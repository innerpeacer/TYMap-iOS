//
//  IPXLicenseValidation.h
//  MapProject
//
//  Created by innerpeacer on 15/9/22.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#ifndef __MapProject__IPXLicenseValidation__
#define __MapProject__IPXLicenseValidation__

#include <stdio.h>
#include <string>
#include <iostream>


namespace Innerpeacer {
    namespace MapSDK {
        bool checkValidity(std::string userID, std::string license, std::string buildingID);
        std::string getExpiredDate(std::string userID, std::string license, std::string buildingID);
    }
}


#endif /* defined(__MapProject__IPLicenseValidation__) */
