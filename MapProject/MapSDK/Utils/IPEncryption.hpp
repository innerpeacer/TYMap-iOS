//
//  IPEncryption.hpp
//  MapProject
//
//  Created by innerpeacer on 15/8/4.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#ifndef IPEncryption_hpp
#define IPEncryption_hpp

#include <stdio.h>

#include <string>

std::string decryptString(std::string str);
std::string encryptString(std::string str);

void encryptFile(const char *originalPath, const char *encryptedFile);
void decryptFile(const char *encryptedFile, const char *decryptedFile);

std::string decryptFile(const char *file);

#endif /* IPEncryption_hpp */
