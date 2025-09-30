//
//  CashClass.h
//  el-abda3-lib
//
//  Created by khaled on 1/26/15.
//  Copyright (c) 2015 com.el-abda3. All rights reserved.
//

#import <Foundation/Foundation.h>
 

typedef void(^CashCompletion)(NSDictionary *rows);

@interface localCashClass : NSObject

@property (nonatomic, copy) CashCompletion CashcompletionBlock;

-(id) init :(int)ReloadEveryMinute;

-(NSDictionary *) getSavedLastData:(NSString *) url keydata:(NSString *) keydata;
-(NSDictionary *) getLastData:(NSString *) url keydata:(NSString *) keydata UseCash:(BOOL)UseCash checkInternet:(BOOL) checkInternet;
//-(void) getLastData:(NSString *) url keydata:(NSString *) keydata UseCash:(BOOL)UseCash  withCompletion:(CashCompletion)completion;
-(void) saveData:(NSString *) url keydata:(NSString *) keydata dictionary:(NSDictionary *)dictionary;



//-(void) GetCashedData:(NSString *) url keydata:(NSString *) keydata UseCash:(BOOL)UseCash  con:(kcon *)con dic:(NSDictionary *) dic withCompletion:(CashCompletion)completion;


@property(nonatomic) BOOL EnableCash;

-(BOOL) isTimeTopdate:(NSString *)key ;
-(void) SetTimelastupdate:(NSString *)key;
-(NSString *) getTimelastupdate :(NSString *)key;

@end
