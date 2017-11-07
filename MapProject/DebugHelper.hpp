//
//  DebugHelper.hpp
//  MapEngine2D
//
//  Created by innerpeacer on 15/10/15.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#ifndef DebugHelper_hpp
#define DebugHelper_hpp

#define OBJC_LOG_METHOD NSLog(@"%@ -> %@", [self class], NSStringFromSelector(_cmd));
//#define CPP_LOG_METHOD printf("Cpp Method -> %d: %s\n", __LINE__, __FUNCTION__);
#define CPP_LOG_METHOD LogCppMethod(__FILE__, __LINE__, __FUNCTION__);

void LogCppMethod(const char *file, int line, const char *func);


#endif /* DebugHelper_hpp */
