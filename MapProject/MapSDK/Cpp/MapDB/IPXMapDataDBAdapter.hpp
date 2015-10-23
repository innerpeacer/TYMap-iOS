//
//  IPXMapDataDBAdapter.hpp
//  MapProject
//
//  Created by innerpeacer on 15/10/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#ifndef IPXMapDataDBAdapter_hpp
#define IPXMapDataDBAdapter_hpp

#include <stdio.h>
#include <vector>
#include <sqlite3.h>

#include "IPXFeatureRecord.hpp"

namespace Innerpeacer {
    namespace MapSDK {
        
        class IPXMapDataDBAdapter {
        public:
            IPXMapDataDBAdapter(const char *dbPath);
            bool open();
            bool close();
            
//            std::vector<IPXFeatureRecord> getAllRecords();
            std::vector<IPXFeatureRecord *> getAllRecordsOnFloor(int floor);
//            std::vector<IPXFeatureRecord> getAllRecordsInLayer(MapLayer layer);
//            std::vector<IPXFeatureRecord> getAllRecordsOnFloorInLayer(int floor, MapLayer layer);
            
        private:
            std::string m_path;
            sqlite3 *m_database;
        };
    }
}

#endif /* IPXMapDataDBAdapter_hpp */
