// SPDX-License-Identifier: GPL-3.0-or-later
#pragma once
#import <UIKit/UIKit.h>

// Controller Button Mapping: SunPad's assignment list, then a physical-button
// choice. changed runs after each saved change (reload the mapping there).
void GalaxyPadPresentControllerMapping(UIViewController *presenter, void (^changed)(void));
