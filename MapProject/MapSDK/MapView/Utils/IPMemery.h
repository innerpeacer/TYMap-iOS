//
//  IPMemery.h
//  IPMapEngine
//
//  Created by innerpeacer on 15/6/26.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#ifndef __IPMapEngine__IPMemery__
#define __IPMapEngine__IPMemery__

#define MAX_PATH	256


        typedef struct {
            char fileName[MAX_PATH];
            unsigned int size;
            unsigned int position;
            
            unsigned char *buffer;
        } IPMemory;
        
        IPMemory *mOpen(const char *fName);
        IPMemory *mClose(IPMemory *memory);
        unsigned int mRead(IPMemory *memory, void *dst, unsigned int size);
        void mInsert(IPMemory *memory, char *str, unsigned int position);
 

#endif /* defined(__IPMapEngine__IPMemery__) */
