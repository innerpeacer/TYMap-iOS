//
//  TYFanRange.h
//  BLEProject
//
//  Created by innerpeacer on 2017/5/15.
//  Copyright © 2017年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>
#import <TYMapData/TYMapData.h>

@interface TYFanRange : NSObject
//@property (nonatomic, strong) NSNumber *heading;
@property (nonatomic, strong) TYLocalPoint *center;

- (id)initWithCenter:(TYLocalPoint *)center Heading:(NSNumber *)heading;
- (void)updateCenter:(TYLocalPoint *)center;
- (void)updateHeading:(double)heading;

- (AGSGeometry *)toFanGeometry;
- (AGSGeometry *)toArcGeometry;

- (AGSGeometry *)toArcGeometry1WithStartAngle:(double)startAngle endAngle:(double)endAngle;
- (AGSGeometry *)toArcGeometry2WithStartAngle:(double)startAngle endAngle:(double)endAngle;

@end
