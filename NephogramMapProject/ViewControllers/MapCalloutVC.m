//
//  MapCalloutVC.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "MapCalloutVC.h"
#import "NPMapView.h"
#import "CustomCalloutVC.h"

@interface MapCalloutVC() <AGSCalloutDelegate>
{
    
}
@property (nonatomic, strong) CustomCalloutVC *calloutViewController;

@end

@implementation MapCalloutVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.mapView.highlightPOIOnSelection = YES;
    
    self.mapView.callout.delegate = self;
    
    CGRect frame = CGRectMake(0, 0, 200, 125);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.calloutViewController = [storyboard instantiateViewControllerWithIdentifier:@"customCalloutController"];
    [self.calloutViewController.view setFrame:frame];
    [self.calloutViewController.view setClipsToBounds:YES];
}

- (void)NPMapView:(NPMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    NSLog(@"didClickAtPoint: %f, %f", mappoint.x, mappoint.y);
}

- (void)NPMapView:(NPMapView *)mapView didFinishLoadingFloor:(NPMapInfo *)mapInfo
{
    
}

- (void)calloutDidDismiss:(AGSCallout *)callout
{
    //    NSLog(@"calloutDidDismiss");
}

- (void)calloutWillDismiss:(AGSCallout *)callout
{
    //    NSLog(@"calloutWillDismiss");
}

- (BOOL)callout:(AGSCallout *)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable> *)layer mapPoint:(AGSPoint *)mapPoint
{
    //    NSLog(@"willShowForFeature");
    
    if ([layer.name isEqualToString:@"LabelLayer"] || [layer.name isEqualToString:@"FloorLayer"] || [layer.name isEqualToString:@"hintLayer"]) {
        return NO;
    }
    
    AGSGraphic *graphic = (AGSGraphic *)feature;
    NSString *name = [graphic attributeForKey:@"NAME"];
    NSString *gid = [graphic attributeForKey:@"OBJECTID"];
    NSString *type = [graphic attributeForKey:@"CATEGORY_ID"];
    
    
    self.calloutViewController.nameLabel.text = [NSString stringWithFormat:@"%@", name];
    self.calloutViewController.typeLabel.text = [NSString stringWithFormat:@"%@", type];
    self.calloutViewController.idLabel.text = [NSString stringWithFormat:@"%@", gid];
    
    self.mapView.callout.customView = self.calloutViewController.view;
    
    return YES;
}

- (BOOL)callout:(AGSCallout *)callout willShowForLocationDisplay:(AGSLocationDisplay *)locationDisplay
{
    //    NSLog(@"willShowForLocationDisplay");
    return YES;
}

- (void)calloutDidClick:(AGSCallout *)callout
{
    //    NSLog(@"calloutDidClick");
}

@end