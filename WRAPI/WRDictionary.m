//
//  WRDictionary.m
//
//  Created by Yari Dareglia (@yariok) on 9/4/11.
//  Copyright 2011 Jumpzero. All rights reserved.
//

#import "WRDictionary.h"


@implementation WRDictionary
@synthesize fromLanguage,toLanguage;

- (id)init
{
    return [self initWithLanguage:@"en" translateInLanguage:@"it"];
}

static NSSet *dictionaryCombination = nil; //Static is useless here... we release dictionary object at any translate request
static NSSet *languages = nil;             //Static is useless here... we release dictionary object at any translate request

-(WRDictionary*) initWithLanguage:(NSString*)fromLang translateInLanguage:(NSString*)toLang{   
    
    self = [super init];
    if (self) {
        if(![WRDictionary isValidDictionaryLang:fromLang toLang:toLang]){   
            NSAssert(true,@"Languages error");
            return nil;
        }
        self.fromLanguage = fromLang;
        self.toLanguage = toLang;
    }
    
    return self;    
}

-(NSString*) dictionaryString{   
    if (fromLanguage!= nil && toLanguage !=nil) {
        NSString *compose = [[fromLanguage stringByAppendingString:toLanguage]autorelease];
        return compose;
    }else{  
        return nil;
    }
}

+(BOOL)isValidLanguage:(NSString *)lang{  
    if (languages == nil) {
        //Define Languages
        languages = [[NSSet setWithObjects:
                                 @"ar", //Arabian
                                 @"zh", //Chinese
                                 @"cz", //Czech
                                 @"en", //English
                                 @"fr", //French
                                 @"gr", //Greek
                                 @"it", //Italian
                                 @"ja", //Japanese
                                 @"ko", //Korean
                                 @"pl", //Polish
                                 @"pt", //Portuguese
                                 @"ro", //Romanian
                                 @"es", //Spanish
                                 @"tr", //Turkey
                                 nil
                                 ]retain];
    }
    
    return [languages containsObject:lang];
}


+(BOOL)isValidDictionaryLang:(NSString *)fromLang toLang:(NSString *)toLang{    
    
    if(![WRDictionary isValidLanguage:fromLang] && [WRDictionary isValidLanguage:toLang]){  
        return false;
    }
    
    if(dictionaryCombination == nil){  
        //Define valid combiantion
        dictionaryCombination = [[NSSet setWithObjects:
                                  @"enes",
                                  @"esen",
                                  @"esfr",
                                  @"espt",
                                 
                                  @"enfr",
                                  @"fren",
                                  @"fres",
                                  
                                  @"enit",
                                  @"iten",
                                  
                                  @"ende",
                                  @"deen",
                                  
                                  @"enru",
                                  @"ruen",
                                  
                                  @"enpt",
                                  @"pten",
                                  @"ptes", 
                                  
                                  @"enpl",
                                  @"plen",
                                  
                                  @"enro",
                                  @"roen",
                                  
                                  @"encz",
                                  @"czen",
                                  
                                  @"tren",
                                  @"entr",                                
                                  
                        
                                  //Must check chars support
                                  @"engr",
                                  @"gren",
                                  
                                  @"enja",
                                  @"jaen",
                                  
                                  @"enko",
                                  @"koen",
                                  
                                  @"aren",
                                  @"enar",
                                  //-------------------------
                                 nil
                                 ]retain];
    }
    
    return [dictionaryCombination containsObject:[fromLang stringByAppendingString:toLang]];
}

+(void) cleanStatic{    
    [languages release];
    languages = nil;
    
    [dictionaryCombination release];
    dictionaryCombination = nil;
}

-(void)dealloc{ 
    NSLog(@"rilascia");
    [fromLanguage release];
    fromLanguage = nil;
    
    [toLanguage release];
    toLanguage = nil;
    
    [super dealloc];
    
}

@end
