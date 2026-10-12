// SPDX-License-Identifier: GPL-3.0-or-later
#import <UIKit/UIKit.h>
@interface GalaxyPadAboutViewController : UIViewController
// Game Data & Save Status: what is installed, from file presence only.
+ (UIAlertController *)gameDataStatusAlert;
@end
