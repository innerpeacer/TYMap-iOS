//
//  IPXFeatureRecord.hpp
//  MapProject
//
//  Created by innerpeacer on 15/10/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#ifndef IPXFeatureRecord_hpp
#define IPXFeatureRecord_hpp

#include <stdio.h>
#include <geos/geom.h>

namespace Innerpeacer {
    namespace MapSDK {
        
        typedef enum {
            LAYER_FLOOR = 1,
            LAYER_ROOM = 2,
            LAYER_ASSET = 3,
            LAYER_FACILITY = 4,
            LAYER_LABEL = 5
            
        } MapLayer;
        
        const geos::geom::Point *getPointN(geos::geom::MultiPoint *mp, std::size_t n);
        const geos::geom::LineString *getLineStringN(geos::geom::MultiLineString *ml, std::size_t n);
        const geos::geom::Polygon *getPolygonN(geos::geom::MultiPolygon *mp, std::size_t n);

        class IPXFeatureRecord {
        public:
            geos::geom::Geometry *geometry;
            
            geos::geom::Point *getPointIfSatisfied() const;
            geos::geom::MultiPoint *getMultiPointIfSatisfied() const;
            geos::geom::LineString *getLineStringIfSatisfied() const;
            geos::geom::MultiLineString *getMultiLineStringIfSatisfied() const;
            geos::geom::Polygon *getPolygonIfSatisfied() const;
            geos::geom::MultiPolygon *getMultiPolygonIfSatisfied() const;
            
            
            std::string geoID;
            std::string poiID;
            std::string categoryID;
            std::string name;
            int symbolID;
            int floorNumber;
            int layer;
            
            IPXFeatureRecord() {
                geometry = NULL;
            }
            
            ~IPXFeatureRecord() {
                if (geometry) {
                   delete geometry;
                    geometry = NULL;
                }
            }
        };
    }
}

#endif /* IPXFeatureRecord_hpp */
