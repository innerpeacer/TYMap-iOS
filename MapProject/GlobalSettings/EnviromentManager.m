//
//  EnviromentManager.m
//  MapProject
//
//  Created by innerpeacer on 15/7/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "EnviromentManager.h"
#import "TYMapEnviroment.h"
#import "TYUserDefaults.h"

@implementation EnviromentManager

+ (void)switchToEncrypted
{
//    NSString *pathMapEncrypted = [[NSBundle mainBundle] pathForResource:DEFAULT_MAP_ENCRPTION_ROOT ofType:nil];
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [TYMapEnvironment setRootDirectoryForMapFiles:[documentDirectory stringByAppendingPathComponent:DEFAULT_MAP_ENCRPTION_ROOT]];
    [TYMapEnvironment setEncryptionEnabled:YES];
}

+ (void)switchToOriginal
{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [TYMapEnvironment setEncryptionEnabled:NO];
    [TYMapEnvironment setRootDirectoryForMapFiles:[documentDirectory stringByAppendingPathComponent:DEFAULT_MAP_ROOT]];
}

@end
