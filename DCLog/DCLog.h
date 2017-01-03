//
//  DCLog.h
//  DCLogViewDemo
//
//  Created by DarielChen https://github.com/DarielChen/DCLog.
//  Copyright © 2016年 DarielChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCLog : NSObject


/**
 Start record Normal and Crash log 
 
 You can use in -application:didFinishLaunchingWithOptions:
 */
+ (void)startRecord;


/**
 Hide or show the LogView
 
 You can add the code in AppDelegate.m
 
 - (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
 
    if (event.type == UIEventSubtypeMotionShake) {
        [DCLog changeVisible];
    }
 }
 */
+ (void)changeVisible;

@end
