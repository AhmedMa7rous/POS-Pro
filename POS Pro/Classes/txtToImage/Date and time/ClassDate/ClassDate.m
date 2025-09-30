//
//  ClassDate.m
//  KLib
//
//  Created by ebad3 on 10/23/15.
//  Copyright © 2015 com.greatideas4ap. All rights reserved.
//

#import "ClassDate.h"
#include <sys/time.h>
@implementation ClassDate


 

+(NSString *) serverFromate
{
 
      return @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"  ;
}

+(NSString *) SatnderFromate
{
    // return @"MM/dd/yyyy HH:mm:ss"  ;
      return @"yyyy-MM-dd HH:mm:ss"  ;
}

+(NSString *) SatnderFromate_12H
{
    // return @"MM/dd/yyyy HH:mm:ss"  ;
      return @"yyyy-MM-dd hh:mm a"  ;
}

+(NSString *) SatnderFromate_date
{
  
      return @"yyyy-MM-dd"  ;
}


+(NSString *) GetTimeINMS
{
    
     NSDate *dt_utc = [self GetDateNow_date];
  
    NSString *st = [NSString stringWithFormat:@"%.0f", [dt_utc timeIntervalSince1970]  ];

//    NSString *st = [NSString stringWithFormat:@"%.0f", [dt_utc timeIntervalSince1970] * 1000];
    return st;
    
}

+(NSString *)getTimeStringFromSeconds:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}
+(NSString *)TimeRemainingUntilDate:(NSTimeInterval  )interval return_days:(BOOL)return_days return_hours:(BOOL)return_hours return_minutes:(BOOL)return_minutes
{
    
     NSString * timeRemaining = nil;
    
    if (interval > 0) {
        
        div_t d = div(interval, 86400);
        int day = d.quot;
        div_t h = div(d.rem, 3600);
        int hour = h.quot;
        div_t m = div(h.rem, 60);
        int min = m.quot;
        
        NSString * nbday = nil;
        if(day > 1)
            nbday = @" days";
        else if(day == 1)
            nbday = @"day";
        else
            nbday = @"";
        NSString * nbhour = nil;
        if(hour > 1)
            nbhour = @" hours";
        else if (hour == 1)
            nbhour = @" hour";
        else
            nbhour = @"";
        NSString * nbmin = nil;
        if(min > 1)
            nbmin = @" mins";
        else
            nbmin = @" min";
        
         if (return_days == YES) {
            timeRemaining = [NSString stringWithFormat:@"%@%@" ,   [NSNumber numberWithInt:day] ,@"d" ];
        }
        
        if (return_hours == YES) {
            timeRemaining = [NSString stringWithFormat:@"%@%@%@",timeRemaining,   [NSNumber numberWithInt:hour] ,@"h" ];
        }
        
        if (return_minutes == YES) {
            timeRemaining = [NSString stringWithFormat:@"%@%@%@",timeRemaining,   [NSNumber numberWithInt:min] ,@"m" ];
        }
        
        
//        if (return_days == YES && return_hours==YES && return_minutes==YES) {
//                timeRemaining = [NSString stringWithFormat:@"%@%@ %@%@ %@%@",day ? [NSNumber numberWithInt:day] : @"",nbday,hour ? [NSNumber numberWithInt:hour] : @"",nbhour,min ? [NSNumber numberWithInt:min] : @"00",nbmin];
//        }
        
  
    }
    else
        timeRemaining = nil;
    
    return timeRemaining;
}

+(double) GetTimeINMS:(NSDate *) dt_utc
{
    
    return   [dt_utc timeIntervalSince1970] * 1000 ;
    
    
}

+(NSString *) GetTimeINMS_str:(NSDate *) dt_utc
{
    
    return  [NSString stringWithFormat:@"%.0f", [dt_utc timeIntervalSince1970] * 1000 ];
    
    
}

+(NSString *) GetYear
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    
    return  yearString  ;
}

//Begining of Week Date

+  (NSDate*) beginingOfWeekOfDate{
    NSDate *now = [NSDate date];

    NSCalendar *tmpCalendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [tmpCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfYear|NSCalendarUnitWeekday fromDate:now];//get the required calendar units
    
    NSInteger weekday = tmpCalendar.firstWeekday;
    components.weekday = weekday; //weekday
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    
    NSDate *fireDate = [tmpCalendar dateFromComponents:components];
    
    return fireDate;
}

