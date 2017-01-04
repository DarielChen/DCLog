//
//  UIWindow+DCLog.m
//  DCLogViewDemo
//
//  Created by DarielChen on 17/1/4.
//  Copyright © 2017年 DarielChen. All rights reserved.
//

#import "UIWindow+DCLog.h"
#import "DCLog.h"

@implementation UIWindow (DCLog)

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    if (event.type == UIEventSubtypeMotionShake) {
        [DCLog changeVisible];
    }
}


@end
