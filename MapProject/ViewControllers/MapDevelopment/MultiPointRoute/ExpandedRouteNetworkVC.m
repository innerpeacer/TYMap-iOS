//
//  ExpandedRouteNetworkVC.m
//  MapProject
//
//  Created by innerpeacer on 2017/11/7.
//  Copyright © 2017年 innerpeacer. All rights reserved.
//

#import "ExpandedRouteNetworkVC.h"
#import "RouteNetworkDataset.h"
#import "TYUserDefaults.h"
#import "TYMapEnviroment.h"

#import "RouteNetworkDBAdapter.h"

#import "SymbolGroup.h"
#import "LayerGroup.h"

#import "MRLayerGroup.h"
#import "MRMethodHelper.h"
#import "MRParams.h"

#import "MRSuperNode.h"
#import "MRSuperLink.h"
#import "MRSuperRouteNetworkDataset.h"
#import "MRMultiRouteCaculator.h"

@interface ExpandedRouteNetworkVC ()
{
    AGSGeometryEngine *geometryEngine;
    
    RouteNetworkDataset *routeNetwork;
    SymbolGroup *symbolgroup;
    LayerGroup *layergroup;
    
    MRLayerGroup *mLayers;
    MRSymbolGroup *mSymbols;
    
    //    AGSGraphicsLayer *testLayer;
    AGSGraphicsLayer *hintLayer;
    
    AGSPoint *startPoint;
    AGSPoint *endPoint;
    
    MRParams *routeParam;
    NSMutableSet *randomSet;
}
@end

void swap(int array[], int cursor, int i) {
    int temp = array[cursor];
    array[cursor] = array[i];
    array[i] = temp;
}

void fullArray(int array[], int cursor, int end) {
    if (cursor == end) {
        printf("%d, %d, %d, %d\n", array[0], array[1], array[2], array[3]);
    } else {
        for (int i = cursor; i <= end; i++) {
            swap(array, cursor, i);
            fullArray(array, cursor + 1, end);
            swap(array, cursor, i);
        }
    }
}

@implementation ExpandedRouteNetworkVC

- (void)viewDidLoad
{
    self.currentCity = [TYUserDefaults getDefaultCity];
    self.currentBuilding = [TYUserDefaults getDefaultBuilding];
    self.allMapInfos = [TYMapInfo parseAllMapInfo:self.currentBuilding];
    
    [super viewDidLoad];
    
    geometryEngine = [AGSGeometryEngine defaultGeometryEngine];
    
    [MRMethodHelper map:self.mapView zoomToAllExtent:self.allMapInfos];
    self.mapView.backgroundColor = [UIColor darkGrayColor];
    
    RouteNetworkDBAdapter *db = [[RouteNetworkDBAdapter alloc] initWithBuilding:self.currentBuilding];
    [db open];
    routeNetwork = [db readRouteNetworkDataset];
    [db close];
    
    NSLog(@"%@", routeNetwork);
    
    symbolgroup = [[SymbolGroup alloc] init];
    layergroup = [[LayerGroup alloc] init];
    [layergroup addToMap:self.mapView];
    [MRMethodHelper routeNetwork:routeNetwork showNodesAndLinksOnLayer:layergroup];
    
    mSymbols = [[MRSymbolGroup alloc] init];
    mLayers = [[MRLayerGroup alloc] initWithSymbolGroup:mSymbols];
    [mLayers addToMap:self.mapView];
    
    hintLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:hintLayer];
    
    randomSet = [NSMutableSet set];
//    [self generateRandomParams: 4];
    [self generateTestParams];
    [routeParam buildNodes];
    
    [self testMultiRoute];
    
    //    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(testOfflineRoute) userInfo:nil repeats:YES];
}

