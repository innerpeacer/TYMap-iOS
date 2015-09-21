//
//  CityBuildingTableVC.m
//  MapProject
//
//  Created by innerpeacer on 15/8/7.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "CityBuildingTableVC.h"

#import "RATreeView.h"
#import "RADataObject.h"


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface CityBuildingTableVC () <RATreeViewDataSource, RATreeViewDelegate>


@property (nonatomic, strong) NSArray *treeData;

@property (nonatomic, strong) id expanded;

@end

@implementation CityBuildingTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareData];
    [self prepareTreeView];
}

- (void)prepareTreeView
{
//    RATreeView *treeView = [[RATreeView alloc] initWithFrame:self.view.frame];
//    treeView.delegate =self;
//    treeView.dataSource = self;
//    treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLine;
//    [treeView reloadData];
//    //    [treeView expandRowForItem:nil withRowAnimation:RATreeViewRowAnimationLeft];
//    [treeView setBackgroundColor:UIColorFromRGB(0xF7F7F7)];
//    
//    self.treeView = treeView;
//    [self.view addSubview:treeView];
    
    self.treeView.delegate = self;
    self.treeView.dataSource = self;
    self.treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLine;
    [self.treeView reloadData];
    [self.treeView setBackgroundColor:UIColorFromRGB(0xF7F7F7)];
}

- (void)prepareData
{
    NSMutableArray *cityObjectArray = [NSMutableArray array];
    for (int i = 0; i < self.cityArray.count; ++i) {
        TYCity *city = self.cityArray[i];
        NSArray *bArray = self.buildingArray[i];
        
        NSMutableArray *buildingObjectArray = [NSMutableArray array];
        for (int j = 0; j < bArray.count; ++j) {
            TYBuilding *building = bArray[j];
            RADataObject *buildingObject = [RADataObject dataObjectWithName:building.name data:building children:nil];
            [buildingObjectArray addObject:buildingObject];
        }
        
        RADataObject *cityObject = [RADataObject dataObjectWithName:city.name data:city children:buildingObjectArray];
        [cityObjectArray addObject:cityObject];
    }
    self.treeData = cityObjectArray;
}

- (void)viewDidAppear:(BOOL)animated
{
//    NSLog(@"%@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//    [EnviromentManager switchToOriginal];
//    NSLog(@"[EnviromentManager switchToOriginal]");
}


#pragma mark RATreeViewDelegate
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return 47;
}

- (NSInteger)treeView:(RATreeView *)treeView indentationLevelForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return 3 * treeNodeInfo.treeDepthLevel;
}

- (BOOL)treeView:(RATreeView *)treeView shouldExpandItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return YES;
}

- (BOOL)treeView:(RATreeView *)treeView shouldItemBeExpandedAfterDataReload:(id)item treeDepthLevel:(NSInteger)treeDepthLevel
{
    if ([item isEqual:self.expanded]) {
        return YES;
    }
    return NO;
}

- (void)treeView:(RATreeView *)treeView willDisplayCell:(UITableViewCell *)cell forItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    //    if (treeNodeInfo.treeDepthLevel == 0) {
    //        cell.backgroundColor = UIColorFromRGB(0xD1EEFC);
    //    } else if (treeNodeInfo.treeDepthLevel == 1) {
    //        cell.backgroundColor = UIColorFromRGB(0xE0F8D8);
    //    } else if (treeNodeInfo.treeDepthLevel == 2) {
    //        cell.backgroundColor = UIColorFromRGB(0xE0F8D8);
    //    }
}

- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
//    NSLog(@"%@", ((RADataObject *)item).data);
    
    if (treeNodeInfo.treeDepthLevel == 1) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectBuilding:City:)]) {
            [self.delegate didSelectBuilding:((RADataObject *)item).data City:((RADataObject *)treeNodeInfo.parent.item).data];
        }
    }    
}

#pragma mark RATreeViewDataSource
- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    //    NSInteger numberOfChildren = [treeNodeInfo.children count];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (treeNodeInfo.treeDepthLevel == 0) {
        cell.detailTextLabel.textColor = [UIColor blackColor];
        
        TYCity *city = ((RADataObject *)item).data;
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", city.name, city.cityID];
    } else {
        
        TYBuilding *building = ((RADataObject *)item).data;
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", building.name, building.buildingID];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"地址：%@", building.address];
    }
    
    
    return cell;
}

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return [self.treeData count];
    }
    RADataObject *data = item;
    return [data.children count];
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item
{
    RADataObject *data = item;
    if (item == nil) {
        return [self.treeData objectAtIndex:index];
    }
    return [data.children objectAtIndex:index];
}


@end
