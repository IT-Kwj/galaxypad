// SPDX-License-Identifier: GPL-3.0-or-later
#import "../apple/ios/GalaxyPadDocuments.h"
#include <cassert>

int main() {
  @autoreleasepool {
    NSFileManager *files=NSFileManager.defaultManager;
    NSURL *root=[[NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES]
      URLByAppendingPathComponent:NSUUID.UUID.UUIDString isDirectory:YES];
    NSURL *documents=[root URLByAppendingPathComponent:@"Documents" isDirectory:YES];
    NSURL *guide=[documents URLByAppendingPathComponent:@"Import Game Data.txt"];
    NSError *error=nil;
    assert(![files fileExistsAtPath:documents.path]);
    assert(GalaxyPadPrepareDocuments(documents,&error));
    NSData *original=[NSData dataWithContentsOfURL:guide];
    assert(original.length>0);
    assert(GalaxyPadPrepareDocuments(documents,&error));
    assert([[NSData dataWithContentsOfURL:guide] isEqual:original]);

    // An upgrade/relaunch preserves player-supplied files and edited guides.
    NSData *fixture=[@"synthetic player file" dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *image=[documents URLByAppendingPathComponent:@"My Game.wbfs"];
    NSURL *save=[root URLByAppendingPathComponent:@"Library/Save.fixture"];
    assert([files createDirectoryAtURL:[save URLByDeletingLastPathComponent]
      withIntermediateDirectories:YES attributes:nil error:&error]);
    assert([fixture writeToURL:image options:0 error:&error]);
    assert([fixture writeToURL:save options:0 error:&error]);
    assert([fixture writeToURL:guide options:0 error:&error]);
    assert(GalaxyPadPrepareDocuments(documents,&error));
    for (NSURL *url in @[guide,image,save])
      assert([[NSData dataWithContentsOfURL:url] isEqual:fixture]);

    // Recreate a removed guide or directory without disturbing other data.
    assert([files removeItemAtURL:guide error:&error]);
    assert(GalaxyPadPrepareDocuments(documents,&error));
    assert([[NSData dataWithContentsOfURL:guide] isEqual:original]);
    assert([[NSData dataWithContentsOfURL:image] isEqual:fixture]);
    assert([files removeItemAtURL:documents error:&error]);
    assert(GalaxyPadPrepareDocuments(documents,&error));
    assert([[NSData dataWithContentsOfURL:guide] isEqual:original]);
    assert([[NSData dataWithContentsOfURL:save] isEqual:fixture]);

    // A blocked destination reports failure; never replace the blocking file.
    NSURL *blocked=[root URLByAppendingPathComponent:@"Blocked"];
    assert([fixture writeToURL:blocked options:0 error:&error]);
    error=nil;
    assert(!GalaxyPadPrepareDocuments(blocked,&error));
    assert(error!=nil);
    assert([[NSData dataWithContentsOfURL:blocked] isEqual:fixture]);
    assert([files removeItemAtURL:root error:&error]);
    puts("Documents: fresh setup, relaunch, preservation, recovery and failure passed");
  }
}
