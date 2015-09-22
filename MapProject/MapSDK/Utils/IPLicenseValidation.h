//
//  IPLicenseValidation.h
//  MapProject
//
//  Created by innerpeacer on 15/9/22.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#ifndef __MapProject__IPLicenseValidation__
#define __MapProject__IPLicenseValidation__

#include <stdio.h>
#include <string>
#include <iostream>

bool checkValidity(std::string userID, std::string license, std::string buildingID);
std::string getExpiredDate(std::string userID, std::string license, std::string buildingID);

#endif /* defined(__MapProject__IPLicenseValidation__) */
