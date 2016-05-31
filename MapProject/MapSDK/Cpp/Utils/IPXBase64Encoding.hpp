//
//  IPXBase64Encoding.hpp
//  TestCppBase64
//
//  Created by innerpeacer on 16/5/31.
//  Copyright © 2016年 innerpeacer. All rights reserved.
//

#ifndef IPXBase64Encoding_hpp
#define IPXBase64Encoding_hpp

#include <stdio.h>
#include <string>

namespace Innerpeacer {
    namespace MapSDK {
        std::string base64Encode(unsigned char const* , unsigned int len);
        std::string base64Decode(std::string const& s);
    }
}

#endif /* IPXBase64Encoding_hpp */
