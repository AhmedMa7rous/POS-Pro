//
//  clsIsUpdateTime.m
//  twitterSearch
//
//  Created by khaled on 1/1/14.
//  Copyright (c) 2014 greatidea. All rights reserved.
//

#import "clsIsUpdateTime.h"
 

@implementation clsIsUpdateTime

+(void) Setlastupdate:(NSString *)itemname key:(NSString *) key
{
        [myuserdefaults Setitems:itemname SetValue:[self GetDate] Prefix:key];

}

+(BOOL) isTimeTopdate:(int) timetoreloadcash itemname:(NSString *)itemname key:(NSString *) key
{
    
    NSString *dt =   [myuserdefaults getitem:itemname Prefix:key];
    
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
    
    if (t>= timetoreloadcash * 60) {
        return YES;
    }
    else
    {
        return NO;
    }
    
    
    
}

+(NSString *) GetDate
{
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MM/dd/yyyy hh:mm"];
    NSString *dateString = [dateFormat stringFromDate:date];
   // NSLog(@"%@" ,dateString) ;
    
    
    
    return dateString;
}

 

@end
