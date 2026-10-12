// SPDX-License-Identifier: GPL-3.0-or-later
#import "GalaxyPadNewEngineHost.h"
#import "GalaxyPadGameOverlay.h"
#import "GalaxyPadGyroPointer.h"
#import "GalaxyPadAboutViewController.h"
#import "GalaxyPadReportViewController.h"
#import "../shared/GalaxyPadDiagnostics.h"
#include "../shared/GalaxyPadInput.h"
#include <cmath>
#include <stdlib.h>

// GalaxyPadEngine.framework (ref/galaxypad-engine native/app/engine_entry.mm).
extern "C" void galaxypad_engine_input(uint32_t buttons, float stickX, float stickY, int pointerVisible,
                                       float pointerX, float pointerY);
extern "C" int galaxypad_engine_image(float *x, float *y, float *width, float *height);
extern "C" int galaxypad_engine_started(void);
extern "C" void galaxypad_engine_switch_to_original(void);

@interface GalaxyPadNewEngineHost : NSObject <GalaxyPadGameOverlayDelegate>
@end

// The overlay's own view controller, in a window above the engine's: menus and
// alerts present from it as they do over the Original engine.
@interface GalaxyPadNewEngineControlsController : UIViewController
@end
@implementation GalaxyPadNewEngineControlsController
- (UIInterfaceOrientationMask)supportedInterfaceOrientations { return UIInterfaceOrientationMaskLandscape; }
- (BOOL)prefersStatusBarHidden { return YES; }
- (BOOL)prefersHomeIndicatorAutoHidden { return YES; }
@end

@implementation GalaxyPadNewEngineHost {
  GalaxyPadGameOverlay *_overlay;
  GalaxyPadGyroPointer *_gyro;
  galaxypad::InputMixer _mixer;
  UIWindow *_controlsWindow;
  NSTimer *_timer;
  CGRect _image;
  BOOL _started;
  BOOL _active;
  BOOL _blocked;
}

- (instancetype)init {
  if ((self = [super init])) {
    _active = YES;
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    [center addObserver:self selector:@selector(windowBecameKey:) name:UIWindowDidBecomeKeyNotification object:nil];
    [center addObserver:self selector:@selector(becameActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [center addObserver:self selector:@selector(resignedActive) name:UIApplicationWillResignActiveNotification object:nil];
  }
  return self;
}

// The engine's SDL window appeared: GalaxyPad's overlay goes in a window of its
// own above it (the engine's root view is a Metal view, which draws over any
// subview). The window stays hidden until the game starts, so a tap reaches the
// engine's shader preparation screen.
- (void)windowBecameKey:(NSNotification *)note {
  UIWindow *window = note.object;
  if (_overlay || !window.windowScene) return;
  GalaxyPadNewEngineControlsController *controller = [GalaxyPadNewEngineControlsController new];
  _controlsWindow = [[UIWindow alloc] initWithWindowScene:window.windowScene];
  _controlsWindow.windowLevel = window.windowLevel + 1;
  _controlsWindow.backgroundColor = UIColor.clearColor;
  _controlsWindow.rootViewController = controller;
  _controlsWindow.hidden = YES;
  controller.view.backgroundColor = UIColor.clearColor;
  _overlay = [[GalaxyPadGameOverlay alloc] initWithFrame:controller.view.bounds];
  _overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  _overlay.delegate = self;
  _overlay.hostedByNewEngine = YES;
  _overlay.gameplayAvailable = NO;
  [_overlay applySettings];
  [controller.view addSubview:_overlay];
  __weak GalaxyPadNewEngineHost *weakSelf = self;
  _overlay.viewportProvider = ^CGRect {
    GalaxyPadNewEngineHost *host = weakSelf;
    return host ? host->_image : CGRectZero;
  };
  _overlay.inputChanged = ^(galaxypad::InputState input) {
    GalaxyPadNewEngineHost *host = weakSelf;
    if (!host) return;
    [host->_gyro acceptTouch:input];
    host->_mixer.set(galaxypad::InputSource::Touch, input);
    [host sendInput];
  };
  _overlay.nativeUIChanged = ^{ [weakSelf menusChanged]; };
  _overlay.gyroSettingsChanged = ^{ [weakSelf clearInput]; };
  __weak GalaxyPadGameOverlay *weakOverlay = _overlay;
  _gyro = [GalaxyPadGyroPointer new];
  __weak GalaxyPadGyroPointer *weakGyro = _gyro;
  _overlay.gyroRecenterRequested = ^{ [weakGyro recenter]; };
  _gyro.inputAllowed = ^BOOL {
    GalaxyPadNewEngineHost *host = weakSelf;
    return host && host->_active && host->_started && !host->_blocked;
  };
  _gyro.orientation = ^UIInterfaceOrientation { return weakOverlay.window.windowScene.interfaceOrientation; };
  _gyro.controller = ^GCController * { return nil; };
  _gyro.inputChanged = ^(galaxypad::InputState state) {
    GalaxyPadNewEngineHost *host = weakSelf;
    if (!host) return;
    host->_mixer.set(galaxypad::InputSource::Gyro, state);
    [host sendInput];
  };
  _gyro.statusChanged = ^(NSString *status) { weakOverlay.gyroStatus = status; };
  [_gyro start];
  _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer *timer) {
    GalaxyPadNewEngineHost *host = weakSelf;
    if (!host) { [timer invalidate]; return; }
    [host tick];
  }];
  [self tick];
  GalaxyPadLog(@"new engine: GalaxyPad controls attached");
}

