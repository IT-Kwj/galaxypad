// SPDX-License-Identifier: GPL-3.0-or-later
// GalaxyPad's touch controls and menu over the New engine
// (docs/ENGINE-SWITCH-PLAN.md). The engine runs the app and draws the game;
// GalaxyPad's overlay goes over its window and feeds the engine's input.
#pragma once

// Call from main() just before galaxypad_engine_main(). The engine's own touch
// controls stay off; GalaxyPad's appear once the game starts.
void GalaxyPadNewEngineHostInstall(void);
