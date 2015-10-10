//
//  IPXRouteNetworkDBAdapter.hpp
//  MapProject
//
//  Created by innerpeacer on 15/10/11.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#ifndef IPXRouteNetworkDBAdapter_hpp
#define IPXRouteNetworkDBAdapter_hpp

#include <stdio.h>
#include <vector>

#include "IPXLinkRecord.hpp"
#include "IPXNodeRecord.hpp"
#include "IPXRouteNetworkDataset.hpp"

namespace Innerpeacer {
    namespace MapSDK {
     
        class IPXRouteNetworkDBAdapter {
            
        public:
            IPXRouteNetworkDBAdapter(std::string dbPath);
            
            bool open();
            bool close();
            
            IPXRouteNetworkDataset *readRouteNetworkDataset();
            
            
        private:
            std::vector<IPXLinkRecord> getLinks();
            std::vector<IPXNodeRecord> getNodes();
        };
        
    }
}

#endif /* IPXRouteNetworkDBAdapter_hpp */
