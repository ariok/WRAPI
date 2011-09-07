//
//  WRDictionary.h
//  Model class to describe a Wordreference dictionary
//  Created by Yari Dareglia (@yariok) on 9/4/11.
//  Copyright 2011 Jumpzero. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - 
#pragma mark WRDictionary *************************
@interface WRDictionary : NSObject{   
    NSString *fromLanguage; //original language
    NSString *toLanguage;   //translate language
}

#pragma mark - 
#pragma mark WRDictionary Properties **************
@property (copy) NSString *fromLanguage;
@property (copy) NSString *toLanguage;

#pragma mark - 
#pragma mark WRDictionary Methods******************
//Check if a language exists in wordreference valid languages list
+(BOOL)isValidLanguage:(NSString*)lang;

//Check if combination of 2 languages produces a valid dictionary
+(BOOL)isValidDictionaryLang:(NSString*)fromLang toLang:(NSString*)toLang;

//Init function 
-(WRDictionary*) initWithLanguage:(NSString*)fromLang translateInLanguage:(NSString*)toLang;

//Return dictionary identifier
-(NSString*) dictionaryString;

//Release static variable
+(void) cleanStatic;
@end
