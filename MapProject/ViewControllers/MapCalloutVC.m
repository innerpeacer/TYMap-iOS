//
//  MapCalloutVC.m
//  MapProject
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
    
    CGRect frame = CGRectMake(0, 0, 200, 125);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.calloutViewController = [storyboard instantiateViewControllerWithIdentifier:@"customCalloutController"];
    [self.calloutViewController.view setFrame:frame];
    [self.calloutViewController.view setClipsToBounds:YES];
}

- (void)NPMapView:(NPMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(TYPoint *)mappoint
{
    NSLog(@"didClickAtPoint: %f, %f", mappoint.x, mappoint.y);
}

- (void)NPMapView:(NPMapView *)mapView didFinishLoadingFloor:(NPMapInfo *)mapInfo
{
    NSLog(@"NPMapView:calloutWillDismiss");
}

- (void)NPMapView:(NPMapView *)mapView calloutWillDismiss:(TYCallout *)callout
{
    NSLog(@"NPMapView:calloutWillDismiss");
}

- (BOOL)NPMapView:(NPMapView *)mapView willShowForGraphic:(TYGraphic *)graphic layer:(TYGraphicsLayer *)layer mapPoint:(TYPoint *)mappoint
{
    NSLog(@"NPMapView:willShowForGraphic:layer:mapPoint:");
    
    if ([layer.name isEqualToString:@"LabelLayer"] || [layer.name isEqualToString:@"FloorLayer"] || [layer.name isEqualToString:@"hintLayer"]) {
        return NO;
    }
    
    NSString *name = [graphic attributeForKey:@"NAME"];
    NSString *gid = [graphic attributeForKey:@"OBJECTID"];
    NSString *type = [graphic attributeForKey:@"CATEGORY_ID"];

    
    self.calloutViewController.nameLabel.text = [NSString stringWithFormat:@"%@", name];
    self.calloutViewController.typeLabel.text = [NSString stringWithFormat:@"%@", type];
    self.calloutViewController.idLabel.text = [NSString stringWithFormat:@"%@", gid];
    
    self.mapView.callout.customView = self.calloutViewController.view;
    
//    self.mapView.callout.borderColor = [UIColor blackColor];
//    self.mapView.callout.borderWidth = 5;
//    self.mapView.callout.margin = CGSizeMake(0, 0);
    self.mapView.callout.color = [UIColor cyanColor];
    
    return YES;
}

//- (void)calloutDidClick:(AGSCallout *)callout
//{
//    //    NSLog(@"calloutDidClick");
//}

@end