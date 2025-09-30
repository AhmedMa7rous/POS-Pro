//
//  MutualAuth.h
//  SP530 Demo
//
//  Created by spectra on 10/8/15.
//  Copyright (c) 2015 Spectra Technologies Holdings Company Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

//**** General Class Type Commands (0x0X) ****//
#define	S3INS_INIT_MODE     0x01
#define	S3INS_INIT_AUTH     0x02
#define	S3INS_MUTU_AUTH     0x03

#define MUTU_AUTH_KTYPE_MRMK    0x00
#define MUTU_AUTH_KTYPE_RMK     0x01

typedef struct sp530_app_auth_rrand
{
    unsigned char RRand_L[4];
    unsigned char RRand_H[4];
}sp530_app_auth_rrand;                   //Reader Random number

typedef struct sp530_app_auth_trand
{
    unsigned char TRand_L[4];
    unsigned char TRand_H[4];
}sp530_app_auth_trand;                   //Terminal Random


typedef struct sp530_app_init_auth_response
{
    unsigned char response_code;
    unsigned char key_type;
    unsigned char key_Idx;
    sp530_app_auth_rrand RRand;
    unsigned char EncRand[16];
}sp530_app_init_auth_response;

@interface MutualAuth : NSObject
{
    
}

@property(assign, nonatomic)unsigned char SelectedKeyType;      //Master Reader Message Key
@property(retain, nonatomic)NSString *MRMK;                     //Master Reader Message Key
@property(retain, nonatomic)NSString *RMK;                      //Reader Message Key
@property(assign, nonatomic)unsigned char AuthMode;
@property(assign, nonatomic)unsigned char MRMK_index;
@property(assign, nonatomic)unsigned char RMK_index;
@property(retain, nonatomic)NSString *TRand;                    //Terminal Random Number (TRand)
@property(retain, nonatomic)NSMutableData *SessionKey;
@property(assign, nonatomic)sp530_app_auth_rrand RRand;         //Encrypt Reader Random Number (RRand)
@property(assign, nonatomic)unsigned char MutualAuthResult;
-(id)init;

@end
