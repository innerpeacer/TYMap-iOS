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
std::string decryptString(std::string str, std::string key);

std::string encryptString(std::string str);
std::string encryptString(std::string originalString, std::string key);

void encryptFile(const char *originalPath, const char *encryptedFile);
void encryptFile(const char *originalPath, const char *encryptedFile, const char *key);

std::string decryptFile(const char *file);
std::string decryptFile(const char *file, const char *key);

void encryptBytes(const char *originalBytes, char *encryptedByte, int length);
void encryptBytes(const char *originalBytes, char *encryptedByte, int length, const char *key);

void decryptBytes(const char *encryptedBytes, char *originalBytes, int length);
void decryptBytes(const char *encryptedBytes, char *originalBytes, int length, const char *key);


#endif /* IPEncryption_hpp */