- (void)testMultiRoute
{
    [mLayers showMultiRouteParams:routeParam];
    //    [self requestRouteWithStart:routeParam.startPoint End:routeParam.endPoint];
    
    NSDate *now = [NSDate date];
//    NSLog(@"MultiRoute: %@", line);
//    [mLayers showRoute:line WithStart:startPoint End:endPoint];
    
//    NSMutableArray *stopsArray = [NSMutableArray arrayWithArray:[routeParam getStopNodes]];
//    index = 0;
//    [self fullArray:stopsArray WithCursor:0 End:(int)stopsArray.count - 1];
    
//    stopArray = [NSMutableArray arrayWithObjects:@1, @2, @3, @4, nil];
//    [self fullArray:stopArray WithCursor:0 End:(int)stopArray.count - 1];
    
    NSMutableDictionary *routeDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *lengthDict = [NSMutableDictionary dictionary];
//    MRSuperNode *startNode = [routeParam getStartNode];
//    MRSuperNode *endNode = [routeParam getEndNode];
    NSArray *stopNodeArray = [routeParam getStopNodes];
    
    NSLog(@"================ BuildKey ===============");

    for (int i = 0; i < stopNodeArray.count; ++i) {
        MRSuperNode *startNode = [routeParam getStartNode];
        MRSuperNode *stopNode = stopNodeArray[i];
        AGSPolyline *line = [routeNetwork getShorestPathFrom:startNode.pos To:stopNode.pos];
        NSString *key = [NSString stringWithFormat:@"%d-%d", startNode.nodeID, stopNode.nodeID];
        NSLog(@"Key: %@ => %d", key, (int)[line numPoints]);
        [routeDict setObject:line forKey:key];
    }
    
    for (int i = 0; i < stopNodeArray.count; ++i) {
        MRSuperNode *endNode = [routeParam getEndNode];
        MRSuperNode *stopNode = stopNodeArray[i];
        AGSPolyline *line = [routeNetwork getShorestPathFrom:stopNode.pos To:endNode.pos];
        NSString *key = [NSString stringWithFormat:@"%d-%d", stopNode.nodeID, endNode.nodeID];
        NSLog(@"Key: %@ => %d", key, (int)[line numPoints]);
        [routeDict setObject:line forKey:key];
    }
    
    for (int i = 0; i < stopNodeArray.count; ++i) {
        for (int j = 0; j < stopNodeArray.count; ++j) {
            if (i == j) continue;
            MRSuperNode *stopNode1 = stopNodeArray[i];
            MRSuperNode *stopNode2 = stopNodeArray[j];
            AGSPolyline *line = [routeNetwork getShorestPathFrom:stopNode1.pos To:stopNode2.pos];
            NSString *key = [NSString stringWithFormat:@"%d-%d", stopNode1.nodeID, stopNode2.nodeID];
            NSLog(@"Key: %@ => %d", key, (int)[line numPoints]);
            [routeDict setObject:line forKey:key];
        }
    }
    
    MRMultiRouteCaculator *c = [[MRMultiRouteCaculator alloc] initWithRouteParam:routeParam Dict:routeDict];
    AGSPolyline *routeResult = [c calculate];
//    [mLayers showRoute:routeResult WithStart:startPoint End:endPoint];
    [mLayers showRouteCollections:[c getRouteCollection] WithStart:startPoint End:endPoint];

//    int integers[] = {1, 2, 3, 4};
//    [self fullArray:integers cursor:0 end:3];
//    fullArray(integers, 0, 3);
    
    NSDate *endDate = [NSDate date];
    NSLog(@"处理用时：%f", [endDate timeIntervalSinceDate:now]);
}

- (void)swap:(int [])array cursor:(int)cursor index:(int)i
{
    int temp = array[cursor];
    array[cursor] = array[i];
    array[i] = temp;
}

- (void)fullArray:(int [])array cursor:(int)cursor end:(int)end
{
    if (cursor == end) {
        printf("%d, %d, %d, %d\n", array[0], array[1], array[2], array[3]);
    } else {
        for (int i = cursor; i <= end; i++) {
            swap(array, cursor, i);
            fullArray(array, cursor + 1, end);
            swap(array, cursor, i);
        }
    }
}

