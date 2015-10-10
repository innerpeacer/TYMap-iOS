//
//  IPXRouteNetworkDataset.hpp
//  MapProject
//
//  Created by innerpeacer on 15/10/11.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#ifndef IPXRouteNetworkDataset_hpp
#define IPXRouteNetworkDataset_hpp

#include <stdio.h>
#include <vector>
#include <unordered_map>

#include <geos/geom.h>

#include "IPXLink.hpp"
#include "IPXNode.hpp"
#include "IPXLinkRecord.hpp"
#include "IPXNodeRecord.hpp"
namespace Innerpeacer {
    namespace MapSDK {
        
        class IPXRouteNetworkDataset {
        public:
            IPXRouteNetworkDataset(std::vector<IPXNodeRecord> &nodes, std::vector<IPXLinkRecord> &links);
            geos::geom::LineString *getShorestPath(geos::geom::Point start, geos::geom::Point end);
            
        private:
            std::vector<IPXLink *> m_linkArray;
            std::vector<IPXLink *> m_virtualLinkArray;
            std::vector<IPXNode *> m_nodeArray;
            std::vector<IPXNode *> m_virtualNodeArray;
            
            std::unordered_map<std::string, IPXLink *> m_allLinkDict;
            std::unordered_map<int, IPXNode *> m_allNodeDict;
            
            
            geos::geom::MultiLineString *m_unionLine;
        };
    }
}


#endif /* IPXRouteNetworkDataset_hpp */
