#WRAP: WorldRefecence.com API Wrapper#
WRAPI is an Objective-c Wrapper for [http://www.wordreference.com](Wordreference.com) Api. 

##How to request a translation##

Drag and drop WRAPI Folder in your project (remember to include JSONKit too)

Include WRAPI.h in your project 
    #import "WRAPI.h"

Init "WRAPI" and (optional, but required :P) define a delegate
     wrapi = [[WRAPI alloc] init];
     wrapi.delegate = self;

###Ask for translation###

You need eventually define which dictionary you need (i.e. from English (en) to Frenc (fr)) and call `requestTerm: fromLanguage: toLanguage:` like in this example :

    [wrapi requestTerm:@"Love" fromLanguage:@"en" toLanguage:@"fr"]; 

##How to get data ##

To manage response from Wordreference.com you need to implement the WRAPIDelegate with at least `translateDidFinish:` function. 

The fastest way to obtain translation is accessing properties `termTranslationList` and `compoundTranslationList` after   `translateDidFinish`. Those two functions return an NSDictionary with a formatted representation of terms and sense in original and translated language.  

##Implement the `WRAPIDelegate` protocol##

###Translation complete###

`-(void) translateDidFinish:(NSDictionary*) result;` 

This function is called when translation is completely successful terminated, `result` contains and NSDictionary with all data received from Worldreference.com (here an example return by the world "gender" on "enfr" dictionary: 

    {
    END = 1;
    Lines = "End Reached";
    original =     {
        Compounds =         {
            0 =             {
                FirstTranslation =                 {
                    POS = nm;
                    sense = "";
                    term = sexisme;
                };
                Note = "";
                OriginalTerm =                 {
                    POS = n;
                    sense = "sexual discrimination";
                    term = "gender bias";
                    usage = "";
                };
            };
            1 =             {
                FirstTranslation =                 {
                    POS = nf;
                    sense = "";
                    term = "dysphorie de genre";
                };
                Note = "";
                OriginalTerm =                 {
                    POS = "";
                    sense = "";
                    term = "gender dysphoria";
                    usage = "";
                };
            };
       };
    };
    term0 =     {
        AdditionalTranslations =         {
            0 =             {
                FirstTranslation =                 {
                    POS = nm;
                    sense = "";
                    term = sexe;
                };
                Note = "";
                OriginalTerm =                 {
                    POS = n;
                    sense = sex;
                    term = gender;
                    usage = "";
                };
            };
        };
        PrincipalTranslations =         {
            0 =             {
                FirstTranslation =                 {
                    POS = nm;
                    sense = grammaire;
                    term = genre;
                };
                Note = "";
                OriginalTerm =                 {
                    POS = n;
                    sense = grammar;
                    term = gender;
                    usage = "";
                };
            };
        };
    };
    }



###Translation not found###

`-(void)translationNotFound` 

Fired when Wordlreference.com can't find a specific term. 
You can use this function to warn your user:

    -(void)translationNotFound{
            NSAlert *alert = [[[NSAlert alloc] init] autorelease];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Translation not found"];
            [alert setInformativeText:@"I can't find a translation for this term."];
            [alert setAlertStyle:NSWarningAlertStyle];    
            [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
    } 

###Call a not supported dictionary###

`-(void) notAllowedDictionaryRequest`

Not every dictionaries are supported (at the moment) by Wordreference.com for example you can't ask for Spanish to Jappanese translation. 
This function is called after requesting a not supported dictionary.


###Redirect request###

`-(void)translateRedirectTo:(NSString *)url`

This function is an helper to intercept inverted request. For example if you request translation for the term "People" from Italian to English (thus, on dictionary @"iten") this function is called with `url=@"enit"`


 