//- (void)fullArray:(NSMutableArray *)array WithCursor:(int)cursor End:(int)end
//{
//    if (cursor == end) {
//        index++;
////        NSLog(@"array %d: %@", index, array);
//        NSLog(@"array %d: [%@, %@, %@, %@]", index, array[0], array[1], array[2], array[3]);
//    } else {
//        for (int i = cursor; i <= end; ++i) {
//            stopArray = [self swapArray:stopArray WithCursor:i Index:end];
//            [self fullArray:stopArray WithCursor:cursor + 1 End:end];
//            stopArray = [self swapArray:stopArray WithCursor:i Index:end];
//        }
//    }
//}

//- (NSMutableArray *)swapArray:(NSMutableArray *)array WithCursor:(int)cursor Index:(int)index
//{
//    id obj = array[cursor];
//
//    NSMutableArray *newArray = [array mutableCopy];
//    newArray[cursor] = newArray[index];
//    newArray[index] = obj;
//
//    return newArray;
//}

//- (void)testMultiRoute
//{
//    [mLayers showMultiRouteParams:routeParam];
//    //    [self requestRouteWithStart:routeParam.startPoint End:routeParam.endPoint];
//
//    NSDate *now = [NSDate date];
//
//    NSMutableArray *superLinkArray = [NSMutableArray array];
//    NSDictionary *dict = [routeParam getCombinations];
////    NSLog(@"%@", dict);
//    NSString *name = nil;
//    {
//        name = @"start";
//        NSArray *starts = dict[name];
//
//        NSMutableArray *lineArray = [NSMutableArray array];
//        for (int i = 0; i < starts.count; ++i) {
//            NSArray<MRSuperNode *> *nodes = starts[i];
//            MRSuperNode *startNode = nodes[0];
//            MRSuperNode *middleNode = nodes[1];
//            AGSPolyline *line = [routeNetwork getShorestPathFrom:startNode.pos To:middleNode.pos];
//            [lineArray addObject:line];
//
//            MRSuperLink *superLink = [[MRSuperLink alloc] initWithLinkID:startNode.nodeID * 100 + middleNode.nodeID];
//            superLink.currentNodeID = startNode.nodeID;
//            superLink.nextNodeID = middleNode.nodeID;
//            superLink.line = line;
//            superLink.length = [geometryEngine lengthOfGeometry:line];
//
//            [startNode addLink:superLink];
//            superLink.nextNode = middleNode;
//
//            [superLinkArray addObject:superLink];
//        }
//        [mLayers showCombinations:lineArray withName:name];
//    }
//
//    {
//        name = @"end";
//        NSArray *ends = dict[name];
//
//        NSMutableArray *lineArray = [NSMutableArray array];
//        for (int i = 0; i < ends.count; ++i) {
//            NSArray<MRSuperNode *> *nodes = ends[i];
//            MRSuperNode *middleNode = nodes[0];
//            MRSuperNode *endNode = nodes[1];
//            AGSPolyline *line = [routeNetwork getShorestPathFrom:middleNode.pos To:endNode.pos];
//            [lineArray addObject:line];
//
//            MRSuperLink *superLink = [[MRSuperLink alloc] initWithLinkID:middleNode.nodeID * 100 + endNode.nodeID];
//            superLink.currentNodeID = middleNode.nodeID;
//            superLink.nextNodeID = endNode.nodeID;
//            superLink.line = line;
//            superLink.length = [geometryEngine lengthOfGeometry:line];
//
//            [middleNode addLink:superLink];
//            superLink.nextNode = endNode;
//
//            [superLinkArray addObject:superLink];
//        }
//        [mLayers showCombinations:lineArray withName:name];
//    }
//
//    {
//        name = @"stops";
//        NSArray *stops = dict[name];
//
//        NSMutableArray *lineArray = [NSMutableArray array];
//        for (int i = 0; i < stops.count; ++i) {
//            NSArray<MRSuperNode *> *nodes = stops[i];
//            MRSuperNode *stop1Node = nodes[0];
//            MRSuperNode *stop2Node = nodes[1];
//            AGSPolyline *line = [routeNetwork getShorestPathFrom:stop1Node.pos To:stop2Node.pos];
//            [lineArray addObject:line];
//
//            MRSuperLink *superLink = [[MRSuperLink alloc] initWithLinkID:stop1Node.nodeID * 100 + stop2Node.nodeID];
//            superLink.currentNodeID = stop1Node.nodeID;
//            superLink.nextNodeID = stop2Node.nodeID;
//            superLink.line = line;
//            superLink.length = [geometryEngine lengthOfGeometry:line];
//
//            [stop1Node addLink:superLink];
//            superLink.nextNode = stop2Node;
//
//            [superLinkArray addObject:superLink];
//        }
//        [mLayers showCombinations:lineArray withName:name];
//    }
//
//    MRSuperRouteNetworkDataset *superDataset = [[MRSuperRouteNetworkDataset alloc] initWithNodes:routeParam.getSuperNodes Links:superLinkArray];
//    NSLog(@"SuperDataset: %@", superDataset);
//    AGSPolyline *line = [superDataset getShorestPathFrom:[routeParam getStartNode] To:[routeParam getEndNode]];
//    NSLog(@"MultiRoute: %@", line);
//    [mLayers showRoute:line WithStart:startPoint End:endPoint];
//
//    NSDate *endDate = [NSDate date];
//    NSLog(@"处理用时：%f", [endDate timeIntervalSinceDate:now]);
//}

