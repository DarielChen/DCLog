//
//  DCLogView.h
//  DCLogViewDemo
//
//  Created by DarielChen https://github.com/DarielChen/DCLog
//  Copyright © 2016年 DarielChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCLogView : UIView

- (void)updateLog:(NSString *)logText;

@property (nonatomic, strong) void(^indexBlock)(NSInteger index);

@property (nonatomic, strong) void(^CleanButtonIndexBlock)(NSInteger index);

@end
