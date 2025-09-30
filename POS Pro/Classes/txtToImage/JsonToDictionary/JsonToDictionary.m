//
//  JsonToDictionary.m
//
//  Created by Oscar Vicente Gonzalez Greco on 1/22/13.
//  Copyright (c) 2013 Oscar Vicente Gonzalez Greco. All rights reserved.
//

#import "JsonToDictionary.h"

@implementation JsonToDictionary

+ (NSString*)JSONStringWithDictionary:(NSDictionary*)dictionary prettyPrinted:(BOOL)prettyPrinted
{
    NSJSONWritingOptions options = (prettyPrinted) ? NSJSONWritingPrettyPrinted : 0;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:options error:nil];
    return  [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)diccionaryFromJsonString:(NSString *)stringJson
{
    NSData *data = [stringJson dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:0
                                                                     error:&error];
    
    if (error)
    {
        NSLog(@"Error al leer json: %@", [error description]);
    }
    
    return jsonDictionary;
}

+ (NSArray *)ArrayFromJsonString:(NSString *)stringJson
{
    NSData *data = [stringJson dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    
    NSArray *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:0
                                                                     error:&error];
    
    if (error)
    {
        NSLog(@"Error al leer json: %@", [error description]);
    }
    
    return jsonDictionary;
}

+ (NSString *)jsonStringFromDictionary:(NSDictionary *)dictionary
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (error)
    {
        NSLog(@"Error: %@", error);
    }
    
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

@end
