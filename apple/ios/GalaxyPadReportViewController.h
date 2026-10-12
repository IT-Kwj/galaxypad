// SPDX-License-Identifier: GPL-3.0-or-later
#import <UIKit/UIKit.h>
@interface GalaxyPadReportViewController : UIViewController
// GitHub review starts without reading or sharing logs. The optional log is
// generated only when the user enables it on the review screen.
- (instancetype)initWithReporterAnswers:(NSDictionary<NSString *, NSString *> *)answers
                      technicalContext:(NSString *)context;
// Existing local diagnostic-log review entry point.
- (instancetype)initWithReportURL:(NSURL *)url;
// "Report a Problem": three short questions, then the GitHub draft review.
// context is read when the user continues.
// Shows a saved diagnostic report for review, or says it could not be saved.
+ (void)presentReportURL:(NSURL *)url from:(UIViewController *)presenter;
+ (void)presentReportPromptFrom:(UIViewController *)presenter technicalContext:(NSString *(^)(void))context;
@end
