//
//  MapTableVC.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "MapTableVC.h"

@implementation MapTableVC

- (void)viewDidLoad
{
    self.objects = [[NSMutableArray alloc] init];
    self.controllerDict = [[NSMutableDictionary alloc] init];
    
    self.title = @"云图地图 Demo";
    
    [self.objects addObject:@"云图地图 Demo"];
    [self.controllerDict setObject:@"mapController" forKey:@"云图地图 Demo"];
    
    [self.objects addObject:@"地图导航 Demo"];
    [self.controllerDict setObject:@"mapRouteController" forKey:@"地图导航 Demo"];
    
    [self.objects addObject:@"地图Callout Demo"];
    [self.controllerDict setObject:@"mapCalloutController" forKey:@"地图Callout Demo"];
    
    [self.objects addObject:@"生成POI数据库"];
    [self.controllerDict setObject:@"CreatePOIDatabaseVC" forKey:@"生成POI数据库"];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [self.objects objectAtIndex:indexPath.row];
    
    if ([self.controllerDict objectForKey:key] != nil) {
        NSString *identifier = [self.controllerDict objectForKey:key];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:identifier];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
