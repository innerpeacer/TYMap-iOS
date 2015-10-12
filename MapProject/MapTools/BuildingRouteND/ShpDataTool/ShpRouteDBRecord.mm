//
//  ShpRouteDBRecord.m
//  MapProject
//
//  Created by innerpeacer on 15/9/29.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "ShpRouteDBRecord.h"
#import "Geos2AgsConverter.h"

#include <geos.h>
#include <geos/geom.h>
#import <sstream>

using namespace std;

@interface ShpRouteDBRecord()
{
    geos::geom::Geometry *geosGeometry;
}

@end

@implementation ShpRouteDBRecord

- (geos::geom::Geometry *)getGeosGeometry
{
    if (geosGeometry == NULL) {
        WKBReader reader;
        stringstream s;
        s.clear();
        s.write((const char *)[_geometryData bytes], [_geometryData length]);
        geosGeometry = reader.read(s);
    }
    return geosGeometry;
}

- (AGSGeometry *)getAgsGeometry
{
    AGSGeometry *agsGeometry = [Geos2AgsConverter agsgeometryFromGeosGeometry:[self getGeosGeometry]];
    return agsGeometry;
}

- (void)dealloc
{
    if (geosGeometry == NULL) {
        delete geosGeometry;
    }
}


@end
