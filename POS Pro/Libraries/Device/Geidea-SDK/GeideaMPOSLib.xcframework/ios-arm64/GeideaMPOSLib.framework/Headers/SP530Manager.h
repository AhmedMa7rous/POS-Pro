//
//  SP530Manager.h
//  SP530 Demo
//
//  Created by spectra on 4/8/15.
//  Copyright (c) 2015 Spectra Technologies Holdings Company Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TxDetails.h"
#import "SP530Communicator.h"
#import "SP530AppsManager.h"
#import "MutualAuth.h"
#import "SP530ConfMcp.h"

/* Default Extended Sales Command */
#define S5_EMV_TX_CMD_SALES             @""
#define S5_EMV_TX_CMD_OFFLINE_SALE      @"FF000101"
#define S5_EMV_TX_CMD_REFUND            @"FF000102"
#define S5_EMV_TX_CMD_VOID              @"FF000103"
#define S5_EMV_TX_CMD_AUTH              @"FF000108"
#define S5_EMV_TX_CMD_SETTLEMENT        @"FF000109"

/* APM level Command */
#define S3INS_UPDMCPCHCFG       0x35
#define S3INS_REBOOTREQ         0x36

@class SP530Manager;

@protocol SP530ManagerDelegate <NSObject>

@required
/**
 *  @discussion Error occurred of transaction or the communication channels issues
 *  @param mErrMsg Description of the Error
 */
-(void)didSP530ErrFound:(NSString *)mErrMsg;

@optional

#pragma mark Load TMS (Callback)

//****************** Load TMS :: Begin - Version 1.2.0 ******************//

/**
 *  @discussion SP530 CH1 SSL Handshake status
 */
-(void)didSP530CH1SslHandshakeCompleted:(bool)Status;

/**
 *  @discussion Call back after received the TMS Application list from the SP530
 */
-(void)didSP530CompletedGetAppsList;

/**
 *  @discussion Call back after all TMS Applications to be loaded into the SP530
 */
-(void)didSP530CompletedLoadApps;

/**
 *  @discussion Call back - Check last Loading TMS Application Result
 *  @param output parameter with Error Code: Please refer to OSM document - os_adll_get_result() function
 */
-(void)didSP530CompletedChkLoadAppsWithResult:(NSString *)aResult;

/**
 *  @discussion Failed to load the Apps
 */
-(void)didSP530FailedLoadApps;

/**
 *  @discussion call back function.
 */
-(void)didSP530LoadingApps:(NSString *)aProgress;

/**
 *  @discussion call back function.
 */
-(void)didSP530LoadingAppsWithDownLoaded:(NSInteger)downLoaded total:(NSInteger)total;

//****************** Transaction API List  ******************//
#pragma mark Transaction (Callback)

/**
 *  @discussion (Lib v1.4.0) Call back function of the SP530Communicator. (DEPRECATED in Version 2)
 *  @param if mErrMsg is an empty string or null that mean success. Otherwise it returns error message to indicate connection failure
 *  @version 1
 */
-(void)didSP530Connected:(NSString *)mErrMsg
    __attribute__((deprecated("Deprecated in version 2, Please use didSP530Manager:ConnectedWithMsg:")));

/**
 *  @discussion (Lib v1.4.0) Call back function of the SP530Communicator.
 *  @param if mErrMsg is an empty string or null that mean success. Otherwise it returns error message to indicate connection failure
 *  @version 2
 */
-(void)didSP530Manager:(SP530Manager *)mSP530Manager ConnectedWithMsg:(NSString *)mErrMsg;

-(void)didSP530Manager:(SP530Manager *)mSP530Manager DisconnectedWithMsg:(NSString *)mErrMsg;

/**
 *  @discussion The application layer transaction command completed
 *  @param mTxDetails Transaction details
 *  @version 1
 */
-(void)didSP530CompletedTxWithDetails:(TxDetails *)mTxDetails
__attribute__((deprecated("Deprecated in version 2, Please use didSP530Manager:WithTxDetails:")));

/**
 *  @discussion The application layer transaction command completed
 *  @param mTxDetails Transaction details
 *  @version 2
 */
-(void)didSP530Manager:(SP530Manager *)mSP530Manager WithTxDetails:(TxDetails *)mTxDetails;

/**
 *  @discussion The application layer transaction command completed (Raw Full EMV Transaction:: decode by end-user)
 *  @param mDataBlock :: Raw Data Message from SP530
 *  @version 1
 */
-(void)didSP530CompletedRawFullEmvTxWithData:(NSData *)mDataBlock
__attribute__((deprecated("Deprecated in version 2, Please use didSP530Manager:CompletedRawFullEmvTxWithData:")));

