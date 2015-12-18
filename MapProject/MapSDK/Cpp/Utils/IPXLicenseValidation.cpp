//
//  IPXLicenseValidation.cpp
//  MapProject
//
//  Created by innerpeacer on 15/9/22.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#include "IPXLicenseValidation.h"
#include "IPXEncryption.hpp"
#include "IPXMD5.hpp"

using namespace std;
using namespace Innerpeacer::MapSDK;

bool Innerpeacer::MapSDK::checkValidity(std::string userID, std::string license, std::string buildingID)
{
    if (userID.length() < 18) {
        printf("Invalid UserID.\n");
        return false;
    }
    
    std::string key1 = userID.substr(2, 8);
    std::string key2 = userID.substr(10, 8);
    std::string encryptedBuildingID = encryptString(buildingID.substr(0, 8), key1);
    
    IPXMD5 md5;
    md5.update(encryptedBuildingID);
    std::string md5ForBuildingID = md5.toString();
    std::string encryptedExpiredDate = decryptString(license.substr(16, 8), md5ForBuildingID);
    std::string originalExpiredDate = decryptString(encryptedExpiredDate, key2);
    
    
    std::string expectedOriginallMD5 = "MAP" + encryptedBuildingID + encryptedExpiredDate;
    md5.reset();
    md5.update(expectedOriginallMD5);
    std::string expectedMD5String = md5.toString();
    std::string expectedLicense = expectedMD5String.substr(0, 8) + encryptString(encryptedBuildingID, md5ForBuildingID) + encryptString(encryptedExpiredDate, md5ForBuildingID) + expectedMD5String.substr(24, 8);
    
    //    cout << "Key1: " << key1 << endl;
    //    cout << "Key2: " << key2 << endl;
    //    cout << "encryptedBuildingID: " << encryptedBuildingID << endl;
    //
    //    cout << "md5ForBuildingID: " << md5ForBuildingID << endl;
    //    cout << "encryptedExpiredDate: " << encryptedExpiredDate << endl;
    //    cout << "originalExpiredDate: " << originalExpiredDate << endl;
    //
    //
    //    cout << "expectedOriginallMD5: " << expectedOriginallMD5 << endl;
    //    cout << "expectedMD5String: " << expectedMD5String << endl;
    //    cout << "expectedLicense: \t" << expectedLicense << endl;
    //    cout << "license        : \t" << license << endl;
    
    if (expectedLicense == license) {
        return true;
    } else {
        return false;
    }
}

std::string Innerpeacer::MapSDK::getExpiredDate(std::string userID, std::string license, std::string buildingID)
{
    if (userID.length() < 18) {
        printf("Invalid UserID.\n");
        return "";
    }
    
    std::string key1 = userID.substr(2, 8);
    std::string key2 = userID.substr(10, 8);
    std::string encryptedBuildingID = encryptString(buildingID.substr(0, 8), key1);
    IPXMD5 md5;
    md5.update(encryptedBuildingID);
    std::string md5ForBuildingID = md5.toString();
    std::string encryptedExpiredDate = decryptString(license.substr(16, 8), md5ForBuildingID);
    std::string originalExpiredDate = decryptString(encryptedExpiredDate, key2);
    
    //    cout << "Key1: " << key1 << endl;
    //    cout << "Key2: " << key2 << endl;
    //    cout << "encryptedBuildingID: " << encryptedBuildingID << endl;
    //    cout << "md5ForBuildingID: " << md5ForBuildingID << endl;
    //    cout << "encryptedExpiredDate: " << encryptedExpiredDate << endl;
    //    cout << "originalExpiredDate: " << originalExpiredDate << endl;
    
    return originalExpiredDate;
}