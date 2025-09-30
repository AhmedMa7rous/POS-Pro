//
//  KBaseObject.m
//  KLib
//
//  Created by khaled on 1/25/17.
//  Copyright © 2017 com.greatideas4ap. All rights reserved.
//

#import "KBaseObject.h"
#import "JAGPropertyConverter.h"
//#import "myuserdefaults.h"
#import "JsonToDictionary.h"
@interface KBaseObject()
{
 

}
@end

@implementation KBaseObject

//- (id)initWith:(NSDictionary *) dic
//{
//    self = [super init];
//    
//    if (self)
//    {
//        self = [self toClass:dic];
//    }
//    
//    return self;
//}
//-(NSDictionary *) toDic
//{
//    
//    JAGPropertyConverter *converter = [[JAGPropertyConverter alloc]init];
//    converter.classesToConvert = [NSSet setWithObjects:[self class], nil];
//    
//    NSDictionary *dictPerson = [converter convertToDictionary:self];
//    
//    
//    return dictPerson;
//
//}
//
//-(NSString *) toString
//{
//    
//    JAGPropertyConverter *converter = [[JAGPropertyConverter alloc]init];
//    converter.classesToConvert = [NSSet setWithObjects:[self class], nil];
//    
//    NSDictionary *dictPerson = [converter convertToDictionary:self];
//    
//    
//    return [JsonToDictionary jsonStringFromDictionary:dictPerson];
//    
//}
//
//
//+(NSDictionary *) toDic :(id) cls
//{
//    
//    JAGPropertyConverter *converter = [[JAGPropertyConverter alloc]init];
//    converter.classesToConvert = [NSSet setWithObjects:[cls class], nil];
//    
//    NSDictionary *dictPerson = [converter convertToDictionary:cls];
//    
//    
//    return dictPerson;
//    
//}
//
//+(NSString *) toString :(id) cls
//{
//    
//    JAGPropertyConverter *converter = [[JAGPropertyConverter alloc]init];
//    converter.classesToConvert = [NSSet setWithObjects:[cls class], nil];
//    
//    NSDictionary *dictPerson = [converter convertToDictionary:cls];
//    
//    
//    return [JsonToDictionary jsonStringFromDictionary:dictPerson];
//    
//}
//
//
//
//
//-(id) toClass:(NSDictionary *)dic
//{
//    
//    JAGPropertyConverter *converter = [[JAGPropertyConverter alloc]init];
//    converter.classesToConvert = [NSSet setWithObjects:[self class], nil];
//    
//   // [self class] *cls = [[[self class] alloc] init];
//    
//    [converter setPropertiesOf:self fromDictionary:dic];
//    
//    
//    return self;
//    
//}
//
//-(id) toClass_str:(NSString *)str
//{
//    NSDictionary *dic  = [JsonToDictionary diccionaryFromJsonString:str];
//
//    return [self toClass:dic];
//}
//
//
//+(id) toClass:(NSDictionary *)dic cls:(id) cls
//{
//    
//    JAGPropertyConverter *converter = [[JAGPropertyConverter alloc]init];
//    converter.classesToConvert = [NSSet setWithObjects:[cls class], nil];
//    
//    // [self class] *cls = [[[self class] alloc] init];
//    
//    [converter setPropertiesOf:cls fromDictionary:dic];
//    
//    
//    return self;
//    
//}
//
//+(id) toClass_str:(NSString *)str cls:(id) cls
//{
//    NSDictionary *dic  = [JsonToDictionary diccionaryFromJsonString:str];
//    
//    return [KBaseObject toClass:dic cls:cls];
//}
//
//-(NSString *) className
//{
//    return NSStringFromClass([self class]);
//}
//
//-(void) saveClass
//{
//    
//    NSDictionary *dic = self.toDic;
//    
//    
//    [myuserdefaults Setitems:[self className] SetValue:dic Prefix:@"KBaseObject"];
//    
//}
//
//-(id) getClass
//{
//   
//    NSDictionary *dic = [myuserdefaults getitem:[self className] Prefix:@"KBaseObject"];
//   
//    return [self toClass:dic];
//    
//    
//    
//}


@end
