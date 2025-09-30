//
//  TxDetails.h
//  SP530 Hulk
//
//  Created by spectra on 29/7/15.
//  Copyright (c) 2015 Spectra Technologies Holdings Company Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionBase.h"
#import "TxResponse.h"
#import "TxRequest.h"


@interface TxDetails : TransactionBase
{
    
}

-(id)init;

@property(assign, nonatomic)NSString *TransID;  //iOS Apps TransID :: Device Type+ UUID + 000000 digital
@property(retain, nonatomic)NSDate *TransDate;
@property(retain, nonatomic)NSString *CasherName;
@property(retain, nonatomic)TxRequest *TransRequest;
@property(retain, nonatomic)TxResponse *TransResponse;

@property(retain, nonatomic)NSMutableDictionary *TransEMVTags;

@end
