//
//  SelectBuildingVC.m
//  MapProject
//
//  Created by innerpeacer on 15/8/7.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "SelectBuildingVC.h"
#import "TYUserDefaults.h"

@interface SelectBuildingVC () <CityBuildingTableVCDelegate>

@end

@implementation SelectBuildingVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.delegate = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelSelection:)];
}

- (void)didSelectBuilding:(TYBuilding *)building City:(TYCity *)city
{
    NSLog(@"SelectBuildingVC:didSelectBuilding: %@ - %@", building.name, city.name);
//    [TYUserDefaults setDefaultBuilding:building.buildingID];
//    [TYUserDefaults setDefaultCity:city.cityID];

    if (self.selectDelegate && [self.selectDelegate respondsToSelector:@selector(SelectBuildingVC:didSelectBuliding:City:)]) {
        [self.selectDelegate SelectBuildingVC:self didSelectBuliding:building City:city];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)cancelSelection:(id)sender
{
//    NSLog(@"cancelSelection");

    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
