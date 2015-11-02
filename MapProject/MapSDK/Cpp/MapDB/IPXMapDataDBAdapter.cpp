//
//  IPXMapDataDBAdapter.cpp
//  MapProject
//
//  Created by innerpeacer on 15/10/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#include "IPXMapDataDBAdapter.hpp"

using namespace std;
using namespace Innerpeacer::MapSDK;

#include <geos/geom.h>
#include <geos/io.h>
#include <sstream>

#include "IPEncryption.hpp"

typedef vector<IPXFeatureRecord *> FeatureVector;

IPXMapDataDBAdapter::IPXMapDataDBAdapter(const char *dbPath)
{
    m_path = dbPath;
}

//vector<IPXFeatureRecord> IPXMapDataDBAdapter::getAllRecords()
//{
//    FeatureVector resultVector;
//    
//    return resultVector;
//}

vector<IPXFeatureRecord *> IPXMapDataDBAdapter::getAllRecordsOnFloor(int floor)
{
    FeatureVector resultVector;
    
    sqlite3_stmt *stmt = NULL;
    
    ostringstream ostr;
    ostr << "select GEOMETRY, GEO_ID, POI_ID, CATEGORY_ID, NAME, SYMBOL_ID, LAYER from MAPDATA where FLOOR_NUMBER = " << floor;
    string sql = ostr.str();
    
    stringstream s;
    WKBReader reader;
    
    int ret = sqlite3_prepare_v2(m_database, sql.c_str(), (int)sql.length(), &stmt, NULL);
    if (ret == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            IPXFeatureRecord *record = new IPXFeatureRecord();

//            s.write((const char *)sqlite3_column_blob(stmt, 0), sqlite3_column_bytes(stmt, 0));
            const char *encryptedGeometryBytes = (const char *)sqlite3_column_blob(stmt, 0);
            int encryptedGeometryByteLength = (int)sqlite3_column_bytes(stmt, 0);
            char decryptedGeometryBytes[encryptedGeometryByteLength + 1];
            decryptBytes(encryptedGeometryBytes, decryptedGeometryBytes, encryptedGeometryByteLength);
            s.clear();
            s.write((const char *)decryptedGeometryBytes, encryptedGeometryByteLength);
            
            record->geometry = reader.read(s);
            
            record->geoID = (const char *)sqlite3_column_text(stmt, 1);
            record->poiID = (const char *)sqlite3_column_text(stmt, 2);
            record->categoryID = (const char *)sqlite3_column_text(stmt, 3);
            
            if (sqlite3_column_type(stmt, 4) != SQLITE_NULL) {
                record->name = (const char *)sqlite3_column_text(stmt, 4);
            }
            
            record->symbolID = sqlite3_column_int(stmt, 5);
            record->layer = sqlite3_column_int(stmt, 6);
            
            if (record->geometry->getGeometryTypeId() == GEOS_POINT) {
                record->point =
                dynamic_cast<geos::geom::Point *>(record->geometry);
            } else if (record->geometry->getGeometryTypeId() == GEOS_POLYGON) {
                record->polygon =
                dynamic_cast<geos::geom::Polygon *>(record->geometry);
            }

            resultVector.push_back(record);
//            printf("%d\n", (int)record->name.length());
        }
    }
    sqlite3_finalize(stmt);
    return resultVector;
}

//vector<IPXFeatureRecord> IPXMapDataDBAdapter::getAllRecordsInLayer(MapLayer layer)
//{
//    FeatureVector resultVector;
//    
//    return resultVector;
//}
//
//vector<IPXFeatureRecord> IPXMapDataDBAdapter::getAllRecordsOnFloorInLayer(int floor, MapLayer layer)
//{
//    FeatureVector resultVector;
//    
//    return resultVector;
//}



bool IPXMapDataDBAdapter::open()
{
    int ret = sqlite3_open(m_path.c_str(), &m_database);
    if (ret == SQLITE_OK) {
        //        printf("open sucesss: %s\n", m_path.c_str());
        return true;
    }
    //    printf("open failed: %s\n", m_path.c_str());
    return false;
}

bool IPXMapDataDBAdapter::close()
{
    return (sqlite3_close(m_database) == SQLITE_OK);
}