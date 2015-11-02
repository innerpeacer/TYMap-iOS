//
//  IPXRouteNetworkDBAdapter.cpp
//  MapProject
//
//  Created by innerpeacer on 15/10/11.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#include "IPXRouteNetworkDBAdapter.hpp"

using namespace Innerpeacer::MapSDK;
using namespace std;

#include <geos/geom.h>
#include <geos/io.h>
#include <sstream>

IPXRouteNetworkDBAdapter::IPXRouteNetworkDBAdapter(const char *dbPath)
{
    m_path = dbPath;
}

IPXRouteNetworkDataset *IPXRouteNetworkDBAdapter::readRouteNetworkDataset()
{
//    printf("IPXRouteNetworkDBAdapter::readRouteNetworkDataset()\n");
    std::vector<IPXLinkRecord> linkRecords = getLinks();
    std::vector<IPXNodeRecord> nodeRecords = getNodes();
    return new IPXRouteNetworkDataset(nodeRecords, linkRecords);
}

std::vector<IPXLinkRecord> IPXRouteNetworkDBAdapter::getLinks()
{
//    printf("IPXRouteNetworkDBAdapter::getLinks()\n");
    
    std::vector<IPXLinkRecord> linkRecordArray;
    
    sqlite3_stmt *stmt = NULL;
    string sql = "select linkID, Geometry, length, headNode, endNode, virtual, oneWay from RouteLink";
    stringstream s;
    WKBReader reader;
    int ret = sqlite3_prepare_v2(m_database, sql.c_str(), (int)sql.length(), &stmt, NULL);
    if (ret == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            IPXLinkRecord record;
            
            record.linkID = sqlite3_column_int(stmt, 0);
            s.clear();
            s.write((const char *)sqlite3_column_blob(stmt, 1), sqlite3_column_bytes(stmt, 1));
            record.line = dynamic_cast<LineString *>(reader.read(s));
            record.length = sqlite3_column_double(stmt, 2);
            record.headNode = sqlite3_column_int(stmt, 3);
            record.endNode = sqlite3_column_int(stmt, 4);
            record.isVirtual = sqlite3_column_int(stmt, 5);
            record.isOneWay = sqlite3_column_int(stmt, 6);
            
            linkRecordArray.push_back(record);
        }
    }
//    printf("%d links in route database\n", (int)linkRecordArray.size());
    sqlite3_finalize(stmt);

    return linkRecordArray;
}

std::vector<IPXNodeRecord> IPXRouteNetworkDBAdapter::getNodes()
{
//    printf("IPXRouteNetworkDBAdapter::getNodes()\n");

    std::vector<IPXNodeRecord> nodeRecordArray;
    
    sqlite3_stmt *stmt = NULL;
    string sql = "select nodeID, Geometry, virtual from RouteNode";
    stringstream s;
    WKBReader reader;
    int ret = sqlite3_prepare_v2(m_database, sql.c_str(), (int)sql.length(), &stmt, NULL);
    if (ret == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            IPXNodeRecord record;
            
            record.nodeID = sqlite3_column_int(stmt, 0);
            s.clear();
            s.write((const char *)sqlite3_column_blob(stmt, 1), sqlite3_column_bytes(stmt, 1));
            record.pos = dynamic_cast<geos::geom::Point *>(reader.read(s));
            record.isVirtual = sqlite3_column_int(stmt, 2);
            
            nodeRecordArray.push_back(record);
        }
    }
//    printf("%d nodes in route database\n", (int)nodeRecordArray.size());
    sqlite3_finalize(stmt);

    return nodeRecordArray;
}

bool IPXRouteNetworkDBAdapter::open()
{
//    printf("IPXRouteNetworkDBAdapter::open()\n");
    int ret = sqlite3_open(m_path.c_str(), &m_database);
    if (ret == SQLITE_OK) {
//        printf("open sucesss: %s\n", m_path.c_str());
        return true;
    }
//    printf("open failed: %s\n", m_path.c_str());
    return false;
}

bool IPXRouteNetworkDBAdapter::close()
{
//    printf("IPXRouteNetworkDBAdapter::close()\n");
    return (sqlite3_close(m_database) == SQLITE_OK);
}