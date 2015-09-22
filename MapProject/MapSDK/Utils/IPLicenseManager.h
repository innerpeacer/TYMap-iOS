//
//  IPLicenseManager.h
//  MapProject
//
//  Created by innerpeacer on 15/9/21.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#ifndef __MapProject__IPLicenseManager__
#define __MapProject__IPLicenseManager__

#include <stdio.h>
#include <string>
#include <iostream>

bool checkValidity(std::string userID, std::string license, std::string buildingID);
std::string getExpiredDate(std::string userID, std::string license, std::string buildingID);

#endif /* defined(__MapProject__IPLicenseManager__) */
