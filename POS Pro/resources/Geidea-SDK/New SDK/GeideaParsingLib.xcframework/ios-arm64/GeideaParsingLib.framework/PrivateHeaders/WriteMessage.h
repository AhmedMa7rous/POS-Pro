//
//  WriteMessage.h
//  TCP_IP
//
//  Created by Rajat Agarwal on 23/04/18.
//  Copyright © 2018 GEIDEA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WriteMessage : NSObject {
    NSMutableArray *ReceivedBuffer;
    NSMutableArray *splitArray;
    NSInteger incrementNum;
    
}

-(NSMutableData*)authorize ;
-(NSMutableData*)checkCommunication ;
-(NSMutableData*)sendPurchaseTransaction : (NSString * )dataToSendText;
-(NSMutableData*)sendReconciliation ;
-(NSMutableData*)sendRefund : (NSString *)dataToRefundText forDate: (NSString *)Date forRRN: (NSString *)RRN;
-(NSMutableData*)sendRefund : (NSString *)dataToRefundText forDate: (NSString *)Date forRRN: (NSString *)RRN CardNo:(NSString *)CardNo;
-(NSMutableData*)sendReversal ;

@end