- (void)generateRandomParams:(int)num
{
    routeParam = [[MRParams alloc] init];
    routeParam.startPoint = [self getRandomPoint];
    routeParam.endPoint = [self getRandomPoint];
    
    for (int i = 0; i < num; ++i) {
        [routeParam addStop:[self getRandomPoint]];
    }
}

- (void)generateTestParams
{
    NSArray *indexArray = @[@162, @14, @186, @90, @184, @88];
    [routeNetwork.nodeArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        TYNode *n1 = obj1;
        TYNode *n2 = obj2;
        return n1.pos.x > n2.pos.x;
    }];
    
    [routeNetwork.nodeArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        TYNode *n1 = obj1;
        TYNode *n2 = obj2;
        return n1.pos.y > n2.pos.y;
    }];
    
    NSMutableArray *posArray = [NSMutableArray array];
    for (int i = 0; i < indexArray.count; ++i) {
        TYNode *node = routeNetwork.nodeArray[[indexArray[i] intValue]];
        [posArray addObject:[AGSPoint pointWithX:node.pos.x y:node.pos.y spatialReference:node.pos.spatialReference]];
    }
    
    routeParam = [[MRParams alloc] init];
    
    routeParam.startPoint = posArray[0];
    routeParam.endPoint = posArray[1];
    
    for (int i = 2; i < posArray.count; ++i) {
        [routeParam addStop:posArray[i]];
    }
}

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    NSLog(@"%@", mappoint);
    NSLog(@"X: %f", mappoint.x);
}

- (void)requestRouteWithStart:(AGSPoint *)s End:(AGSPoint *)e
{
    NSDate *now = [NSDate date];
    AGSPolyline *line = [routeNetwork getShorestPathFrom:s To:e];
    NSDate *endDate = [NSDate date];
    NSLog(@"导航用时：%f", [endDate timeIntervalSinceDate:now]);
    
    [mLayers showRoute:line WithStart:s End:e];
}

- (AGSPoint *)getRandomPoint
{
    int randomIndex = (int)arc4random()%routeNetwork.nodeArray.count;
    while ([randomSet containsObject:@(randomIndex)]) {
        randomIndex = (int)arc4random()%routeNetwork.nodeArray.count;
    }
    [randomSet addObject:@(randomIndex)];
    NSLog(@"RandomIndex: %d", randomIndex);
    
    TYNode *randomNode = routeNetwork.nodeArray[randomIndex];
    return  [AGSPoint pointWithX:randomNode.pos.x + arc4random() % 5 y:randomNode.pos.y + arc4random()%5 spatialReference:randomNode.pos.spatialReference];
}

@end

