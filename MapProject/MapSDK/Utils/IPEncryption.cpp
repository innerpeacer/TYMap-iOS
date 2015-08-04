//
//  IPEncryption.cpp
//  MapProject
//
//  Created by innerpeacer on 15/8/4.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#include "IPEncryption.hpp"
#include "IPMemery.h"

const char *KEY = "6^)(9-p35@%3#4S!4S0)$Y%%^&5(j.&^&o(*0)$Y%!#O@*GpG@=+@j.&6^)(0-=+";
const char *PASSWORD_FOR_CONTENT = "innerpeacer-content";

std::string decryptString(std::string str)
{
    return encryptString(str);
}

std::string encryptString(std::string originalString)
{
    int passLength = (int)strlen(PASSWORD_FOR_CONTENT);
    int keyLength = (int)strlen(KEY);
    
    char passValue[passLength];
    memcpy(&passValue[0], PASSWORD_FOR_CONTENT, passLength);
    
    char keyValue[keyLength];
    memcpy(&keyValue[0], KEY, keyLength);
    
    int pa_pos = 0;
    for (int i = 0; i < keyLength; ++i) {
        keyValue[i] ^= passValue[pa_pos];
        pa_pos++;
        
        if (pa_pos == passLength) {
            pa_pos = 0;
        }
    }
    
    int originalLength = (int)strlen(originalString.c_str());
    char originalValue[originalLength + 1];
    memcpy(&originalValue[0], originalString.c_str(), originalLength);
    
    int key_pos = 0;
    for (int i = 0; i < originalLength ; ++i) {
        originalValue[i] ^= keyValue[key_pos];
        key_pos++;
        if (key_pos == keyLength) {
            key_pos = 0;
        }
    }
    originalValue[originalLength] = 0;
    
    return std::string(originalValue);
}

void encryptFile(const char *originalPath, const char *encryptedFile)
{
    int passLength = (int)strlen(PASSWORD_FOR_CONTENT);
    int keyLength = (int)strlen(KEY);
    
    char passValue[passLength];
    memcpy(&passValue[0], PASSWORD_FOR_CONTENT, passLength);
    
    char keyValue[keyLength];
    memcpy(&keyValue[0], KEY, keyLength);
    
    int pa_pos = 0;
    for (int i = 0; i < keyLength; ++i) {
        keyValue[i] ^= passValue[pa_pos];
        pa_pos++;
        
        if (pa_pos == passLength) {
            pa_pos = 0;
        }
    }
    
    IPMemory *memory = mOpen(originalPath);
    int originalLength = memory->size;
    char originalValue[originalLength + 1];
    memcpy(&originalValue[0], memory->buffer, originalLength);
    mClose(memory);
    
    int key_pos = 0;
    for (int i = 0; i < originalLength ; ++i) {
        originalValue[i] ^= keyValue[key_pos];
        key_pos++;
        if (key_pos == keyLength) {
            key_pos = 0;
        }
    }
    originalValue[originalLength] = 0;
    
    FILE *f;
    f = fopen(encryptedFile, "wb");
    
    if (!f) {
        return;
    }
    
    fwrite(originalValue, originalLength, 1, f);
    fclose(f);
}

std::string decryptFile(const char *file)
{
    int passLength = (int)strlen(PASSWORD_FOR_CONTENT);
    int keyLength = (int)strlen(KEY);
    
    char passValue[passLength];
    memcpy(&passValue[0], PASSWORD_FOR_CONTENT, passLength);
    
    char keyValue[keyLength];
    memcpy(&keyValue[0], KEY, keyLength);
    
    int pa_pos = 0;
    for (int i = 0; i < keyLength; ++i) {
        keyValue[i] ^= passValue[pa_pos];
        pa_pos++;
        
        if (pa_pos == passLength) {
            pa_pos = 0;
        }
    }
    
    IPMemory *memory = mOpen(file);
    int originalLength = memory->size;
    char originalValue[originalLength + 1];
    memcpy(&originalValue[0], memory->buffer, originalLength);
    mClose(memory);
    
    int key_pos = 0;
    for (int i = 0; i < originalLength ; ++i) {
        originalValue[i] ^= keyValue[key_pos];
        key_pos++;
        if (key_pos == keyLength) {
            key_pos = 0;
        }
    }
    originalValue[originalLength] = 0;
    
    return originalValue;
}

void decryptFile(const char *encryptedFile, const char *decryptedFile)
{
    encryptFile(encryptedFile, decryptedFile);
}