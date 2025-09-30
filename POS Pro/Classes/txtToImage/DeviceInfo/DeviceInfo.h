//
//  DeviceInfo.h
//  KLib
//
//  Created by khaled on 12/26/14.
//  Copyright (c) 2014 com.greatideas4ap. All rights reserved.
//
/*
 
 4-inch   (640x1136 )   320 * 568  ( iPhone SE )
 4.7-inch (750x1334 )   375 * 667  ( iPhone 6s , iPhone 7 , iPhone 8 )
 5.5-inch (1080x1920)   414 * 736  ( iPhone 7 Plus , iPhone 6s Plus ,iPhone 8 Plus )
 5.8-inch (1125x2436)   375 * 812  ( iPhone X ,iPhone XS)
 6.1-inch (828x1792 )   414 * 896  ( iPhone XR )
 6.5-inch (1242x2688)   414 * 896  ( iPhone XS Max )
 
 */



#import <UIKit/UIKit.h>

@interface DeviceInfo : UIDevice
+ (NSString *) Platform;
+ (NSString *) PlatformString;
+ (BOOL) HasRetinaDisplay;
+(CGRect) ScreenRect;

+(BOOL) IsIpad;
+(BOOL) IsIphone4;
+(BOOL) IsIphone5;
+(BOOL) IsIphone6;
+(BOOL) IsIphone6Plus;
+(BOOL) IsIphone7;
+(BOOL) IsIphone10 ;

+(BOOL) IsIphone_4_inch;
+(BOOL) IsIphone_4_7_inch;
+(BOOL) IsIphone_5_5_inch;
+(BOOL) IsIphone_5_8_inch;
+(BOOL) IsIphone_6_1_inch;

- (BOOL)hasMultitasking;

@end
