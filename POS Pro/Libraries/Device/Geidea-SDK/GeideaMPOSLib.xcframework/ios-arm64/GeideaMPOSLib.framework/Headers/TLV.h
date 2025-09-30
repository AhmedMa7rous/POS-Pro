//
//  TLV.h
//  SP530Core
//
//  Created by spectra on 8/12/2015.
//  Copyright © 2015 Spectra Technologies Holdings Company Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    tlv_b=0,
    tlv_n=1,
    tlv_cn=2,
    tlv_an=3,
    tlv_ans=4
} TLV_t;

@interface TLV : NSObject
{
    
}

-(id)init;

@property(retain, nonatomic)NSString *Code;
@property(assign, nonatomic)TLV_t DataType;
@property(assign, nonatomic)int Len;
@property(retain, nonatomic)NSString *StrVal;
@property(retain, nonatomic)NSString *Description;

@end
