// SPDX-License-Identifier: GPL-3.0-or-later
#import "GalaxyPadDocuments.h"

BOOL GalaxyPadPrepareDocuments(NSURL *directory, NSError **error) {
  NSFileManager *files = NSFileManager.defaultManager;
  if (![files createDirectoryAtURL:directory withIntermediateDirectories:YES attributes:nil error:error])
    return NO;
  NSURL *guide = [directory URLByAppendingPathComponent:@"Import Game Data.txt"];
  if ([files fileExistsAtPath:guide.path]) return YES;
  NSString *instructions = @"Import your game into GalaxyPad\n\n"
    "Open GalaxyPad, then choose:\n"
    "Three-dot menu > Game Data & Saves > Import or Reimport Game Data > Choose Image.\n\n"
    "Select your own Super Mario Galaxy USA (RMGE01 revision 0), single-file WBFS image. "
    "You can select it directly from Downloads, iCloud Drive, or another Files location; "
    "download the file to your device first. You do not have to move it into this folder.\n\n"
    "Alternatively, copy the WBFS directly into this GalaxyPad folder, then choose "
    "Import from GalaxyPad Folder in Game Data & Saves. Copying alone does not import it.\n\n"
    "Keep at least 9 GiB free for import. ISO, other regions/revisions, and split WBFS "
    "are not supported. Reopen GalaxyPad after import completes.\n\n"
    "Installed game data and saves are stored privately, outside this folder. "
    "Update GalaxyPad in place with the same sideloading tool and Apple ID to keep saves.\n";
  // Never overwrite a file supplied or edited by the player, including a file
  // created between the existence check and this write.
  NSError *writeError = nil;
  if ([[instructions dataUsingEncoding:NSUTF8StringEncoding] writeToURL:guide
      options:NSDataWritingWithoutOverwriting error:&writeError]) return YES;
  if ([writeError.domain isEqualToString:NSCocoaErrorDomain] && writeError.code == NSFileWriteFileExistsError)
    return YES;
  if (error) *error = writeError;
  return NO;
}
