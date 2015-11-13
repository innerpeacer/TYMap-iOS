//
//  IPXFeatureRecord.cpp
//  MapProject
//
//  Created by innerpeacer on 15/10/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#include "IPXFeatureRecord.hpp"

using namespace Innerpeacer::MapSDK;

geos::geom::Point *IPXFeatureRecord::getPointIfSatisfied() const
{
    if (geometry != NULL && geometry->getGeometryTypeId() == GEOS_POINT) {
        return dynamic_cast<geos::geom::Point *>(geometry);
    }
    return NULL;
}

geos::geom::MultiPoint *IPXFeatureRecord::getMultiPointIfSatisfied() const
{
    if (geometry != NULL && geometry->getGeometryTypeId() == GEOS_MULTIPOINT) {
        return dynamic_cast<geos::geom::MultiPoint *>(geometry);
    }
    return NULL;
}

geos::geom::LineString *IPXFeatureRecord::getLineStringIfSatisfied() const
{
    if (geometry != NULL && geometry->getGeometryTypeId() == GEOS_LINESTRING) {
        return dynamic_cast<geos::geom::LineString *>(geometry);
    }
    return NULL;
}

geos::geom::MultiLineString *IPXFeatureRecord::getMultiLineStringIfSatisfied() const
{
    if (geometry != NULL && geometry->getGeometryTypeId() == GEOS_MULTILINESTRING) {
        return dynamic_cast<geos::geom::MultiLineString *>(geometry);
    }
    return NULL;
}

geos::geom::Polygon *IPXFeatureRecord::getPolygonIfSatisfied() const
{
    if (geometry != NULL && geometry->getGeometryTypeId() == GEOS_POLYGON) {
        return dynamic_cast<geos::geom::Polygon *>(geometry);
    }
    return NULL;
}

geos::geom::MultiPolygon *IPXFeatureRecord::getMultiPolygonIfSatisfied() const
{
    if (geometry != NULL && geometry->getGeometryTypeId() == GEOS_MULTIPOLYGON) {
        return dynamic_cast<geos::geom::MultiPolygon *>(geometry);
    }
    return NULL;
}

const geos::geom::Point *Innerpeacer::MapSDK::getPointN(geos::geom::MultiPoint *mp, std::size_t n)
{
    if (mp == NULL) {
        return NULL;
    }
    return dynamic_cast<const geos::geom::Point *>(mp->getGeometryN(n));
}

const geos::geom::LineString *Innerpeacer::MapSDK::getLineStringN(geos::geom::MultiLineString *ml, std::size_t n)
{
    if (ml == NULL) {
        return NULL;
    }
    return dynamic_cast<const geos::geom::LineString *>(ml->getGeometryN(n));
}

const geos::geom::Polygon *Innerpeacer::MapSDK::getPolygonN(geos::geom::MultiPolygon *mp, std::size_t n)
{
    if (mp == NULL) {
        return NULL;
    }
    return dynamic_cast<const geos::geom::Polygon *>(mp->getGeometryN(n));
}