//
//  WRAPI.h
//  A wrapper for Wordreference.com API 
//
//  Created by Yari Dareglia (@yariok) on 9/4/11.
//  Copyright 2011 Jumpzero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WRDictionary.h"

#pragma mark - 
#pragma mark WRAPI Constants ******************
#define API_KEY @"f493f"    //Your personal API KEY                                        
#define API_VERSION @"0.8"  //Wordreference API version
#define API_URL @"http://api.wordreference.com/%@/%@/json/%@/%@" //API URL format

#pragma mark - 
#pragma mark WRAPI definitions ****************
@protocol WRAPIDelegate;

@interface WRAPI : NSObject{
    
    id <WRAPIDelegate> delegate; //Delegate 
    
  @private
    NSMutableData *receivedData;
    NSMutableDictionary *translateObj;
    WRDictionary *dictionary;
}   

#pragma mark - 
#pragma mark WRAPI Properties ****************
//WRAPIDelegate 
@property (assign) id <WRAPIDelegate> delegate;

//Return list of compound translations
@property (readonly) NSDictionary *compounds;

//Return list of simple single term translation 
@property (readonly) NSDictionary *terms;

//Return a simplified list of principal and additional term translations 
@property (readonly) NSArray *termTranslationList;

//Return a simplified list of compound term translations  
@property (readonly) NSArray *compoundTranslationList;

#pragma mark - 
#pragma mark WRAPI Methods *******************
//Request translation
-(void) requestTerm:(NSString*) term fromLanguage:(NSString*) from toLanguage:(NSString*)to;
@end

#pragma mark - 
#pragma mark WRAPI Delegate *****************
@protocol WRAPIDelegate <NSObject>
@optional
//Translate is done, by now you can access 
-(void) translateDidFinish:(NSDictionary*) result;
//Error occured during request
-(void) translateDidFailWithError:(NSError*) error;
//Redirect to other dictionary (see Wordreference API documentation) 
-(void) translateRedirectTo:(NSString*) url;
//Term can't be translated
-(void) translationNotFound;
//Attempt to create a not valid dictionary (see Wordreference API documantation to get info about allowed dictionaries)
-(void) notAllowedDictionaryRequest;
@end