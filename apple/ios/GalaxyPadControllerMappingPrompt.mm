// SPDX-License-Identifier: GPL-3.0-or-later
// Controller Button Mapping (moved from main.mm so both engines show it).
#import "GalaxyPadControllerMappingPrompt.h"
#import "../shared/GalaxyPadControllerMappingStore.h"

static void GalaxyPadPresentControllerChoices(UIViewController *presenter, unsigned game, void (^changed)(void));
void GalaxyPadPresentControllerMapping(UIViewController *presenter, void (^changed)(void)) {
  // SunPad's assignment-list/physical-choice flow, with Galaxy's action set.
  const auto mapping=GalaxyPadControllerMappingStore.mapping;
  NSArray *games=@[@"A", @"B", @"Spin", @"C", @"Z"];
  NSArray *physical=@[@"A", @"B", @"X", @"Y", @"Left Trigger"];
  UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"Controller Button Mapping"
    message:@"Assignments swap to keep every action reachable. Left stick moves; right stick aims; click right stick to recenter. Choose Controls → Stick Mode for Ray Surfing or Star Ball: left stick tilts, with the correct remote pose. Return to Normal for walking and aiming. Hold Left Shoulder for optional right-stick tilt. Right Shoulder is also A; Right Trigger is also B, so you can aim while using either action. Menu/Start or the on-screen + opens Galaxy’s original pause menu, including Return to Observatory when available. View/Select toggles app pause; press it again to resume. D-pad controls the camera. Connect a controller to test."
    preferredStyle:UIAlertControllerStyleAlert];
  __weak UIViewController *weakPresenter=presenter;
  for (unsigned i=0;i<5;++i) {
    [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@ — %@",games[i],physical[mapping.physical[i]]]
      style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        (void)action;
        UIViewController *view=weakPresenter;
        [view dismissViewControllerAnimated:YES completion:^{ GalaxyPadPresentControllerChoices(view, i, changed); }];
      }]];
  }
  [alert addAction:[UIAlertAction actionWithTitle:@"Reset to Default" style:UIAlertActionStyleDestructive
    handler:^(UIAlertAction *action) {
      (void)action;
      UIViewController *view=weakPresenter;
      if (!view) return;
      [GalaxyPadControllerMappingStore reset];
      changed();
      [view dismissViewControllerAnimated:YES completion:^{ GalaxyPadPresentControllerMapping(view, changed); }];
    }]];
  [alert addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:nil]];
  [presenter presentViewController:alert animated:YES completion:nil];
}
static void GalaxyPadPresentControllerChoices(UIViewController *presenter, unsigned game, void (^changed)(void)) {
  if (game>=5) return;
  NSArray *games=@[@"A", @"B", @"Spin", @"C", @"Z"];
  NSArray *physical=@[@"A", @"B", @"X", @"Y", @"Left Trigger"];
  UIAlertController *alert=[UIAlertController alertControllerWithTitle:games[game]
    message:@"Choose a physical button. Its existing assignment swaps with this one."
    preferredStyle:UIAlertControllerStyleAlert];
  __weak UIViewController *weakPresenter=presenter;
  for (unsigned i=0;i<5;++i) {
    [alert addAction:[UIAlertAction actionWithTitle:physical[i] style:UIAlertActionStyleDefault
      handler:^(UIAlertAction *action) {
        (void)action;
        UIViewController *view=weakPresenter;
        if (!view) return;
        [GalaxyPadControllerMappingStore setMapping:GalaxyPadControllerMappingStore.mapping.assigning(game,i)];
        changed();
        [view dismissViewControllerAnimated:YES completion:^{ GalaxyPadPresentControllerMapping(view, changed); }];
      }]];
  }
  [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
    handler:^(UIAlertAction *action) {
      (void)action;
      UIViewController *view=weakPresenter;
      [view dismissViewControllerAnimated:YES completion:^{ GalaxyPadPresentControllerMapping(view, changed); }];
    }]];
  [presenter presentViewController:alert animated:YES completion:nil];
}
