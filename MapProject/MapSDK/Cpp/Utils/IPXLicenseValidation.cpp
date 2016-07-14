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
#include "IPXBase64Encoding.hpp"

using namespace std;
using namespace Innerpeacer::MapSDK;

bool checkValidityForLicense32(std::string userID, std::string license, std::string buildingID);
std::string getExpiredDateForLicense32(std::string userID, std::string license, std::string buildingID);

bool checkValidityForBase64License40(std::string userID, std::string license, std::string buildingID);
std::string getExpiredDateForBase64License40(std::string userID, std::string license, std::string buildingID);

void string_replace(string &s1, const string &s2, const string &s3)
{
    string::size_type pos = 0;
    string::size_type a = s2.size();
    string::size_type b = s3.size();
    while ((pos = s1.find(s2, pos)) != string::npos) {
        s1.replace(pos, a, s3);
        pos += b;
    }
}

bool Innerpeacer::MapSDK::checkValidity(std::string userID, std::string license, std::string buildingID)
{
    if (license.length() == 32) {
        return  checkValidityForLicense32(userID, license, buildingID);
    } else if (license.length() == 40) {
        return checkValidityForBase64License40(userID, license, buildingID);
    }
    return false;
}

std::string Innerpeacer::MapSDK::getExpiredDate(std::string userID, std::string license, std::string buildingID)
{
    if (license.length() == 32) {
        return getExpiredDateForLicense32(userID, license, buildingID);
    } else if (license.length() == 40) {
        return getExpiredDateForBase64License40(userID, license, buildingID);
    }
    return "";
}

bool checkValidityForBase64License40(std::string userID, std::string license, std::string buildingID)
{
//    printf("Innerpeacer::MapSDK::checkValidity\n");
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
    
    string basedEncryptedExpiredDate = license.substr(20, 12);
    string_replace(basedEncryptedExpiredDate, "#", "=");
    string_replace(basedEncryptedExpiredDate, ":", "/");
    std::string encryptedExpiredDate = decryptString(base64Decode(basedEncryptedExpiredDate), md5ForBuildingID);
    std::string originalExpiredDate = decryptString(encryptedExpiredDate, key2);
    
    std::string expectedOriginallMD5 = "MAP" + encryptedBuildingID + encryptedExpiredDate;
    md5.reset();
    md5.update(expectedOriginallMD5);
    std::string expectedMD5String = md5.toString();
    
    string expectedEncryptedBuildingID = encryptString(encryptedBuildingID, md5ForBuildingID);
    string expectedBasedEncryptedBuildingID = base64Encode(reinterpret_cast<const unsigned char*>(expectedEncryptedBuildingID.c_str()), (unsigned int)expectedEncryptedBuildingID.length());
    string_replace(expectedBasedEncryptedBuildingID, "/", ":");
    string_replace(expectedBasedEncryptedBuildingID, "=", "#");
    
    string expectedEncryptedExpireDate = encryptString(encryptedExpiredDate, md5ForBuildingID);
    string expectedBasedEncryptedExpireDate = base64Encode(reinterpret_cast<const unsigned char*>(expectedEncryptedExpireDate.c_str()), (unsigned int)expectedEncryptedExpireDate.length());
    string_replace(expectedBasedEncryptedExpireDate, "/", ":");
    string_replace(expectedBasedEncryptedExpireDate, "=", "#");
    
    std::string expectedLicense = expectedMD5String.substr(0, 8) + expectedBasedEncryptedBuildingID + expectedBasedEncryptedExpireDate + expectedMD5String.substr(24, 8);
    
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

std::string getExpiredDateForBase64License40(std::string userID, std::string license, std::string buildingID)
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
    
    string basedEncryptedExpiredDate = license.substr(20, 12);
    string_replace(basedEncryptedExpiredDate, "#", "=");
    string_replace(basedEncryptedExpiredDate, ":", "/");
    std::string encryptedExpiredDate = decryptString(base64Decode(basedEncryptedExpiredDate), md5ForBuildingID);
    std::string originalExpiredDate = decryptString(encryptedExpiredDate, key2);
    
    //    cout << "Key1: " << key1 << endl;
    //    cout << "Key2: " << key2 << endl;
    //    cout << "encryptedBuildingID: " << encryptedBuildingID << endl;
    //    cout << "md5ForBuildingID: " << md5ForBuildingID << endl;
    //    cout << "encryptedExpiredDate: " << encryptedExpiredDate << endl;
    //    cout << "originalExpiredDate: " << originalExpiredDate << endl;
    
    return originalExpiredDate;
}

bool checkValidityForLicense32(std::string userID, std::string license, std::string buildingID)
{
//    printf("Innerpeacer::MapSDK::checkValidity\n");
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

std::string getExpiredDateForLicense32(std::string userID, std::string license, std::string buildingID)
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