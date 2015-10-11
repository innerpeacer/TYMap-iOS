//
//  IPXLink.hpp
//  MapProject
//
//  Created by innerpeacer on 15/10/11.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#ifndef IPXLink_hpp
#define IPXLink_hpp

#include <stdio.h>

#include <geos/geom.h>

namespace Innerpeacer {
    namespace MapSDK {
        
        class IPXNode;
        
        class IPXLink {
            
        public:
            int currentNodeID;
            int nextNodeID;
            IPXNode *nextNode;
            double length;
            
            IPXLink(int linkID, bool isVir);
            ~IPXLink();
            
            int getLinkID() const;
            bool isVirtual() const;
            geos::geom::LineString *getLine() const;
            void setLine(geos::geom::LineString *line);
            
            std::string toString() const;
            
        private:
            int m_linkID;
            bool m_isVirtual;
            geos::geom::LineString *m_line;
        };
        
    }
}

#endif /* IPXLink_hpp */
