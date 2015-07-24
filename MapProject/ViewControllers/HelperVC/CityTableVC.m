//
//  CityTableVC.m
//  MapProject
//
//  Created by innerpeacer on 15/7/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "CityTableVC.h"

@interface CityTableVC ()

@end

@implementation CityTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_cityArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    TYCity *city = [_cityArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", city.name, city.cityID];
    
    return cell;
}


@end
