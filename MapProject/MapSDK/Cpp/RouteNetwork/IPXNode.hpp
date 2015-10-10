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
            
            IPXNode(int nodeID, bool isVir);
            ~IPXNode();
            
            void addLink(IPXLink *link);
            void removeLink(IPXLink *link);
            void reset();
            
            geos::geom::Point *getPos() const;
            void setPos(geos::geom::Point *p);
            
        private:
            int m_nodeID;
            bool m_isVirtual;
            
            std::vector<IPXLink *> m_adjacencies;
            geos::geom::Point *m_pos;
            
            
        };
        
        
    }
}
#endif /* IPXNode_hpp */
