//
//  DCLog.m
//  DCLogViewDemo
//
//  Created by DarielChen https://github.com/DarielChen/DCLog
//  Copyright © 2016年 DarielChen. All rights reserved.
//

#import "DCLog.h"
#import "DCLogView.h"


#define LogFileName @"DCLogInfo.log"
#define CarshFileName @"DCCrashInfo.log"

#define DCWeakSelf __weak typeof(self) weakSelf = self;

@interface DCLog()

@property (nonatomic, copy) NSString *crashInfoString;

@property (nonatomic, strong) DCLogView *logView;

@property (nonatomic, strong) NSTimer *time;

@property (nonatomic, assign) NSInteger index;

@property(nonatomic, assign) BOOL logViewEnabled;


@end

@implementation DCLog

+ (void)setLogViewEnabled:(BOOL)logViewEnabled {

    [DCLog shareLog].logViewEnabled = logViewEnabled;
    
    [DCLog startRecord];
}

+ (void)startRecord {
    if ([DCLog shareLog].logViewEnabled == YES) {

#if DEBUG
        NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
        [[DCLog shareLog] saveLogInfo];
#else
#endif
    }
}

+ (void)changeVisible {
    
    if ([DCLog shareLog].logViewEnabled == YES) {
        
#if DEBUG
        DCLog *log = [DCLog shareLog];
        log.time ? [log hideLogView] : [log showLogView];
#else
#endif
    }
}


+ (instancetype)shareLog {
    static DCLog *log = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        log = [[DCLog alloc] init];
        [log readCarshInfo];
    });
    return log;
}

- (DCLogView *)logView {
    
    if (!_logView) {
        _logView = [[DCLogView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _logView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [[UIApplication sharedApplication].keyWindow addSubview:self.logView];
        
        self.logView.hidden = YES;
        self.logView.alpha = 0.0f;
    }
    return _logView;
}

void UncaughtExceptionHandler(NSException *exception) {
    
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    NSString *crashInfo = [NSString stringWithFormat:@"Crash date: %@ \nNexception type: %@ \nCrash reason: %@ \nStack symbol info: %@ \n",[[DCLog shareLog] getCurrentDate], name, reason, arr];
    
    [[DCLog shareLog] saveCrashInfo:crashInfo];
}

- (void)saveLogInfo {
    
    NSString *logPath = [self loadPathWithName:LogFileName];
    [[NSFileManager defaultManager]removeItemAtPath:logPath error:nil];
    
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"SIMULATOR DEVICE");
#else
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout); //c printf
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr); //oc  NSLog
#endif
    
}

- (NSString *)readLogInfo {
    
    NSData *logData = [NSData dataWithContentsOfFile:[self loadPathWithName:LogFileName]];
    NSString *logText = [[NSString alloc]initWithData:logData encoding:NSUTF8StringEncoding];
    
    return logText;
}


- (void)saveCrashInfo:(NSString *)crashInfo {
    
    if (self.crashInfoString) {
        self.crashInfoString = [self.crashInfoString stringByAppendingString:crashInfo];
    }else {
        self.crashInfoString = crashInfo;
    }
    
    [self.crashInfoString writeToFile:[self loadPathWithName:CarshFileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *)readCarshInfo {
    
    NSData *crashData = [NSData dataWithContentsOfFile: [self loadPathWithName:CarshFileName]];
    NSString *crashText = [[NSString alloc]initWithData:crashData encoding:NSUTF8StringEncoding];

    self.crashInfoString = crashText;
    return crashText;
}


- (void)showLogView {
    
    [UIView animateWithDuration:0.4 animations:^{
        self.logView.alpha = 1.0f;
    }];
    
    self.logView.hidden = NO;
    
    self.time = [NSTimer scheduledTimerWithTimeInterval:0.35 target:self selector:@selector(refreshLogText) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.time forMode:NSRunLoopCommonModes];
    
    DCWeakSelf;
    self.logView.indexBlock = ^(NSInteger index) {
        weakSelf.index = index;
    };
    
    self.logView.CleanButtonIndexBlock = ^(NSInteger index) {
        if (index == 0) {
            [[NSFileManager defaultManager]removeItemAtPath:[weakSelf loadPathWithName:LogFileName] error:nil];
            [weakSelf saveLogInfo];
        }else if (index == 1) {
            [[NSFileManager defaultManager]removeItemAtPath:[weakSelf loadPathWithName:CarshFileName] error:nil];
        }
    };
}


- (void)refreshLogText {
    
    if (self.index == 0) {
        [self.logView updateLog:[self readLogInfo]];
    }else if (self.index == 1) {
        [self.logView updateLog:[self readCarshInfo]];
    }
}

- (void)hideLogView {
    
    [UIView animateWithDuration:0.4 animations:^{
        self.logView.alpha = 0.0f;
    }];
    self.logView.hidden = YES;
    
    [self.time invalidate];
    self.time = nil;
}


- (NSString *)loadPathWithName:(NSString *)fileName {
    
    NSString *documentDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentDirPath stringByAppendingPathComponent:fileName];
    return path;
}

- (NSDate *)getCurrentDate {

    NSDate *now = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger seconds = [zone secondsFromGMTForDate:now];
    NSDate *newDate = [now dateByAddingTimeInterval:seconds];
    return newDate;
}


@end
