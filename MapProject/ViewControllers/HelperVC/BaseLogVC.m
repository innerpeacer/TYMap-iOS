//
//  BaseLogVC.m
//  MapProject
//
//  Created by innerpeacer on 15/3/8.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "BaseLogVC.h"

@interface BaseLogVC ()
{
    NSMutableString *logString;
}
@end

@implementation BaseLogVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    logString = [NSMutableString string];
    self.logView.textAlignment = NSTextAlignmentCenter;
}

- (void)addToLog:(NSString *)str
{
    [logString appendFormat:@"%@\n", str];
    [self.logView setText:logString];
    [self.logView scrollRangeToVisible:NSMakeRange(self.logView.text.length, 1)];
}

@end