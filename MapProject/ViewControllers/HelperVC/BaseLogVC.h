//
//  BaseLogVC.h
//  MapProject
//
//  Created by innerpeacer on 15/3/8.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseLogVC : UIViewController

@property (nonatomic, weak) IBOutlet UITextView *logView;

- (void)addToLog:(NSString *)logString;

@end