/**
 *  @discussion The application layer transaction command completed (Raw Full EMV Transaction:: decode by end-user)
 *  @param mDataBlock :: Raw Data Message from SP530
 *  @version 2
 */
-(void)didSP530Manager:(SP530Manager *)mSP530Manager CompletedRawFullEmvTxWithData:(NSData *)mDataBlock;

/**
 *  @discussion Callback function of the execRawWithCmd member function
 *  @param mDataBlock the transaction return data
 */
-(void)didSP530CompletedRawCmdWithData:(NSData *)mDataBlock
__attribute__((deprecated("Deprecated in version 2, Please use didSP530Manager:CompletedRawCmdWithData:")));

/**
 *  @discussion Callback function of the execRawWithCmd member function
 *  @param mDataBlock the transaction return data
 */
-(void)didSP530Manager:(SP530Manager *)mSP530Manager CompletedRawCmdWithData:(NSData *)mDataBlock;

/**
 *  @discussion Callback function of the doInitMutualAuthWithType
 *  the SP530 only process the transaction command after sucessfully completed the mutual authenication
 *  @version 1
 */
-(void)didSP530MutuAuthCompleted
__attribute__((deprecated("Deprecated in version 2, Please use didSP530Manager:MutuAuthCompleted:")));

/**
*  @discussion Callback function of the doInitMutualAuthWithType
*  the SP530 only process the transaction command after sucessfully completed the mutual authenication
* @version 2
*/
-(void)didSP530Manager:(SP530Manager *)mSP530Manager MutuAuthCompleted:(bool)aMutuAuthCompleted;


/**
 *  @discussion Inform the caller mutual auth param write to file system successfully
 *  @param errMsg Error Message
 */
-(void)didSP530SaveMutuAuthConfCompleted:(NSString *)errMsg;

/**
 *  @discussion Callback of the find near by function call
 *  @param mPeripheral discovered SP530 profile
 */
-(void)didSP530Found:(MyPeripheral*)mPeripheral
    __attribute__((deprecated("Deprecated in version 2, Please use didSP530Manager:FoundDevice:")));

/**
 *  @discussion Callback of the find near by function call (for building hub)
 *  @param mPeripheral discovered SP530 profile
 *  @version 2
 */
-(void)didSP530Manager:(SP530Manager *)mSP530Manager  FoundDevice:(MyPeripheral*)mPeripheral;

/**
 *  @discussion Capture the debug messages send from the lib for toubleshooting
 *  @param mDebugMessage debug message
 */
-(void)didSP530DebugMessage:(NSString *)mDebugMessage;

/**
 *  @discussion Send Echo cmd to SP530 to check it ready to process the command request or not
 *  @param mStatus is a return value. TRUE:ready  FALSE:not yet connect with the device
 */
-(void)didSP530CommanderReady:(bool)mStatus;

-(void) needMutualAuth;

@end

//v1.1.x
typedef enum : NSUInteger {
    CRC16_checksum=1,
    MAC_checksum=2
} checksum_t;


@interface SP530Manager : NSObject<SP530CommunicatorDelegate, SP530AppsManagerDelegate>
{
}

#pragma mark Level 1 API - Transaction
/**
 *  @discussion Create a application shared instance
 *  @return instance of the SP530Manager class
 */
+(SP530Manager *)sharedInstance;

/**
 *  @discussion Create SP530Manager instance
 */
-(id)init;

/**
 *  @discussion Check the SP530 ready to accept the application command or not
 * Should implement the didSP530Connected
 *  @param mDuration Wait in second before timeout
 */
-(void)chkCommanderStatusWithTimeout:(int)mDuration;

/**
 *  @discussion Request the SP530 to process a sale command
 *  @param mTxDetails Sales Amount and the host response (Default use MAC checksum)
 *  @return 80:SP530 accepted the command -80:Not yet complete the mutual authenication
 */
-(int)makeSalesTrans:(TxDetails *)mTxDetails;

/**
 *  @discussion Make full EMV transaction with extended command (e.g. offline sales, void, refund, auth and settlement)
 *  @param mTxDetails Transaction detail
 *          ExtSalesCmd - e.g. S5_EMV_TX_CMD_SALES ... S5_EMV_TX_CMD_SETTLEMENT
 *  @return >=0 success <0 error
 */
-(int)makeFullEmvTrans:(TxDetails *)mTxDetails ExtSalesCmd:(NSString *)mExtSalesCmd ChecksumType:(checksum_t)mChecksumType;

/**
 *  @discussion get a copy of EMV tags map
 *  @return List of TLV objects (contains EMV code, data type, data length, value, description)
 */
