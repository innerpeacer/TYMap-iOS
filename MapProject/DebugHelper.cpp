//
//  DebugHelper.cpp
//  MapEngine2D
//
//  Created by innerpeacer on 15/10/15.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#include "DebugHelper.hpp"
#include <string>

void LogCppMethod(const char *file, int line, const char *func)
{
    char s[256];
    strcpy(s, file);
    
    const char *d = "/";
    char *p;
    char *c = NULL;
    p = strtok(s, d);
    while (p) {
        c = p;
        strcpy(p, c);
        p = strtok(NULL, d);
    }
    printf("================== %s:%d ->  %s()\n", c, line, func);
}