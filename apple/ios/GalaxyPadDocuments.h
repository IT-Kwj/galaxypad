// SPDX-License-Identifier: GPL-3.0-or-later
#import <Foundation/Foundation.h>

// Keep the Files-visible directory populated, without replacing player files.
// The URL is explicit so regression tests never touch a real app's documents.
BOOL GalaxyPadPrepareDocuments(NSURL *directory, NSError **error);
