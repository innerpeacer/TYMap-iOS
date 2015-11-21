//
//  IPXPathCalibration.hpp
//  MapProject
//
//  Created by innerpeacer on 15/11/19.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#ifndef IPXPathCalibration_hpp
#define IPXPathCalibration_hpp

#include <stdio.h>
#include <vector>
#include <geos.h>

using namespace std;
using namespace geos;
using namespace geos::geom;

namespace Innerpeacer {
    namespace MapSDK {
        
        class IPXPathCalibration {
        public:
            IPXPathCalibration(const char *dbPath);
            ~IPXPathCalibration();
            
            void setBufferWidth(double w);
            geos::geom::Coordinate calibratePoint(geos::geom::Coordinate c);
            int getPathCount() const;
            
            geos::geom::Geometry *getUnionPaths() const;
            geos::geom::Geometry *getUnionPathBuffer() const;


        private:
            geos::geom::Point *createPoint(double x, double y);
            geos::geom::Point *snapToPath(Geometry *line, geos::geom::Point *point);
            geos::geom::Geometry *createBufferedUnionGeometry();
            
        private:
            GeometryFactory *factory;
            Geometry *unionPaths;
            Geometry *unionPathsBuffer;
            std::vector<geos::geom::Geometry *> paths;
            
            double bufferWidth;
            int pathCount;
        };
        
    }
}

#endif /* IPXPathCalibration_hpp */
