//
//  KBaseObject.h
//  KLib
//
//  Created by khaled on 1/25/17.
//  Copyright © 2017 com.greatideas4ap. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^KBaseObject_data)(id data);

@interface KBaseObject : NSObject

- (id)initWith:(NSDictionary *) dic;
@property (nonatomic, copy) KBaseObject_data completionBlock;

-(NSDictionary *) toDic;
-(NSString *) toString;

-(id) toClass:(NSDictionary *)dic;
-(id) toClass_str:(NSString *)str;

-(void) saveClass;
-(id) getClass;


+(NSDictionary *) toDic :(id) cls;
+(NSString *) toString :(id) cls;

+(id) toClass:(NSDictionary *)dic  cls:(id) cls;
+(id) toClass_str:(NSString *)str  cls:(id) cls;


@end
