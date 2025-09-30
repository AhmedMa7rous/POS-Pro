//
//  TxResponse.h
//  SP530 Hulk
//
//  Created by spectra on 29/7/15.
//  Copyright (c) 2015 Spectra Technologies Holdings Company Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TxResponse : NSObject<NSCoding, NSCopying>
{
    
}

@property(retain, nonatomic)NSString *MID;
@property(retain, nonatomic)NSString *TID;
@property(retain, nonatomic)NSString *CardholderName;
@property(retain, nonatomic)NSString *MarkedCardNum;
@property(retain, nonatomic)NSString *Acquirer;
@property(retain, nonatomic)NSString *CardExpirtDate;
@property(retain, nonatomic)NSString *TransType;
@property(retain, nonatomic)NSString *CompleteDate;
@property(retain, nonatomic)NSString *BatchNum;
@property(retain, nonatomic)NSString *TransTraceCode;
@property(retain, nonatomic)NSString *RRN; //Reference Retrieval No. unique No. bank for a merchant. Trace original Tx Date
@property(retain, nonatomic)NSString *ApprovalCode;
@property(retain, nonatomic)NSString *AppName;  //Application Name
@property(retain, nonatomic)NSString *AID;      //Application ID
@property(retain, nonatomic)NSString *TC;
@property(retain, nonatomic)NSString *RefECR;
@property(assign, nonatomic)unsigned char ResponseCode;


@property(assign, nonatomic)BOOL NeedSignature;
@property(retain, nonatomic)NSString *ApprovalType;

-(id)init;

@end