//End of Week Date

+(NSDate *)endOfWeekFromDate{
     NSDate *now = [NSDate date];
    
    NSCalendar *tmpCalendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [tmpCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfYear|NSCalendarUnitWeekday fromDate:now];//get the required calendar units
    
    int weekday = 7; //Saturday
    if (tmpCalendar.firstWeekday != 1) {
        weekday = 1;
    }
    components.weekday = weekday;//weekday
    components.hour = 23;
    components.minute = 59;
    components.second = 59;
    
    NSDate *fireDate = [tmpCalendar dateFromComponents:components];
    
    return fireDate;
}


+(NSDictionary *) getdate_In_dic:(NSString *) date formate:(NSString *) fromate
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:fromate];
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormat setTimeZone:timeZone];
    
    NSDate *currentDate = [[NSDate alloc] init];
    currentDate = [dateFormat dateFromString:date];
    
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate]; // Get necessary date components
    
    [components month]; //gives you month
    [components day]; //gives you day
    [components year]; // gives you year
 

    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject: [NSString stringWithFormat:@"%ld",(long)[components day]] forKey:@"day"];
    [dic setObject: [NSString stringWithFormat:@"%ld",(long)[components month]] forKey:@"month"];
    [dic setObject: [NSString stringWithFormat:@"%@",[self MonthNameString:(int) [components month] ]] forKey:@"month_name"];
        [dic setObject: [NSString stringWithFormat:@"%@",[self MonthNameString_short:(int) [components month] ]] forKey:@"month_name_short"];

    [dic setObject: [NSString stringWithFormat:@"%ld",(long)[components year]] forKey:@"year"];

    
    return dic;
}

+(NSString*)MonthNameString:(int)monthNumber
{
    NSDateFormatter *formate = [NSDateFormatter new];
    
    NSArray *monthNames = [formate standaloneMonthSymbols];
    
    NSString *monthName = [monthNames objectAtIndex:(monthNumber - 1)];
    
    return monthName;
}
+(NSString*)MonthNameString_short:(int)monthNumber
{
    NSDateFormatter *formate = [NSDateFormatter new];
    
    NSArray *monthNames = [formate shortStandaloneMonthSymbols];
    
    NSString *monthName = [monthNames objectAtIndex:(monthNumber - 1)];
    
    return monthName;
}

+(int) ConvertDateToTimeStamp :(NSString *) dateString dateFormate:(NSString *) dateFormate timeZone:(NSTimeZone *) timeZone
{
  
    
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    [df setDateFormat:dateFormate];
    [df setTimeZone:timeZone];

//    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    NSDate *date = [df dateFromString:dateString];
    
    NSTimeInterval since1970 = [date timeIntervalSince1970]; // January 1st 1970
    
//    int result = since1970 * 1000;
    
    
    
    return since1970;
}

+(NSString *) ConvertTimeStampTodate :(NSString *) timeStampString returnFormate:(NSString *) returnFormate timeZone:(NSTimeZone *) timeZone
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:returnFormate];
    
//    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    
    NSTimeInterval _interval=[timeStampString doubleValue]  ;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    
    
    
    
    return formattedDateString;
}

+(NSString *) ConvertTimeStampTodate :(NSString *) timeStampString returnFormate:(NSString *) returnFormate
{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:returnFormate];
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
//    [dateFormatter setTimeZone:timeZone];
    
//    NSTimeInterval _interval=[timeStampString doubleValue]  ;
//
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
//
//    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    
    
    
    
    return [self ConvertTimeStampTodate:timeStampString returnFormate:returnFormate timeZone:timeZone];
}

+(NSString *) ConvertTimeStampTodate :(NSString *) timeStampString
{
    return  [self ConvertTimeStampTodate:timeStampString returnFormate:[self SatnderFromate]];
    
}

