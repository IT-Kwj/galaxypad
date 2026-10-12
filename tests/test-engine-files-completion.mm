// SPDX-License-Identifier: GPL-3.0-or-later
// Private evidence: GalaxyPadDiscExtractor's New-engine file completion against
// the real RMGE01 image. Usage: engine-files-completion IMAGE REFERENCE SCRATCH
// REFERENCE is a full extracted tree of the same disc (sys/ and files/);
// SCRATCH is a new directory. Run by tests/test-engine-files-completion.sh.
#import "../apple/ios/GalaxyPadDiscExtractor.h"
#include <atomic>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <memory>
#include <string>
namespace fs=std::filesystem;

static int checks=0;
static void check(bool ok,const char *label) {
  ++checks;
  if (!ok) { std::fprintf(stderr,"FAIL: %s\n",label); std::exit(1); }
}

struct Result { BOOL ok; NSString *error; int progressCalls; double lastFraction; };
static Result Complete(NSString *image,NSString *folder,BOOL (^cancelled)(void),void (^progressed)(void)=nil) {
  __block Result result{NO,nil,0,0};
  __block BOOL done=NO;
  [GalaxyPadDiscExtractor completeFilesForImageAtPath:image directory:folder cancelled:cancelled
    progress:^(double fraction) {
      ++result.progressCalls; result.lastFraction=fraction;
      if (progressed) progressed();
    }
    completion:^(BOOL ok,NSString *error) { result.ok=ok; result.error=error; done=YES; }];
  while (!done) [NSRunLoop.mainRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
  return result;
}

static bool SameBytes(const fs::path& a,const fs::path& b) {
  std::error_code error;
  if (fs::file_size(a,error)!=fs::file_size(b,error) || error) return false;
  std::ifstream x(a,std::ios::binary), y(b,std::ios::binary);
  static char bx[1<<20], by[1<<20];
  while (x && y) {
    x.read(bx,sizeof bx); y.read(by,sizeof by);
    if (x.gcount()!=y.gcount() || std::memcmp(bx,by,(size_t)x.gcount())!=0) return false;
  }
  return x.eof() && y.eof();
}

// Every file in the reference files/ tree matches the scratch tree byte for byte.
static size_t CompareFiles(const fs::path& reference,const fs::path& scratch) {
  size_t count=0;
  for (const auto& entry:fs::recursive_directory_iterator(reference/"files")) {
    if (!entry.is_regular_file()) continue;
    const auto relative=fs::relative(entry.path(),reference);
    check(SameBytes(entry.path(),scratch/relative),"completed file matches the reference");
    ++count;
  }
  return count;
}

static size_t PartialFiles(const fs::path& root) {
  size_t count=0;
  for (const auto& entry:fs::recursive_directory_iterator(root))
    if (entry.path().extension()==".partial") ++count;
  return count;
}

int main(int argc,char **argv) {
  @autoreleasepool {
    check(argc==4,"usage: IMAGE REFERENCE SCRATCH");
    NSString *image=@(argv[1]);
    const fs::path reference=argv[2], scratch=argv[3];
    const fs::path folder=scratch/"RMGE01";
    NSString *folderPath=@(folder.c_str());
    const fs::path marker=folder/GalaxyPadFilesCompleteMarker;
    check(fs::create_directory(scratch),"SCRATCH is new");

    // An install from an older build: sys/ and the two files the import verifies.
    fs::create_directories(folder/"files/ModuleData");
    fs::copy(reference/"sys",folder/"sys",fs::copy_options::recursive);
    for (const char *name:{"HomeButtonMenuWrapperRSO.rso","product.sel"})
      fs::copy_file(reference/"files/ModuleData"/name,folder/"files/ModuleData"/name);

    // Cancel once the first file is reported: a clean stop, no marker.
    auto stop=std::make_shared<std::atomic<bool>>(false);
    Result cancelled=Complete(image,folderPath,^BOOL { return stop->load(); },^{ stop->store(true); });
    check(!cancelled.ok && [cancelled.error hasPrefix:@"Cancelled"],"Cancel reports a cancelled run");
    check(!fs::exists(marker),"no marker after Cancel");

    Result first=Complete(image,folderPath,nil);
    check(first.ok && first.error==nil,"completion succeeds");
    check(first.progressCalls>0 && first.lastFraction==1.0,"progress reaches 100%");
    check(fs::exists(marker),"marker written");
    check(PartialFiles(folder)==0,"no temporary files left");
    const size_t files=CompareFiles(reference,folder);
    std::printf("%zu files match the reference byte for byte\n",files);

    Result again=Complete(image,folderPath,nil);
    check(again.ok && again.progressCalls==0,"a complete folder needs no writes");

    // A damaged file and a leftover temporary file are replaced.
    const fs::path damaged=folder/"files/ModuleData/product.sel";
    fs::resize_file(damaged,10);
    { std::ofstream stray(damaged.string()+".partial"); stray<<"stray"; }
    Result repaired=Complete(image,folderPath,nil);
    check(repaired.ok && repaired.progressCalls==1,"only the damaged file is exported");
    check(SameBytes(damaged,reference/"files/ModuleData/product.sel"),"damaged file restored");
    check(PartialFiles(folder)==0,"leftover temporary file removed");

    // A folder that is not this game's is refused.
    fs::resize_file(folder/"sys/main.dol",16);
    Result wrong=Complete(image,folderPath,nil);
    check(!wrong.ok && wrong.error.length>0,"a damaged main.dol is refused");

    std::printf("engine file completion passed (%d checks)\n",checks);
  }
  return 0;
}
