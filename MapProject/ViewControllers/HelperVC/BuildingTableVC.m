//
//  BuildingTableVC.m
//  MapProject
//
//  Created by innerpeacer on 15/7/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "BuildingTableVC.h"

@interface BuildingTableVC ()

@end

@implementation BuildingTableVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = _currentCity.name;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_buildingArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    TYBuilding *building = [_buildingArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", building.name, building.buildingID];
    
    return cell;
}



@end