+(NSString *) GetlocalTime:(NSString *)dt  
{

    // create dateFormatter with UTC time format
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[self SatnderFromate]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *date = [dateFormatter dateFromString:dt]; // create date from string
    
    // change to a readable time format and change to local time zone
    [dateFormatter setDateFormat:[self SatnderFromate]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *timestamp = [dateFormatter stringFromDate:date];
    
    
    return timestamp;
}

+(NSString *) GetlocalTimeFrom_timeStamp:(NSString * ) timestamp
{
    NSString *dt = [self ConvertTimeStampTodate:timestamp];
    NSString *localdate = [self  GetlocalTime:dt];
    
    return   localdate;
}
+(NSString *) GetlocalTimeFrom_timeStamp:(NSString * ) timestamp  Formate:(NSString *)Formate
{
    
    NSString *dt = [self ConvertTimeStampTodate:timestamp];
    NSString *localdate = [self  GetlocalTime:dt Formate:Formate];

   return   localdate;
    
    
}


+(NSString *) GetlocalTimeFromtimeStamp:(NSString *)dt
{
    
    NSString *timedate = [self ConvertTimeStampTodate:dt];
    
    NSString *localdate = [self GetlocalTime:timedate];
    
    
    return localdate;
}


+(NSString *) GetlocalTime:(NSString *)dt Formate:(NSString *)Formate
{
    
    // create dateFormatter with UTC time format
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[self SatnderFromate]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *date = [dateFormatter dateFromString:dt]; // create date from string
    
    // change to a readable time format and change to local time zone
    [dateFormatter setDateFormat:Formate];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *timestamp = [dateFormatter stringFromDate:date];
    
    
    return timestamp;
}


+(NSString *) GetDateNow:(NSString *)Formate timeZone:(NSTimeZone *) timeZone
 {
        
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        
        [dateFormat setTimeZone:timeZone];
        [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [dateFormat setDateFormat:Formate];
        NSString *dateString = [dateFormat stringFromDate:date];
        // NSLog(@"%@" ,dateString) ;
        
        
        
        return dateString;
}
    
+(NSString *) GetDateNow:(NSString *)Formate
{
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormat setTimeZone:timeZone];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormat setDateFormat:Formate];
    NSString *dateString = [dateFormat stringFromDate:date];
    // NSLog(@"%@" ,dateString) ;
    
    
    
    return dateString;
}

+(NSDate *) GetDateNow_date
{
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:[ClassDate SatnderFromate]];
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormat setTimeZone:timeZone];
    
    
    NSString *dateString = [dateFormat stringFromDate:date];
    // NSLog(@"%@" ,dateString) ;
    
    NSDate *date2 = [dateFormat dateFromString:dateString];
    
    
    return date2;
}


+(NSString *) GetDateNow_local:(NSString *) formate
{
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:formate];
//    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSLocale *locale = [NSLocale currentLocale];

    [dateFormat setLocale:locale];

    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormat setTimeZone:timeZone];
    
    
    NSString *dateString = [dateFormat stringFromDate:date];
    // NSLog(@"%@" ,dateString) ;
    
    
    
    return dateString;
}

+(NSString *) GetDateNow_local
{
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:[ClassDate SatnderFromate]];
//    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSLocale *locale = [NSLocale currentLocale];

    [dateFormat setLocale:locale];

    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormat setTimeZone:timeZone];
    
    
    NSString *dateString = [dateFormat stringFromDate:date];
    // NSLog(@"%@" ,dateString) ;
    
    
    
    return dateString;
}


+(NSDate *) getDateNowLocal
{
    NSDate *date = [NSDate date];
    
    NSDate *someDateInUTC = date;
    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSDate *dateInLocalTimezone = [someDateInUTC dateByAddingTimeInterval:timeZoneSeconds];
    
    return  dateInLocalTimezone;
}

+(NSString *) GetDateNow
{
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
     [dateFormat setDateFormat:[ClassDate SatnderFromate]];
     [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormat setTimeZone:timeZone];
    
   
    NSString *dateString = [dateFormat stringFromDate:date];
    // NSLog(@"%@" ,dateString) ;
    
    
    
    return dateString;
}


+(NSString *) GetDateWithFormate:(NSString *) dt Formate:(NSString *)Formate ReturnFormate:(NSString *)ReturnFormate
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:Formate];
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormat setTimeZone:timeZone];
    
    NSDate *dtnow = [[NSDate alloc] init];
    dtnow = [dateFormat dateFromString:dt];
    
    NSDateFormatter *dfTime = [NSDateFormatter new];
    [dfTime setDateFormat:ReturnFormate];
    NSString *date=[dfTime stringFromDate:dtnow];
    
    return date;
}

