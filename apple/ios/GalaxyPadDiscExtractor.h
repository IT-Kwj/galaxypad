// SPDX-License-Identifier: GPL-3.0-or-later
// SunPad-derived staged extractor; only the configured exact Galaxy image.
#import <Foundation/Foundation.h>
// Written in the extracted folder once files/ holds every file on the disc (the
// New engine reads them all; the Original engine reads the image).
#define GalaxyPadFilesCompleteMarker ".galaxypad-files-complete"
@interface GalaxyPadDiscExtractor : NSObject
// Caller supplies a new private staging path; existing destinations are rejected.
// Failure leaves staging for the owning import transaction to clean up.
+ (void)extractImageAtPath:(NSString *)imagePath toDirectory:(NSString *)destination
  progress:(void (^)(NSString *status, double fraction))progress
  completion:(void (^)(BOOL ok, NSString *error))completion;
// Cancellation is polled on the worker queue. The block must be thread-safe.
// A current DiscIO file export finishes before cancellation is observed.
+ (void)extractImageAtPath:(NSString *)imagePath toDirectory:(NSString *)destination
  cancelled:(BOOL (^)(void))cancelled
  progress:(void (^)(NSString *status, double fraction))progress
  completion:(void (^)(BOOL ok, NSString *error))completion;
// Adds the files an installed extracted folder lacks, from the installed image,
// then writes the marker. Files already present at the right size are kept.
+ (void)completeFilesForImageAtPath:(NSString *)imagePath directory:(NSString *)directory
  cancelled:(BOOL (^)(void))cancelled
  progress:(void (^)(double fraction))progress
  completion:(void (^)(BOOL ok, NSString *error))completion;
@end
