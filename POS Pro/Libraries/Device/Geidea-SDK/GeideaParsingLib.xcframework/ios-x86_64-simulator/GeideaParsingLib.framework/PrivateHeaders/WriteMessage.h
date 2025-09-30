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
-(NSMutableData*)sendMessage : (NSString * )dataToSendText;
-(NSMutableData*)sendReconciliation ;

@end