+(NSString *) GetDateWithFormate:(NSString *) dt Formate:(NSString *)Formate ReturnFormate:(NSString *)ReturnFormate Use_UTC:(BOOL)Use_UTC
{
    NSDateFormatter *dateFormat =[NSDateFormatter new];
    [dateFormat setDateFormat:Formate];
    
    if (Use_UTC == YES) {
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [dateFormat setTimeZone:timeZone];
    }

    
    NSDate *dtnow = [[NSDate alloc] init];
    dtnow = [dateFormat dateFromString:dt];
    
    NSDateFormatter *dfTime = [NSDateFormatter new];
    [dfTime setDateFormat:ReturnFormate];
    NSString *date=[dfTime stringFromDate:dtnow];
    
    return date;
}

+(NSDate *) GetDate:(NSString *) dt
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:Formate];
//
//    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
//    [dateFormat setTimeZone:timeZone];
    
    NSDate *dtnow = [[NSDate alloc] init];
    dtnow = [dateFormat dateFromString:dt];
    
       return dtnow;
}

+(NSDate *) GetDate:(NSString *) dt Formate:(NSString *)Formate
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:Formate];
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormat setTimeZone:timeZone];
    
    NSDate *dtnow = [[NSDate alloc] init];
    dtnow = [dateFormat dateFromString:dt];
    
       return dtnow;
}

+(NSString *)  DateToString:(NSDate *) dt
{
    
    NSDateFormatter *dfTime = [NSDateFormatter new];
   
    NSString *date=[dfTime stringFromDate:dt];
    
    return date;
}
+(NSString *)  DateToString:(NSDate *) dt   ReturnFormate:(NSString *)ReturnFormate
{
    
    NSDateFormatter *dfTime = [NSDateFormatter new];
    [dfTime setDateFormat:ReturnFormate];
    NSString *date=[dfTime stringFromDate:dt];
    
    return date;
}

+(NSString *) GetDateOnly:(NSString *) dt Formate:(NSString *)Formate ReturnFormate:(NSString *)ReturnFormate
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:Formate];
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormat setTimeZone:timeZone];
    
     NSDate *dtnow = [[NSDate alloc] init];
    dtnow = [dateFormat dateFromString:dt];
    
    NSDateFormatter *dfTime = [NSDateFormatter new];
    [dfTime setDateFormat:ReturnFormate];
    NSString *date=[dfTime stringFromDate:dtnow];
 
    return date;
}

+(NSString *) GetTimeOnly:(NSString *) dt Formate:(NSString *)Formate ReturnFormate:(NSString *)ReturnFormate
{
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:Formate];
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [timeFormat setTimeZone:timeZone];
    
    NSDate *dtnow = [[NSDate alloc] init];
    dtnow = [timeFormat dateFromString:dt];
    
    NSDateFormatter *dfTime = [NSDateFormatter new];
    NSTimeZone *timeZone2 = [NSTimeZone timeZoneWithName:@"UTC"];
    [dfTime setTimeZone:timeZone2];
    
    [dfTime setDateFormat:ReturnFormate];
    NSString *time=[dfTime stringFromDate:dtnow];
    
    return time;
}

+(int) CompareTwoDate:(NSString *) dt1_old dt2_new:(NSString *)dt2_new Formate:(NSString *)Formate
{

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:Formate];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [df setTimeZone:timeZone];
    
    
    NSDate *dtlastupdate = [[NSDate alloc] init];
    NSDate *dtnow = [[NSDate alloc] init];
    
    dtlastupdate = [df dateFromString:dt1_old];
    dtnow = [df dateFromString:dt2_new];
    
    
    int t=  [dtnow timeIntervalSinceDate:dtlastupdate] ;
    
    return t;


}


+(int) CompareTimeStamp:(NSString *) dt1_old dt2_new:(NSString *)dt2_new
{
    int x = [dt2_new doubleValue] - [dt1_old doubleValue];
    
    return x;
    
    
}

@end
