//
//  SP530ConfMcp.h
//  SP530Core
//
//  Created by spectra on 18/7/2016.
//  Copyright © 2016 Spectra Technologies Holdings Company Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define S3_MCP_CFG_CA_KEY_IDX_CH_1          @"10CA0000"
#define S3_MCP_CFG_CLIENT_CERT_KEY_IDX_CH_1 @"00CA0000"

#define S3_MCP_CFG_CA_KEY_IDX_CH_2          @"11CA0000"
#define S3_MCP_CFG_CLIENT_CERT_KEY_IDX_CH_2 @"00CA0000"

struct MCP_Cfg_t {
    unsigned char ip[4];
    uint16_t port;
    uint8_t conne_timeout;
    unsigned char pad_dummy;
    unsigned char ssl_status[4];
    unsigned char ca_key_idx[4];
    unsigned char client_cert_key_idx[4];
};


@interface SP530ConfMcp : NSObject
{
    
}

@property(retain, nonatomic) NSString *IP_Addr;
@property(assign, nonatomic) int Port;
@property(assign, nonatomic) int Conn_Timeout;
@property(assign, nonatomic) bool EnableSSL;
@property(assign, nonatomic) int Channel_Num;
@property(retain, nonatomic) NSString *CA_Key_Idx;
@property(retain, nonatomic) NSString *Clent_Cert_Key_Idx;

-(id)init;
-(id)initWithCfgStr:(NSString *)ARawCfgStr;
-(NSString *)getCfgStr;
-(NSString *)setCfgFrmStr:(NSString *)ARawCfgStr ChannelNum:(int)AChannel_Num;

@end
