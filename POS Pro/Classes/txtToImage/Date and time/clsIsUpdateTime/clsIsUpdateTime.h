//
//  clsIsUpdateTime.h
//  twitterSearch
//
//  Created by khaled on 1/1/14.
//  Copyright (c) 2014 greatidea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KObject.h"
@interface clsIsUpdateTime : KObject
+(void) Setlastupdate:(NSString *)itemname key:(NSString *) key;
+(BOOL) isTimeTopdate:(int) timetoreloadcash itemname:(NSString *)itemname key:(NSString *) key;

@end
