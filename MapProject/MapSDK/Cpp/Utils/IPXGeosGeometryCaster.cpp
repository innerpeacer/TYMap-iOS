//
//  IPXGeosGeometryCaster.cpp
//  MapProject
//
//  Created by innerpeacer on 15/11/20.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#include "IPXGeosGeometryCaster.hpp"

using namespace Innerpeacer::MapSDK::GeosGeometryCaster;

using namespace std;
using namespace geos;
using namespace geos::geom;

geos::geom::Point *Innerpeacer::MapSDK::GeosGeometryCaster::CastedPoint(geos::geom::Geometry *g)
{
    return dynamic_cast<Point *>(g);
}

geos::geom::MultiPoint *Innerpeacer::MapSDK::GeosGeometryCaster::CastedMultiPoint(geos::geom::Geometry *g)
{
    return dynamic_cast<MultiPoint *>(g);
}

geos::geom::LineString *Innerpeacer::MapSDK::GeosGeometryCaster::CastedLineString(geos::geom::Geometry *g)
{
    return dynamic_cast<LineString *>(g);
}

geos::geom::MultiLineString *Innerpeacer::MapSDK::GeosGeometryCaster::CastedMultiLineString(geos::geom::Geometry *g)
{
    return dynamic_cast<MultiLineString *>(g);
}

geos::geom::Polygon *Innerpeacer::MapSDK::GeosGeometryCaster::CastedPolygon(geos::geom::Geometry *g)
{
    return dynamic_cast<Polygon *>(g);
}

geos::geom::MultiPolygon *Innerpeacer::MapSDK::GeosGeometryCaster::CastedMultiPolygon(geos::geom::Geometry *g)
{
    return dynamic_cast<MultiPolygon *>(g);
}
