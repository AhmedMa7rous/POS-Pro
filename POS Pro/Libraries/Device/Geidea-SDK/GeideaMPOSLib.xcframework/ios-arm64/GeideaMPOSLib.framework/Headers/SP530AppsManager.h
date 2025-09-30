//
//  SP530AppsManager.h
//  SP530Core
//
//  Created by spectra on 22/2/2016.
//  Copyright © 2016 Spectra Technologies Holdings Company Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SP530AppsManager.h"

//**** Command ****//
#ifndef S3INS_NUM_TMSDL
#define S3INS_NUM_TMSDL         0x30
#define S3INS_TMSDL             0x31
#define S3INS_TMSDLRESULT       0x32
#define S3INS_APPINFO           0x33
#define S3INS_DATADL            0x34
#endif

//**** Data Packet Setting ****//
#define S3_APPS_MGR_TMS_INFO_DAT_LEN    38
#define S3_APPS_MGR_DATA_HEADER_SIZE    1
#define S3_APPS_MGR_DATA_BLOCK_SIZE     1016
#define S3_TMS_HEADER_SECTION_END_TAG   @"%\r"

#ifndef S3RC_OK

//**** Transaction Resposne Code ****
#define S3RC_OK         0x00
#define S3RC_CANCEL     0x40
#define S3RC_TIMEOUT	0x41
#define S3RC_MORE_CARDS	0x42
#define S3RC_ERR        0x80
#define S3RC_ERR_CSUM	0x81
#define S3RC_ERR_DATA	0x82
#define S3RC_ERR_FMT	0x83
#define S3RC_ERR_MEM	0x84
#define S3RC_ERR_KEY	0x85
#define S3RC_ERR_INS	0x86
#define S3RC_ERR_KVC	0x87
#define S3RC_ERR_SEQ	0x88
#define S3RC_ERR_PREL	0x89

#endif

typedef struct{
    unsigned char Name[12];
    unsigned char dummy1;
    unsigned char Version[3];
    unsigned char dummy2;
    unsigned char SubVersion[2];
    unsigned char dummy3;
    unsigned char RealChecksum[8];
    unsigned char dummy4;
    unsigned char DisplayChecksum[8];
}T_S3_TERMINAL_APP_INFO;



@protocol SP530AppsManagerDelegate <NSObject>

@required

-(void)didSP530AppsManagerBuildAppsListCompleted:(bool)aSuccessFlag;

@optional
@end

@interface SP530AppsManager : NSObject
{
}

/**
 *  @discussion initizate the class object
 */
-(id)init;

/**
 *  @discussion Decode the Application list information from SP530 and encapsulate in the SP530AppsInfo class object.
 *  The result are stored in the AppsInfoList property
 *  @param The Applications Information returned from the SP530 in binary format.
 */
-(void)buildAppsListWithData:(NSData *)aDataBlock;

/**
 *  @discussion get TMS header from the TMS file.
 *  @param aTMSBinContent - The content of the TMS file
 *  @return The last line of the TMS header in the TMS file
 */
-(NSString *)getTMSHeaderWithData:(NSData *)aTMSBinContent;


#pragma mark Property

@property(weak, nonatomic) id <SP530AppsManagerDelegate> delegate;

/**
 *  @discussion The TMS Application list and TMS application detail is encapulated in the SP530AppsInfo class.
 */
@property(strong, nonatomic)NSMutableArray *AppsInfoList;

@end
