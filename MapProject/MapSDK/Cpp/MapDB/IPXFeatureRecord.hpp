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
        
        class IPXFeatureRecord {
        public:
            geos::geom::Geometry *geometry;
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
