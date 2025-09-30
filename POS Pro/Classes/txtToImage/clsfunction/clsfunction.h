//
//  clsfunction.h
//  arabia
//
//  Created by khaled on 3/31/14.
//  Copyright (c) 2014 abda3. All rights reserved.
//

#import <Foundation/Foundation.h>
 #import <UIKit/UIKit.h>
#import "KObject.h"

@interface clsfunction : KObject
+(NSString *) getTextEmoj:(NSString*) str;
+(NSString *) readvalue:(id) value;
+(NSString *) StringInNav:(NSString *) str;
+ (CGSize)sizeOfStringWithFont:(NSString *) txt font:(UIFont *)font;
+(CGSize) StringSize :(NSString *) txt font:(UIFont *) font maxWidth:(int)maxWidth;
+(CGSize)sizeOfStringWithFont:(NSString *) txt font:(UIFont *)font constrainedToSize:(CGSize)size;

+(NSString *)timeFormatted:(int)totalSeconds;

+(NSArray *) readnitmes :(NSArray *) json count:(int)count;

@end
