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
            ~IPXRouteNetworkDataset();
            geos::geom::LineString *getShorestPath(geos::geom::Point start, geos::geom::Point end);
            std::string toString() const;
            
        private:
            void extractNodes(std::vector<IPXNodeRecord> &nodes);
            void extractLinks(std::vector<IPXLinkRecord> &links);
            void processNodesAndLinks();
            
            void computePaths(IPXNode *source);
            geos::geom::LineString *getShorestPathToNode(IPXNode *target);
            void reset();
            
            IPXNode *processTempNodeForStart(geos::geom::Point startPoint);
            IPXNode *processTempNodeForEnd(geos::geom::Point endPoint);
            void resetTempNodeForStart();
            void resetTempNodeForEnd();
            IPXNode getTempNode(geos::geom::Point point);
            std::vector<IPXLink *>getTempLinks(geos::geom::Point point);
                        
        private:
            std::vector<IPXLink *> m_linkArray;
            std::vector<IPXLink *> m_virtualLinkArray;
            std::vector<IPXNode *> m_nodeArray;
            std::vector<IPXNode *> m_virtualNodeArray;
            
            std::unordered_map<std::string, IPXLink *> m_allLinkDict;
            std::unordered_map<int, IPXNode *> m_allNodeDict;
            
            geos::geom::MultiLineString *m_unionLine;
            
        private:
//            GeometryEngine *engine;
            std::vector<IPXNode *> m_tempStartNodeArray;
            std::vector<IPXLink *> m_tempStartLinkArray;
            std::vector<IPXLink *> m_replacedStartLinkArray;
            
            std::vector<IPXNode *> m_tempEndNodeArray;
            std::vector<IPXLink *> m_tempEndLinkArray;
            std::vector<IPXLink *> m_replacedEndLinkArray;
            
            int m_tempNodeID;
            int m_tempLinkID;
        };
    }
}


#endif /* IPXRouteNetworkDataset_hpp */
