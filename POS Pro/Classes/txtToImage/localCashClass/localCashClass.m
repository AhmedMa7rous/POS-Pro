//
//  CashClass.m
//  el-abda3-lib
//
//  Created by khaled on 1/26/15.
//  Copyright (c) 2015 com.el-abda3. All rights reserved.
//

#import "localCashClass.h"
#import "myuserdefaults.h"


@interface localCashClass()

{
 
    int TimeToReloadCash;
    NSString *lastupdate;
}

@end
@implementation localCashClass


-(id) init :(int)ReloadEveryMinute
{
    if (self == [super init]) {
        
   
        TimeToReloadCash = ReloadEveryMinute;
        lastupdate =@"lastupdate";
        _EnableCash = YES;
        
        return self;
    }
    
    return nil;
}

-(NSDictionary *) getSavedLastData:(NSString *) url keydata:(NSString *) keydata
{
    __block NSDictionary *rowsData ;

    rowsData =[ [NSDictionary alloc] initWithDictionary:[myuserdefaults getitem:url Prefix: keydata]];
    if ([[rowsData allKeys] count] ==0) {
        return nil;
    }
    else
        return rowsData;
}

-(NSDictionary *) getLastData:(NSString *) url keydata:(NSString *) keydata UseCash:(BOOL)UseCash checkInternet:(BOOL) checkInternet
{
    
//    self.CashcompletionBlock = completion;
    
    __block NSDictionary *rowsData ;
    
    BOOL ReadFromServer = NO;
    if (UseCash == NO) {
        ReadFromServer = YES;
    }
    else
    {
//        BOOL IsTimeToUpdate =[self isTimeTopdate:url];
        BOOL IsTimeToUpdate =[self isTimeTopdate:[NSString stringWithFormat:@"%@_%@",url,keydata]];

        if (IsTimeToUpdate == YES) {
           
            ReadFromServer = checkInternet;
        }
        else
        {
            ReadFromServer =NO;
        }
    }
    
    
    
    
    if (ReadFromServer == NO) {
        
        rowsData =[ [NSDictionary alloc] initWithDictionary:[myuserdefaults getitem:url Prefix: keydata]];
        if ([[rowsData allKeys] count] ==0) {
            return nil;
        }
        else
        return rowsData;
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.CashcompletionBlock(rowsData);
//        });
        
    }
    else
    {

        return nil;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.CashcompletionBlock(nil);
//        });
        
    }
    
    
}
-(void) saveData:(NSString *) url keydata:(NSString *) keydata dictionary:(NSDictionary *)dictionary
{
    [myuserdefaults Setitems:url SetValue:dictionary Prefix:keydata];
    [self SetTimelastupdate:[NSString stringWithFormat:@"%@_%@",url,keydata]];
}
 
//
//-(void) GetCashedData:(NSString *) url keydata:(NSString *) keydata UseCash:(BOOL)UseCash  con:(kcon *)con dic:(NSDictionary *) dic withCompletion:(CashCompletion)completion
//{
//
//    self.CashcompletionBlock = completion;
//
//    __block NSArray *rowsData ;
//
//    BOOL ReadFromServer = NO;
//    if (UseCash == NO) {
//        ReadFromServer = YES;
//    }
//    else
//    {
//        BOOL IsTimeToUpdate =[self isTimeTopdate:url];
//
//
//        if (IsTimeToUpdate == YES) {
//            ReadFromServer = YES;
//        }
//        else
//        {
//
//            rowsData =[ [NSArray alloc] initWithArray:[myuserdefaults getitem:url Prefix: keydata]];
//
//            if ([rowsData count] ==0) {
//                ReadFromServer = YES;
//            }
//            else
//            {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    self.CashcompletionBlock(rowsData);
//                });
//            }
//
//        }
//
//
//    }
//
//
//
//
//    if (ReadFromServer == YES)
//    {
//
//        [con SendData:url item:dic  withCompletion:^(NSArray *rows) {
//
//            if (rows != nil) {
//                [myuserdefaults Setitems:url SetValue:rows Prefix:keydata];
//
//            }
//
//             [self SetTimelastupdate:url];
//
//            rowsData =[ [NSArray alloc] initWithArray:[myuserdefaults getitem:url Prefix: keydata]];
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.CashcompletionBlock(rowsData);
//            });
//
//
//        } withProgress:^(float pre) {
//
//        }];
//    }
//
//
//}




-(NSString *) getTimelastupdate :(NSString *)key
{
  
    return  [myuserdefaults getitem:key Prefix:lastupdate];
 
}

-(void) SetTimelastupdate :(NSString *)key
{
  
        [myuserdefaults Setitems : key SetValue:[self GetDate] Prefix:lastupdate];
 
}

-(BOOL) isTimeTopdate:(NSString *)key
{
 
    if (_EnableCash == NO) {
        return YES;
    }
    else
    {
    
        return [self CheckUpdate:key];
    }
    
  
    
}

-(BOOL) CheckUpdate:(NSString *)key
{

    NSString *dt =   [myuserdefaults getitem : key Prefix:lastupdate];
    
    if (dt == nil) {
        return YES;
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM/dd/yyyy hh:mm"];
    
    NSDate *dtlastupdate = [[NSDate alloc] init];
    NSDate *dtnow = [[NSDate alloc] init];
    
    dtlastupdate = [df dateFromString:dt];
    dtnow = [df dateFromString:[self GetDate]];
    
    
    int t=  [dtnow timeIntervalSinceDate:dtlastupdate] ;
    
    if (t>=  TimeToReloadCash * 60) {
        return YES;
    }
    else
    {
        return NO;
    }
    
    
}

-(NSString *) GetDate
{
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MM/dd/yyyy hh:mm"];
    NSString *dateString = [dateFormat stringFromDate:date];
    //  NSLog(@"%@" ,dateString) ;
    
    
    
    return dateString;
}



@end
