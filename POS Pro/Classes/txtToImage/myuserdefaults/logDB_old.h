//
//  myuserdefaults.h
//  pos
//
//  Created by Khaled on 1/20/20.
//  Copyright © 2020 khaled. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^resultCompletionBlock)(id data);


@interface logDB_old : NSObject

+ (logDB_old *)sharedManager;

+(void) initDataBase;

@property(nonatomic,strong)  NSString *dbPath;

 
@property(nonatomic,strong)  FMDatabaseQueue *Queue_db;

@property (nonatomic, copy) resultCompletionBlock completionBlock;


+(NSString *) printPath;

//+(BOOL) isitems:(NSString *) ItemID   Prefix:(NSString*) Prefix;

+(NSArray *) lstitems:(NSString*) Prefix limit:(NSArray *)limit orderASC:(BOOL) orderASC ;
+(id) getitem:(NSString *)ItemID   Prefix:(NSString*) Prefix;


+(void) lstitems:(NSString*) Prefix completionAction:(resultCompletionBlock) completionBlock;
+(void) getitem:(NSString *)ItemID   Prefix:(NSString*) Prefix completionAction:(resultCompletionBlock) completionBlock;


+(void) Setitems:(NSString *)ItemID SetValue:(id) dic  Prefix:(NSString*) Prefix  ;

+(void) deleteAll:(NSArray *) ignoreFiles;
+(void) Deletelstitems:(NSString*) Prefix;
+(void) deleteitems:(NSString *)ItemID   Prefix:(NSString*) Prefix;
+(void) vacuum_database;

@end

NS_ASSUME_NONNULL_END
