//
//  WRAPI.m
//  A wrapper for Wordreference.com API 
//
//  Created by Yari Dareglia (@yariok) on 9/4/11.
//  Copyright 2011 Jumpzero. All rights reserved.
//

#import "WRAPI.h"
#import "JSONKit.h"

@implementation WRAPI
@synthesize  delegate;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}


-(void) requestTerm:(NSString*) term fromLanguage:(NSString*)from toLanguage:(NSString*)to{    
    
    if (dictionary != nil) {
        [dictionary release];
    }
    
    dictionary = [[WRDictionary alloc]initWithLanguage:from translateInLanguage:to];
    
    if(dictionary){
        
        NSString *encode_term = [term  stringByAddingPercentEscapesUsingEncoding:
                                 NSUTF8StringEncoding];
        NSString *url = [NSString stringWithFormat:API_URL, API_VERSION,API_KEY,[dictionary dictionaryString],encode_term,nil];

        // Create the request.
        NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:60.0];
        // create the connection with the request
        // and start loading the data
        NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        if (theConnection) {
            // Create the NSMutableData to hold the received data.
            receivedData = [[NSMutableData data] retain];
        } else {
            NSLog(@"Connection error");
        }
    }else{  
        if([self.delegate respondsToSelector:@selector(notAllowedDictionaryRequest)]){
            [self.delegate notAllowedDictionaryRequest];
        }        
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    
    [receivedData appendData:data];
}


- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    if([self.delegate respondsToSelector:@selector(translateDidFailWithError:)]){
        [self.delegate translateDidFailWithError:error];
    }
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //Release object for previous request
    if(translateObj){   
        [translateObj release];
    }
    
    translateObj = [[receivedData objectFromJSONDataWithParseOptions:JKParseOptionUnicodeNewlines]retain];
    
    //The structure of Wordreference API response is a bit confused, we need to search for "response" and "note" to manage errors.
    NSDictionary* response = [translateObj objectForKey:@"Response"];
    NSDictionary* note = [translateObj objectForKey:@"Note"];
    
    if (response!= nil) {
        if([self.delegate respondsToSelector:@selector(translateRedirectTo:)]){
            [self.delegate translateRedirectTo:[translateObj objectForKey:@"URL"]];
        }
    }else if(note !=nil){  
        if([self.delegate respondsToSelector:@selector(translationNotFound)]){
            [self.delegate translationNotFound];
        }
    }else  if([self.delegate respondsToSelector:@selector(translateDidFinish:)]){
        
        [self.delegate translateDidFinish:translateObj];
    }
    
    // release the connection, and the data object
    [connection release];
    [receivedData release];
}

-(NSDictionary *)compounds{ 
    if(translateObj != nil){   
        return [translateObj valueForKeyPath:@"original.Compounds"];
    }else return nil;
}

-(NSDictionary *)terms{ 
    if(translateObj != nil){   
        //NOTE: I can't find a way to produce other termN results. 
        //In this first implementation we check only for term0.
        return [translateObj valueForKeyPath:@"term0"];
    }else return nil;
}


-(NSArray*) termTranslationList{  
    
    NSMutableArray *output = [NSMutableArray array];
    
    NSDictionary *principalDictionary = [[self terms]valueForKey:@"PrincipalTranslations"];
    NSDictionary *additionalDictionary = [[self terms]valueForKey:@"AdditionalTranslations"];
    
    if(principalDictionary != nil){          
        for (id indexElement in principalDictionary) {
            NSDictionary *tempDict = [principalDictionary objectForKey:indexElement];
            NSString *trans;
            NSString *origin;
            
            if([tempDict valueForKeyPath:@"FirstTranslation.sense"] != @""){
                trans = [NSString stringWithFormat:@"%@ (%@)", [tempDict valueForKeyPath:@"FirstTranslation.term"],[tempDict valueForKeyPath:@"FirstTranslation.sense"]];
            }else{  
                trans = [tempDict valueForKeyPath:@"FirstTranslation.term"];
            }
            
            if([tempDict valueForKeyPath:@"OriginalTerm.sense"] != @""){
                origin = [NSString stringWithFormat:@"%@ (%@)", [tempDict valueForKeyPath:@"OriginalTerm.term"],[tempDict valueForKeyPath:@"OriginalTerm.sense"]];
            }else{  
                origin = [tempDict valueForKeyPath:@"OriginalTerm.term"];
            }
            
            NSDictionary *element = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:trans,origin,nil] 
                                                                forKeys:[NSArray arrayWithObjects:@"trans",@"origin",nil]];
            [output addObject:element];    
        }
        
    }
    
    if(additionalDictionary != nil){          
        for (id indexElement in additionalDictionary) {
            
            NSDictionary *tempDict = [additionalDictionary objectForKey:indexElement];
            NSString *trans;
            NSString *origin;
            
            if([tempDict valueForKeyPath:@"FirstTranslation.sense"] != @""){
                trans = [NSString stringWithFormat:@"%@ (%@)", [tempDict valueForKeyPath:@"FirstTranslation.term"],[tempDict valueForKeyPath:@"FirstTranslation.sense"]];
            }else{  
                trans = [tempDict valueForKeyPath:@"FirstTranslation.term"];
            }
            
            if([tempDict valueForKeyPath:@"OriginalTerm.sense"] != @""){
                origin = [NSString stringWithFormat:@"%@ (%@)", [tempDict valueForKeyPath:@"OriginalTerm.term"],[tempDict valueForKeyPath:@"OriginalTerm.sense"]];
            }else{  
                origin = [tempDict valueForKeyPath:@"OriginalTerm.term"];
            }
            
            NSDictionary *element = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:trans,origin,nil] 
                                                                forKeys:[NSArray arrayWithObjects:@"trans",@"origin",nil]];
            [output addObject:element];    
        }
    }
    if ([output count] > 0)  {
        return [NSArray arrayWithArray:output];    
    }else { 
        return nil;
    }
    
}

-(NSArray*) compoundTranslationList{  
    
    NSMutableArray *output = [NSMutableArray array];
    
    if([self compounds]!= nil){          
        for (id indexElement in [self compounds]) {
            NSString *trans;
            NSString *origin;
            NSDictionary *tempDict = [[self compounds] objectForKey:indexElement];
            
            if([tempDict valueForKeyPath:@"FirstTranslation.sense"] != @""){
                trans = [NSString stringWithFormat:@"%@ (%@)", [tempDict valueForKeyPath:@"FirstTranslation.term"],[tempDict valueForKeyPath:@"FirstTranslation.sense"]];
            }else{  
                trans = [tempDict valueForKeyPath:@"FirstTranslation.term"];
            }
            
            if([tempDict valueForKeyPath:@"OriginalTerm.sense"] != @""){
                origin = [NSString stringWithFormat:@"%@ (%@)", [tempDict valueForKeyPath:@"OriginalTerm.term"],[tempDict valueForKeyPath:@"OriginalTerm.sense"]];
            }else{  
                origin = [tempDict valueForKeyPath:@"OriginalTerm.term"];
            }
            
            
            NSDictionary *element = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:trans,origin,nil] 
                                                                forKeys:[NSArray arrayWithObjects:@"trans",@"origin",nil]];
            [output addObject:element];    
        }
        
    }

    if ([output count] > 0)  {
        return [NSArray arrayWithArray:output];    
    }else { 
        return nil;
    }
    
}




-(void)dealloc{ 
    if(dictionary != nil){  
        //[WRDictionary cleanStatic]; //Very this code on multithreading environment before than use it
        [dictionary release];
    }
    
    if(translateObj != nil){    
        [translateObj release];
    }
    [super dealloc];
}

@end
