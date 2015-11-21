//
//  IPXPathDBAdapter.hpp
//  MapProject
//
//  Created by innerpeacer on 15/11/18.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#ifndef IPXPathDBAdapter_hpp
#define IPXPathDBAdapter_hpp

#include <stdio.h>
#include <vector>
#include <sqlite3.h>
#include <string>
#include <geos.h>

namespace Innerpeacer {
    namespace MapSDK {
        
        class IPXPathDBAdapter {
        public:
            IPXPathDBAdapter(const char *dbPath);
            ~IPXPathDBAdapter();
            
            bool open();
            bool close();
            
            void readPathData();
            std::vector<geos::geom::LineString *> getAllPaths() const;
            
        private:
            std::vector<geos::geom::LineString *> paths;
            
            std::string m_path;
            sqlite3 *m_database;
        };
        
    }
}

#endif /* IPXPathDBAdapter_hpp */