- (void)tick {
  float x = 0, y = 0, width = 0, height = 0;
  const CGRect image = galaxypad_engine_image(&x, &y, &width, &height) ? CGRectMake(x, y, width, height) : CGRectZero;
  if (!CGRectEqualToRect(image, _image)) {
    _image = image;
    [_overlay setNeedsLayout];
  }
  if (!_started && galaxypad_engine_started()) {
    _started = YES;
    _controlsWindow.hidden = NO;
    _overlay.gameplayAvailable = YES;
    GalaxyPadLog(@"new engine: game started; GalaxyPad controls shown");
  }
}

- (void)sendInput {
  galaxypad::InputState out;
  if (_active && _started && !_blocked) out = _mixer.consume();
  // The engine steers balls and rays from the stick, so the tilt stick is a stick too.
  const float x = std::fabs(out.tiltX) > std::fabs(out.moveX) ? out.tiltX : out.moveX;
  const float y = std::fabs(out.tiltY) > std::fabs(out.moveY) ? out.tiltY : out.moveY;
  galaxypad_engine_input(out.buttons, x, y, out.pointerVisible, out.pointerX, out.pointerY);
}

- (void)clearInput {
  _mixer.clearAll();
  [_gyro reset];
  [self sendInput];
}

- (void)menusChanged {
  const BOOL blocked = _overlay.blocksGameplay || _overlay.nativeMenuVisible;
  if (blocked == _blocked) return;
  _blocked = blocked;
  [self clearInput];
}

- (void)becameActive { _active = YES; }
- (void)resignedActive {
  _active = NO;
  [_overlay reset];
  [self clearInput];
}

- (UIViewController *)presenter {
  UIViewController *controller = _controlsWindow.rootViewController;
  while (controller.presentedViewController) controller = controller.presentedViewController;
  return controller;
}

#pragma mark - Menu

- (void)gameOverlayRequestsOriginalEngine:(GalaxyPadGameOverlay *)overlay {
  (void)overlay;
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Switch to the Original Engine?"
    message:@"GalaxyPad copies your saved progress to the Original engine and closes. Unsaved progress since your last save is lost. Open GalaxyPad again to play."
    preferredStyle:UIAlertControllerStyleAlert];
  [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
  [alert addAction:[UIAlertAction actionWithTitle:@"Switch" style:UIAlertActionStyleDefault
    handler:^(UIAlertAction *action) {
      (void)action;
      GalaxyPadLog(@"new engine: switching to the Original engine");
      galaxypad_engine_switch_to_original();
    }]];
  [[self presenter] presentViewController:alert animated:YES completion:nil];
}

- (void)gameOverlayRequestsAbout:(GalaxyPadGameOverlay *)overlay {
  (void)overlay;
  UINavigationController *navigation = [[UINavigationController alloc]
    initWithRootViewController:[[GalaxyPadAboutViewController alloc] init]];
  navigation.modalPresentationStyle = UIModalPresentationPageSheet;
  [[self presenter] presentViewController:navigation animated:YES completion:nil];
}

- (void)gameOverlayRequestsProblemReport:(GalaxyPadGameOverlay *)overlay {
  (void)overlay;
  [GalaxyPadReportViewController presentReportPromptFrom:[self presenter] technicalContext:^NSString * {
    return [NSString stringWithFormat:@"engine=new platform=%@ os=%@ thermalState=%ld lowPowerMode=%d",
      TARGET_OS_SIMULATOR ? @"simulator" : @"device", UIDevice.currentDevice.systemVersion,
      (long)NSProcessInfo.processInfo.thermalState, NSProcessInfo.processInfo.lowPowerModeEnabled];
  }];
}
@end

void GalaxyPadNewEngineHostInstall(void) {
  // GalaxyPad's controls replace the engine's own (its touch_controls.cpp).
  setenv("PETARI_TOUCH_CONTROLS", "0", 1);
  GalaxyPadDiagnosticsStart();
  // Lives as long as the app (the engine never returns).
  static GalaxyPadNewEngineHost *host = [GalaxyPadNewEngineHost new];
  (void)host;
}
