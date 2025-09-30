//
//  LanguageManager.m
//  calroy
//
//  Created by khaled al jaidi on 4/20/13.
//  Copyright (c) 2013 elbeyt. All rights reserved.
//

#import "LanguageManager.h"

@implementation LanguageManager

+(BOOL) isSupportedLanguage:(NSString*)language {
    
    if ( [language isEqualToString:kLMEnglish] ) {
        return YES;
    }
    if ( [language isEqualToString:kLMArabic] ) {
        return YES;
    }
    
    return NO;
}

+(NSString*) localizedString:(NSString*)key {
    
  //  NSString *s =NSLocalizedString(key, key);
    //return  s  ;
   
     NSString *selectedLanguage = [LanguageManager selectedLanguage];
     
     // Get the corresponding bundle path.
     NSString *path = [[NSBundle mainBundle] pathForResource:selectedLanguage ofType:@"lproj"];
     
     // Get the corresponding localized string.
     NSBundle* languageBundle = [NSBundle bundleWithPath:path];
     NSString* str = [languageBundle localizedStringForKey:key value:@"" table:nil];
     return str;
    
}

+(void) setSelectedLanguage:(NSString*)language {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([language isEqualToString:@"ar"]) {
        language = @"es";
    }
    // Check if desired language is supported.
    if ( [self isSupportedLanguage:language] ) {
        [userDefaults setObject:language forKey:kLMSelectedLanguageKey];
    } else {
        // if desired language is not supported, set selected language to nil.
        [userDefaults setObject:nil forKey:kLMSelectedLanguageKey];
    }
}

+(NSString*) selectedLanguage {
    // Get selected language from user defaults.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *selectedLanguage = [userDefaults stringForKey:kLMSelectedLanguageKey];
    
    // if the language is not defined in user defaults yet...
    if (selectedLanguage == nil) {
        // Get the system language.
        NSArray* userLangs = [userDefaults objectForKey:@"AppleLanguages"];
        if ([userLangs count] >0) {
            
  
        NSString *systemLanguage = [userLangs objectAtIndex:0];
        
        // if system language is supported by LanguageManager, set it as selected language.
        if ( [self isSupportedLanguage:systemLanguage] ) {
            [self setSelectedLanguage:systemLanguage];
            // if not...
        } else {
            // Set the LanguageManager default language as selected language.
            [self setSelectedLanguage:kLMDefaultLanguage];
        }
              }
    }
    
    return [userDefaults stringForKey:kLMSelectedLanguageKey];
}


+(NSString *) Prefix_LANG
{
    return  @"LanguageManager";
}
+(lang) CurrentLang
{
    NSString *l = [  myuserdefaults getitem:@"lang" Prefix:[self Prefix_LANG]] ;
    if (l == nil) {
        return  NotSet;
    }
    
  
    int lx = [l intValue];
    
    return lx;
}


+(void) SetLang:(lang) lng
{

    NSString *keyval =[ NSString stringWithFormat:@"%@",@(lng)];
    [ myuserdefaults Setitems:@"lang" SetValue:keyval Prefix:[self Prefix_LANG]];
}

+(NSString *) text:(NSString *)en ar:(NSString *)ar
{
    
    if ([LanguageManager CurrentLang] == AR) {
        return ar;
    }
    
    return en;
}



@end
