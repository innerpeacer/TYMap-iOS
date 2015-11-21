////
////  IPXPathCalibration.cpp
////  MapProject
////
////  Created by innerpeacer on 15/11/19.
////  Copyright © 2015年 innerpeacer. All rights reserved.
////
//
#include "IPXPathCalibration.hpp"
#include "IPXPathDBAdapter.hpp"

#include <geos/operation/union/CascadedUnion.h>
#include <geos/operation/union/CascadedPolygonUnion.h>
#include <geos/opBuffer.h>
#include <geos/geom/prep/PreparedPolygon.h>
#include <geos/operation/distance/DistanceOp.h>

using namespace geos::operation::geounion;
using namespace geos::operation::buffer;
using namespace geos::geom::prep;
using namespace geos::operation::distance;

#define DEFAULT_BUFFER_WIDTH 2.0

using namespace Innerpeacer::MapSDK;


bool geometryContains(geos::geom::Geometry *geometry1, geos::geom::Geometry *geometry2)
{
    PreparedPolygon polygon1(geometry1);
    return polygon1.contains(geometry2);
}

geos::geom::Point *IPXPathCalibration::snapToPath(Geometry *line, geos::geom::Point *point)
{
    CoordinateSequence *sequences = DistanceOp::nearestPoints(line, point);
    Point *resultPoint = NULL;
    if (sequences->size() > 0) {
        resultPoint = this->createPoint(sequences->front().x, sequences->front().y);
    }
    delete sequences;
    return resultPoint;
}

geos::geom::Point *IPXPathCalibration::createPoint(double x, double y)
{
    Coordinate c;
    c.x = x;
    c.y = y;
    return factory->createPoint(c);
}

IPXPathCalibration::IPXPathCalibration(const char *dbPath)
{
    IPXPathDBAdapter *db = new IPXPathDBAdapter(dbPath);
    db->open();
    db->readPathData();
    std::vector<geos::geom::LineString *> pathsFromDB = db->getAllPaths();
    db->close();
    
    paths.insert(paths.end(), pathsFromDB.begin(), pathsFromDB.end());
    pathCount = (int)paths.size();
    bufferWidth = DEFAULT_BUFFER_WIDTH;
    
    unionPaths = CascadedUnion::Union(&paths);
    unionPathsBuffer = createBufferedUnionGeometry();
    factory = new GeometryFactory();
}

IPXPathCalibration::~IPXPathCalibration()
{
    std::vector<geos::geom::Geometry *>::iterator iter;
    for (iter = paths.begin(); iter != paths.end(); ++iter) {
        delete (*iter);
    }
    
    if (unionPaths) {
        delete unionPaths;
    }
    
    if (unionPathsBuffer) {
        delete unionPathsBuffer;
    }
    
    if (factory) {
        delete factory;
    }
}

void IPXPathCalibration::setBufferWidth(double w)
{
    
    if (unionPathsBuffer) {
        delete unionPathsBuffer;
    }
    bufferWidth = w;
    unionPathsBuffer = createBufferedUnionGeometry();
}

geos::geom::Geometry *IPXPathCalibration::createBufferedUnionGeometry()
{
//    std::vector<Polygon *> pathBufferVector;
//    for (int i = 0; i < paths.size(); ++i) {
//        LineString *ls = dynamic_cast<LineString *>(paths.at(i));
//        Polygon *polygon = dynamic_cast<Polygon *>(BufferOp::bufferOp(ls, bufferWidth));
//        pathBufferVector.push_back(polygon);
//    }
//    
//    geos::geom::Geometry *result = geos::operation::geounion::CascadedPolygonUnion::Union(&pathBufferVector);
//    
//    for (int i = 0; i < pathBufferVector.size(); ++i) {
//        Polygon *polygon = pathBufferVector.at(i);
//        delete polygon;
//    }
//    return result;
    
    std::vector<Polygon *> pathBufferVector;
    for (int i = 0; i < paths.size(); ++i) {
        LineString *ls = dynamic_cast<LineString *>(paths.at(i));
        Polygon *polygon = dynamic_cast<Polygon *>(BufferOp::bufferOp(ls, bufferWidth));
        pathBufferVector.push_back(polygon);
    }
    
    geos::geom::Geometry *result = geos::operation::geounion::CascadedPolygonUnion::Union(&pathBufferVector);
    
    for (int i = 0; i < pathBufferVector.size(); ++i) {
        Polygon *polygon = pathBufferVector.at(i);
        delete polygon;
    }
    return result;
}

geos::geom::Coordinate IPXPathCalibration::calibratePoint(geos::geom::Coordinate c)
{
    Coordinate resultCoordinate(c);
    
    geos::geom::Point *originalPoint = factory->createPoint(c);
    if (geometryContains(unionPathsBuffer, originalPoint)) {
        geos::geom::Point *snappedPoint = this->snapToPath(unionPaths, originalPoint);
        resultCoordinate.x = snappedPoint->getX();
        resultCoordinate.y = snappedPoint->getY();
        delete snappedPoint;
    }
    delete originalPoint;
    return resultCoordinate;
}

int IPXPathCalibration::getPathCount() const
{
    return pathCount;
}

geos::geom::Geometry *IPXPathCalibration::getUnionPaths() const
{
    return unionPaths;
}

geos::geom::Geometry *IPXPathCalibration::getUnionPathBuffer() const
{
    return unionPathsBuffer;
}

