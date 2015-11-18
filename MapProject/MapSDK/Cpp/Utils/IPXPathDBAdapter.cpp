//
//  IPXPathDBAdapter.cpp
//  MapProject
//
//  Created by innerpeacer on 15/11/18.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#include "IPXPathDBAdapter.hpp"

using namespace Innerpeacer::MapSDK;
using namespace std;

#include <geos/io.h>
#include <sstream>

void IPXPathDBAdapter::readPathData()
{
    paths.clear();
    
    sqlite3_stmt *stmt = NULL;
    string sql = "select GEOMETRY from path";
    stringstream s;
    WKBReader reader;
    
    int ret = sqlite3_prepare_v2(m_database, sql.c_str(), (int)sql.length(), &stmt, NULL);
    if (ret == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            s.clear();
            s.write((const char *)sqlite3_column_blob(stmt, 0), sqlite3_column_bytes(stmt, 0));
            geos::geom::LineString *path = dynamic_cast<geos::geom::LineString *>(reader.read(s));
            paths.push_back(path);
        }
    }
    sqlite3_finalize(stmt);
}

std::vector<geos::geom::LineString *> IPXPathDBAdapter::getAllPaths() const
{
    return paths;
}

IPXPathDBAdapter::~IPXPathDBAdapter()
{
    std::vector<geos::geom::LineString *>::iterator iter;
    for (iter = paths.begin(); iter != paths.end(); ++iter) {
        delete (*iter);
    }
}


IPXPathDBAdapter::IPXPathDBAdapter(const char *dbPath)
{
    m_path = dbPath;
}

bool IPXPathDBAdapter::open()
{
    int ret = sqlite3_open(m_path.c_str(), &m_database);
    if (ret == SQLITE_OK) {
        //        printf("open sucesss: %s\n", m_path.c_str());
        return true;
    }
    //    printf("open failed: %s\n", m_path.c_str());
    return false;
}

bool IPXPathDBAdapter::close()
{
    //    printf("IPXRouteNetworkDBAdapter::close()\n");
    return (sqlite3_close(m_database) == SQLITE_OK);
}