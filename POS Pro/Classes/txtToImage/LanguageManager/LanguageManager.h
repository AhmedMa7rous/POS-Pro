//
//  LanguageManager.h
//  calroy
//
//  Created by khaled al jaidi on 4/20/13.
//  Copyright (c) 2013 elbeyt. All rights reserved.
//

#import <Foundation/Foundation.h>
 #import "myuserdefaults.h"
// Supported languages.
#define kLMDefaultLanguage  @"en"
#define kLMEnglish    @"en"
#define kLMArabic     @"es"

#define kLMSelectedLanguageKey  @"kLMSelectedLanguageKey"

typedef enum
{
    NotSet = 0,
    AR  ,
    EN
} lang;


@interface LanguageManager : NSObject {
}

+(BOOL) isSupportedLanguage:(NSString*)language;
+(NSString*) localizedString:(NSString*) key;
+(void) setSelectedLanguage:(NSString*)language;
+(NSString*) selectedLanguage;

+(NSString *) text:(NSString *)en ar:(NSString *)ar;

+(lang) CurrentLang;
+(void) SetLang:(lang) lng;

@end
