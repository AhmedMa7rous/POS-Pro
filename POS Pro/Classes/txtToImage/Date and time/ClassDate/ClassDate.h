//
//  ClassDate.h
//  KLib
//
//  Created by ebad3 on 10/23/15.
//  Copyright © 2015 com.greatideas4ap. All rights reserved.
//

#import <Foundation/Foundation.h>
 
@interface ClassDate : NSObject

+(NSString *) GetlocalTime:(NSString *)dt;
+(NSString *) GetlocalTime:(NSString *)dt Formate:(NSString *)Formate;

+ (NSDate*) beginingOfWeekOfDate;
+(NSDate *)endOfWeekFromDate;

+(NSString *)  DateToString:(NSDate *) dt;
+(NSString *)  DateToString:(NSDate *) dt   ReturnFormate:(NSString *)ReturnFormate;

+(NSString *) serverFromate;
+(NSString *) SatnderFromate;
+(NSString *) SatnderFromate_12H;
+(NSString *) SatnderFromate_date;

+(NSString *) GetDateNow;
+(NSDate *) getDateNowLocal;
+(NSString *) GetDateNow_local;
+(NSString *) GetDateNow_local:(NSString *) formate;

+(double) GetTimeINMS:(NSDate *) dt_utc;
+(NSString *) GetTimeINMS_str:(NSDate *) dt_utc;

+(NSString *) GetTimeINMS;
+(NSString *) GetlocalTimeFrom_timeStamp:(NSString * ) timestamp;
+(NSString *) GetlocalTimeFrom_timeStamp:(NSString * ) timestamp  Formate:(NSString *)Formate;

+(NSString *) GetlocalTimeFromtimeStamp:(NSString *)dt;
+(NSString *) GetDateNow:(NSString *)Formate;
+(NSString *) GetDateNow:(NSString *)Formate timeZone:(NSTimeZone *) timeZone;

+(int) CompareTwoDate:(NSString *) dt1_old dt2_new:(NSString *)dt2_new Formate:(NSString *)Formate;
+(int) CompareTimeStamp:(NSString *) dt1_old dt2_new:(NSString *)dt2_new;

+(NSString *) ConvertTimeStampTodate :(NSString *) timeStampString;
+(NSString *) ConvertTimeStampTodate :(NSString *) timeStampString returnFormate:(NSString *) returnFormate;

+(int) ConvertDateToTimeStamp :(NSString *) dateString dateFormate:(NSString *) dateFormate timeZone:(NSTimeZone *) timeZone;
+(NSString *) ConvertTimeStampTodate :(NSString *) timeStampString returnFormate:(NSString *) returnFormate timeZone:(NSTimeZone *) timeZone;

+(NSString *) GetDateWithFormate:(NSString *) dt Formate:(NSString *)Formate ReturnFormate:(NSString *)ReturnFormate;
+(NSString *) GetDateWithFormate:(NSString *) dt Formate:(NSString *)Formate ReturnFormate:(NSString *)ReturnFormate Use_UTC:(BOOL)Use_UTC;

//+(NSString *) GetDateOnly:(NSString *) dt Formate:(NSString *)Formate ReturnFormate:(NSString *)ReturnFormate;
//+(NSString *) GetTimeOnly:(NSString *) dt Formate:(NSString *)Formate ReturnFormate:(NSString *)ReturnFormate;

+(NSString *) GetYear;
+(NSDictionary *) getdate_In_dic:(NSString *) date formate:(NSString *) fromate;

+(NSString*)MonthNameString:(int)monthNumber;
+(NSDate *) GetDate:(NSString *) dt;
+(NSDate *) GetDate:(NSString *) dt Formate:(NSString *)Formate;
+(NSString *)getTimeStringFromSeconds:(int)totalSeconds;
+(NSString *)TimeRemainingUntilDate:(NSTimeInterval  )interval return_days:(BOOL)return_days return_hours:(BOOL)return_hours return_minutes:(BOOL)return_minutes;

@end
