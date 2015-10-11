//
//  IPXNode.hpp
//  MapProject
//
//  Created by innerpeacer on 15/10/11.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#ifndef IPXNode_hpp
#define IPXNode_hpp

#include <stdio.h>
#include <vector>
#include <geos/geom.h>


namespace Innerpeacer {
    namespace MapSDK {
        
        class IPXLink;
        
        class IPXNode {
            
        public:
            double minDistance;
            IPXNode *previousNode;
            
            std::vector<IPXLink *> adjacencies;

            IPXNode(int nodeID, bool isVir);
            ~IPXNode();
            
            void addLink(IPXLink *link);
            void removeLink(IPXLink *link);
            void reset();
            
            int getNodeID() const;
            geos::geom::Point *getPos() const;
            void setPos(geos::geom::Point *p);
            
            std::string toString() const;

        private:
            int m_nodeID;
            bool m_isVirtual;
            
            geos::geom::Point *m_pos;
        };
        
        
    }
}
#endif /* IPXNode_hpp */
