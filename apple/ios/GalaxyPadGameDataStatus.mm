// SPDX-License-Identifier: GPL-3.0-or-later
#import "GalaxyPadGameDataStatus.h"
#include "GalaxyPadDiscIdentity.h"

UIAlertController *GalaxyPadGameDataStatusAlert(void) {

  NSURL *support=[NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory
    inDomains:NSUserDomainMask].firstObject;
  NSURL *root=[support URLByAppendingPathComponent:@"GalaxyPad" isDirectory:YES];
  NSFileManager *files=NSFileManager.defaultManager;
  BOOL image=[files fileExistsAtPath:[root URLByAppendingPathComponent:@"GameData/RMGE01.wbfs"].path];
  BOOL save=[files fileExistsAtPath:[root URLByAppendingPathComponent:@"Wii/title/00010000/524d4745/data/GameData.bin"].path];
  BOOL newFiles=[files fileExistsAtPath:[root URLByAppendingPathComponent:@"GameData/RMGE01/.galaxypad-files-complete"].path];
  BOOL newSave=[files fileExistsAtPath:[root URLByAppendingPathComponent:@"NewEngine/NAND/title/00010000/524d4745/data/GameData.bin"].path];
  NSString *message=[NSString stringWithFormat:
    @"Supported: Super Mario Galaxy\nRMGE01 · revision 0\n\n"
     "Imported image: %@\nNew engine game files: %@\n"
     "Old engine save: %@\nNew engine save: %@\n\n"
     "Both engines keep the same progress: switching engines copies the save across.\n\n"
     "Expected main.dol SHA-256:\n%@\n\n"
     "File presence only. Integrity and saved progress are not checked here.",
    image ? @"Detected" : @"Not detected", newFiles ? @"Complete" : @"Not added yet",
    save ? @"Detected" : @"Not detected", newSave ? @"Detected" : @"Not detected", @(GalaxyPadDOLSHA256)];
  UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"Game Data & Saves"
    message:message preferredStyle:UIAlertControllerStyleAlert];
  [alert addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:nil]];
  return alert;
}
