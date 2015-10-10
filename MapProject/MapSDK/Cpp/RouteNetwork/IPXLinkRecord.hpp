//
//  IPXLinkRecord.hpp
//  MapProject
//
//  Created by innerpeacer on 15/10/11.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#ifndef IPXLinkRecord_hpp
#define IPXLinkRecord_hpp

#include <stdio.h>
#include <geos/geom.h>

namespace Innerpeacer {
    namespace MapSDK {
        
        struct IPXLinkRecord {
            int linkID;
            geos::geom::LineString *line;
            double length;
            int headNode;
            int endNode;
            bool isVirtual;
            bool isOneWay;
        };
        
    }
}

#endif /* IPXLinkRecord_hpp */
