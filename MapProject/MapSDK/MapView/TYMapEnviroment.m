//
//  TYMapEnviroment.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYMapEnviroment.h"

#define DEFAULT_MAP_ROOT @"Map"

@implementation TYMapEnvironment

static NSString *mapFileRootDirectory;

+ (NSString *)getRootDirectoryForMapFiles
{
    if (mapFileRootDirectory == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        mapFileRootDirectory = [documentDirectory stringByAppendingPathComponent:DEFAULT_MAP_ROOT];
    }
    return mapFileRootDirectory;
}

+ (void)setRootDirectoryForMapFiles:(NSString *)dir
{
    mapFileRootDirectory = [NSString stringWithString:dir];
}

+ (TYSpatialReference *)defaultSpatialReference
{
    static TYSpatialReference *spatialReference;
    if (spatialReference == nil) {
        spatialReference = [TYSpatialReference spatialReferenceWithWKID:3395];
    }
    return spatialReference;
}

+ (TYCredential *)defaultCredential
{
    static TYCredential *credential;
    if (credential == nil) {
        credential = [[TYCredential alloc] initWithUser:@"ArcGIS" password:@"OurArcGIS"];
    }
    return credential;
}

+ (void)initMapEnvironment
{
    NSError *error;
    NSString* clientID = @"aBYcI5ED55pNyHQ8";
    [AGSRuntimeEnvironment setClientID:clientID error:&error];
    if(error){
        NSLog(@"Error using client ID : %@",[error localizedDescription]);
    }
    
//    [[AGSRuntimeEnvironment license] setLicenseCode:@"runtimestandard,101,rud514140042,none, 8SF97XLL6S875E5HJ220"];
//    ArcGISRuntime.SetLicense("runtimestandard,101,rud514140042,none, 8SF97XLL6S875E5HJ220");
}

static TYMapLanguage mapLanguage = TYSimplifiedChinese;
+ (void)setMapLanguage:(TYMapLanguage)language
{
    mapLanguage = language;
}

+ (TYMapLanguage)getMapLanguage
{
    return mapLanguage;
}

static BOOL useEncryption = YES;
+ (void)setEncryptionEnabled:(BOOL)enable
{
    useEncryption = enable;
}

+ (BOOL)useEncryption
{
    return useEncryption;
}

@end