-(NSMutableDictionary *)getEMVTagMap;

/**
 *  @discussion Mutual Authentication Security checking
 *  @param mMutualAuth Obtain the MRMK and RMK information
 */
-(void)doInitMutualAuthWithType:(MutualAuth *)mMutualAuth;

/**
 *  @discussion Save Mutual Auth - MRMK, MRMK index, RMK and RMK index to document folder
 *  @param Mutual Auth Object
 */
-(void)saveMutualAuthConf:(MutualAuth *)mutualAuth;

/**
 *  @discussion get Mutual Auth Conf from document folder
 *  @return MutualAuth object
 */
-(MutualAuth *)loadMutualAuthConf;

/**
 *  @discussion unlock the level 2 API
 *  @param mAPIKey 16 digits key (e.g. xxxx-xxxx-xxxx-xxxx)
 *  @return ture unlocked false invalid key
 */
-(bool)unlockAPIWithKey:(NSString *)mAPIKey;

-(void)sendEchoCmd;

#pragma mark Level 1 API - Load TMS APP

//********** Function for loading TMS APP *******************//

/**
 *  @discussion By Default the SP530 only allows load 16 TMS Applications, This function allow override the default value.
 *  @param aFileCount Max. number of applications can be downloaded to the SP530
 */
-(void)setMaxAppLoadFileCount:(int)aFileCount;

/**
 *  @discussion Get the TMS applications list from the SP530. should implement the "didSP530CompletedGetAppsList" call back 
 *  The list can be found from the "SP530AppsManager.AppsInfoList.
 */
-(void)getAppsList;

/**
 *  @discussion Get the last result of loading TMS Applications. should implement the "didSP530CompletedChkLoadAppsWithResult" call back
 */
-(void)getLastAppsLoadResult;

/**
 *  @discussion Load TMS applications to the SP530. User should implement the "didSP530CompletedLoadApps" call back.
 *  @param aPath: The location of the TMP applications
 *  @param aFileList: A list of file name
 */
-(void)loadTerminalAppsWithPath:(NSString*)aPath FileList:(NSMutableArray *)aFileList;

/**
 *  @discussion Load Data files to the SP530.
 *  @param aPath: The location of the Data File.
 *  @param aFileList: A list of file name
 */
-(void)loadTerminalDataWithPath:(NSString*)aPath FileList:(NSMutableArray *)aFileList;


#pragma mark Level 1 API - SP530 Configuration
/**
 *  @discussion Reboot SP530.
 */
-(void)reboot;

/**
 *  @discussion Configurate MCP Setting
 */
-(void)updateMcpConfigCh1:(SP530ConfMcp *)ASp530McpConfigCh1 Ch2:(SP530ConfMcp *)ASp530McpConfigCh2;

#pragma mark Level 2 API - Extended Command

/**
 *  @discussion Level 2 API - allow customize the EMV tags map such as add EMV TLV and rename the description
 *  @param mEmvTagMap - customized EMV tag map (allow add EMV tag format as key={EMV code} value={data type, description}
 */
-(void)setEMVTagMap:(NSMutableDictionary *)mEmvTagMap;

/**
 *  @discussion Allow input a unsigned char command and data block in hex string format
 *  @param  mCmd Command e.g. 0x23
 *          mHexStringDataBlock e.g. 00000000000001FF000101
 *          mChecksumType   e.g. MAC_checksum or CRC16_checksum
 */
-(void)execRawWithCmd:(unsigned char)mCmd HexStringDataBlock:(NSString *)mHexStringDataBlock ChecksumType:(checksum_t)mChecksumType;

/**
 *  @discussion Pass raw emv full transaction data to SP530
 *  @param mDataBlock - Raw Data in Hex NSString, mChecksumType: CRC16 or MAC
 */
-(void)execRawFullEmvTxWithDataBlock:(NSString *)mHexStringDataBlock ChecksumType:(checksum_t)mChecksumType;


#pragma mark Property

@property(weak, nonatomic) id <SP530ManagerDelegate> delegate;

/**
 *  @discussion Contains the MRMK and RMK information
 */
@property(strong, nonatomic, readonly)MutualAuth *MutualAuth;

/**
 *  @discussion Instance of the SP530Communicator (Read Only)
 */
@property(strong, nonatomic, readonly)SP530Communicator *Communicator;

/**
 *  @discussion Instance of the SP530AppsManager (Read Only)
 */
@property(strong, nonatomic, readonly)SP530AppsManager *AppsManager;

//New for Version 2.0
@property(strong, nonatomic) NSString *SP530ManagerID;

@end
