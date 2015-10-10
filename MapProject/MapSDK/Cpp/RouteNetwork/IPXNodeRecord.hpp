//
//  IPXNodeRecord.hpp
//  MapProject
//
//  Created by innerpeacer on 15/10/11.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#ifndef IPXNodeRecord_hpp
#define IPXNodeRecord_hpp

#include <stdio.h>
#include <geos/geom.h>

namespace Innerpeacer {
    namespace MapSDK {
        
        struct IPXNodeRecord {
            int nodeID;
            geos::geom::Point *pos;
            bool isVirtua;
        };
    }
}

#endif /* IPXNodeRecord_hpp */
