//
//  NephogramMapVC.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NephogramMapVC.h"
#import "TYAreaAnalysis.h"
#import "TYMapEnviroment.h"
#import "TYBrand.h"

@interface NephogramMapVC()
{
    TYAreaAnalysis *areaAnalysis;
    
    AGSGraphicsLayer *testLayer;
    NSTimer *testTimer;
    AGSPoint *testLocation;
    AGSSimpleFillSymbol *testSimpleFillSymbol;
    AGSSimpleLineSymbol *testSimpleLineSymbol;
    int currentRadius;
    int picIndex;
}


@end

@implementation NephogramMapVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    testLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:testLayer];
}

int count = 0;
int tIndex = 0;

- (void)NPMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    NSLog(@"didClickAtPoint: %f, %f", mappoint.x, mappoint.y);
    testLocation = mappoint;
    if (testTimer) {
        [testTimer invalidate];
    }
    testTimer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(showTestLocation) userInfo:nil repeats:YES];
    picIndex = PIC_INITIAL;
    [testLayer removeAllGraphics];
}

const int PIC_INITIAL = 0;
const int PIC_LAST = 7;
- (void)showTestLocation
{
    [testLayer removeAllGraphics];
    
    if (picIndex > PIC_LAST) {
        picIndex = PIC_INITIAL;
    }
    NSString *imageName = [NSString stringWithFormat:@"l%d", picIndex++];
    AGSPictureMarkerSymbol *pms = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:imageName];
    [testLayer addGraphic:[AGSGraphic graphicWithGeometry:testLocation symbol:pms attributes:nil]];
}

@end
