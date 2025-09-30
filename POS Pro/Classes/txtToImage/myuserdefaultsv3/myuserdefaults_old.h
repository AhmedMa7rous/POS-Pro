//
//  itemslist.h
//  store
//

//  Copyright (c) 2013 el-adbda3. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface myuserdefaults_old : NSObject

+(NSString *) printPath;

+(NSArray *) lstitems:(NSString*) Prefix;
+(NSArray *) lstitems:(NSString*) Prefix  directory:(NSSearchPathDirectory) directory;

+(NSArray *) lstitems_suffix:(NSString*) suffix;

+(NSArray *) lstfiles:(NSString*) Prefix;
+(NSArray *) lstfiles_fullPath:(NSString*) Prefix;

+(NSArray *) alllstitems;
//+(NSArray *) lstitems_withkey:(NSString*) Prefix;

+(BOOL) isitems:(NSString *) ItemID   Prefix:(NSString*) Prefix;

+(void) Setitems:(NSString *)ItemID SetValue:(id) dic  Prefix:(NSString*) Prefix;
+(void) Setitems:(NSString *)ItemID SetValue:(id) dic  Prefix:(NSString*) Prefix directory:(NSSearchPathDirectory)directory;

+(id) getitem:(NSString *)ItemID   Prefix:(NSString*) Prefix;
+(id) getitem:(NSString *)ItemID   Prefix:(NSString*) Prefix directory:(NSSearchPathDirectory)directory;

+(id) getitem:(NSString *)ItemID   suffix:(NSString*) suffix;

+(id) getitem:(NSString *)ItemID   Prefix:(NSString*) Prefix defalutValue:(NSString *)defalutValue;

+(void) deleteitems:(NSString *)ItemID   Prefix:(NSString*) Prefix;
+(void) Deletelstitems:(NSString*) Prefix;
+(void) Deletelstitems:(NSString*) Prefix   directory:(NSSearchPathDirectory) directory ;
+(void) deleteAll:(NSArray *) ignoreFiles;

//-(NSArray *) lstitems_:(NSString*) Prefix;
//-(BOOL) isitems_:(NSString *) ItemID   Prefix:(NSString*) Prefix;
//-(void) Setitems_:(NSString *)ItemID SetValue:(id) dic  Prefix:(NSString*) Prefix;
//-(id) getitem_:(NSString *)ItemID   Prefix:(NSString*) Prefix;
//-(void) deleteitems_:(NSString *)ItemID   Prefix:(NSString*) Prefix;
@end
