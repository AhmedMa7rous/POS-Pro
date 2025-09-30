//
//  Sort.h
//  aqa
//
//  Created by khaled on 11/14/13.
//  Copyright (c) 2013 abda3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KObject.h"
@interface Sort : KObject


+(NSDictionary *) sortdicBykeyAlphabetically:(NSDictionary *) dic;
+(NSDictionary *) array_from_Dictionary_Bykey:(NSArray *) arr keyindic:(NSString *)keyindic;
+(NSArray *) sort_array_of_dic_bykey:(NSArray *) array key:(NSString *) key  ascending:(BOOL)ascending;

+(NSArray *) sortArrAlphabetically:(NSArray *) arr;
+(NSArray *) sortArrAlphabetically_Desc:(NSArray *) arr;
+(NSArray *) sortArrNumber:(NSArray *)arr;

+(NSArray *) array_To_arrayOFarray :(NSArray *) json count:(int)count;
+(NSArray *) GetDistinctValues_from_Dictionary:(NSArray *) arr keyindic:(NSString *)keyindic;
+(NSArray *) ReversedArray :(NSArray *)arr;
+(NSArray *)  Random_Array :(NSArray *)arr;

@end
