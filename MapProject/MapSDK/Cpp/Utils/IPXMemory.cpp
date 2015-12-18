//
//  IPMemery.cpp
//  IPMapEngine
//
//  Created by innerpeacer on 15/6/26.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#include "IPXMemory.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

using namespace Innerpeacer::MapSDK;

IPXMemory *Innerpeacer::MapSDK::mOpen(const char *fName) {
    FILE *f;
    f = fopen(fName, "rb");
    
    if (!f) {
        return NULL;
    }
    
    IPXMemory *memory = (IPXMemory *) calloc(1, sizeof(IPXMemory));
    strcpy(memory->fileName, fName);
    
    fseek(f, 0, SEEK_END);
    memory->size = (unsigned int) ftell(f);
    fseek(f, 0, SEEK_SET);
    
    memory->buffer = (unsigned char *) calloc(1, memory->size + 1);
    fread(memory->buffer, memory->size, 1, f);
    memory->buffer[memory->size] = 0;
    
    fclose(f);
    return memory;
}

IPXMemory *Innerpeacer::MapSDK::mClose(IPXMemory *memory) {
    if (memory->buffer) {
        free(memory->buffer);
    }
    free(memory);
    return NULL;
}

unsigned int Innerpeacer::MapSDK::mRead(IPXMemory *memory, void *dst, unsigned int size) {
    if (memory->position + size > memory->size) {
        size = memory->size - memory->position;
    }
    
    memcpy(dst, &memory->buffer[memory->position], size);
    memory->position += size;
    return size;
}

void Innerpeacer::MapSDK::mInsert(IPXMemory *memory, char *str, unsigned int position) {
    unsigned int s1 = (unsigned int) strlen(str);
    unsigned int s2 = memory->size + s1 + 1;
    
    char *buffer = (char *) memory->buffer;
    char *tmp = (char *) calloc(1, s2);
    
    if (position) {
        strncpy(&tmp[0], &buffer[0], position);
    }
    
    strcat(&tmp[position], str);
    strcat(&tmp[position + s1], &buffer[position]);
    
    memory->size = s2;
    free(memory->buffer);
    memory->buffer = (unsigned char *) tmp;
}
