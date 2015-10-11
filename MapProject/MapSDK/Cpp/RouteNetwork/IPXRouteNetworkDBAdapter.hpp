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
#include <sqlite3.h>

#include "IPXLinkRecord.hpp"
#include "IPXNodeRecord.hpp"
#include "IPXRouteNetworkDataset.hpp"

namespace Innerpeacer {
    namespace MapSDK {
     
        class IPXRouteNetworkDBAdapter {
            
        public:
            IPXRouteNetworkDBAdapter(const char *dbPath);
            
            bool open();
            bool close();
            
            IPXRouteNetworkDataset *readRouteNetworkDataset();
            
            
        private:
            std::vector<IPXLinkRecord> getLinks();
            std::vector<IPXNodeRecord> getNodes();
            
            std::string m_path;
            sqlite3 *m_database;
        };
        
    }
}

#endif /* IPXRouteNetworkDBAdapter_hpp */
