//
//  SP530Communicator.h
//  SP530 Demo
//
//  Created by spectra on 31/7/15.
//  Copyright (c) 2015 Spectra Technologies Holdings Company Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyPeripheral.h"


#define SSL_SRV_DAEMON_DEFAULT_PORT 9000

@class SP530Communicator;

@protocol SP530CommunicatorDelegate <NSObject>

@required
/**
 *  @discussion Callback function of the startTransWithCmdPkt: method
 *  @param mReponsePkt Transaction request raw data block from SP530. The SP530Manager based on the command code to
 *      decode the data block and pad into the TxDetails
 */
-(void)didSP530CommunicatorCompleteTx:(NSData *)mReponsePkt;

/**
 *  @discussion Return the Channel 1 error to the delegator
 *  @param mErrMsg Error Message
 */
-(void)didSP530CommunicatorFoundErr:(NSString *)mErrMsg;

@optional
/**
 *  @discussion Confirm the SSL handshaking completed
 *  @param mSP530Communicator Instance of the SP530Communicator Class DebugMessage: Debug message
 */
-(void)SP530Communicator:(SP530Communicator *)mSP530Communicator didSSLHandshakeCompleted:(bool)Status;

/**
 *  @discussion Return the debug message from the lib
 *  @param mSP530Communicator Instance of the SP530Communicator Class DebugMessage: Debug message
 */
-(void)SP530Communicator:(SP530Communicator *)mSP530Communicator DebugMessage:(NSString *)mDebugMessage;

/**
 *  @discussion Callback function of the findDevices: method
 *  @param mSP530Communicator Instance of the SP530Communicator Class didSP530Found: the discovied SP530 profile
 */
-(void)SP530Communicator:(SP530Communicator *)mSP530Communicator didSP530Found:(MyPeripheral*)mPeripheral;

/**
 *  @discussion (Lib v1.4.0) Callback function of the connectWithPeripheral and connectWithPeripheralWithSSL
 *  @param if empty String or null mean connected with SP530 otherwise it returns the error message to the calling program
 */
-(void)SP530Communicator:(SP530Communicator *)mSP530Communicator didSP530Connected:(NSString*)mErrMsg;

-(void)SP530Communicator:(SP530Communicator *)mSP530Communicator didSP530Disconnected:(NSString*)mErrMsg;

@end

/// Class docs
@interface SP530Communicator : NSObject
{
    
}

@property(assign, nonatomic) bool EnableCh1SSL;

//@property(strong, nonatomic) NSMutableArray *DevicesList;
//@property(strong, nonatomic) CBCentralManager *CentralManager;
@property (strong, nonatomic, readonly) MyPeripheral* connectedPeripheral;

@property(weak, nonatomic)id <SP530CommunicatorDelegate> delegate;
@property(assign, nonatomic, readonly) bool IsBLEConnected;

/// Method docs
#pragma mark member methods

+(SP530Communicator *)sharedInstance;

/**
 *  @method init
 *
 *  @discussion        create instance of SP530Communicator
 *
 */
-(id)init;

/**
 *  @method connectWithPeripheral
 *
 *  @discussion        Connect to the SP530 (Default the Channel 1 is disabled SSL)
 *
 */
-(void)connectWithPeripheral:(MyPeripheral*)mPeripheral;

/**
 *  @method connectWithPeripheralWithSSL
 *
 *  @discussion        Connect to the SP530 (Default the Channel 1 is Enabled SSL)
 *
 */
-(void)connectWithPeripheralWithSSL:(MyPeripheral*)mPeripheral CA:(NSString *)mCA_Cer
                       P12_FileName:(NSString *)mP12_Filename
                            P12_Pwd:(NSString *)mP12_Pwd
             CH1_SSL_Req_ClientAuth:(bool)mEnableCh1SSLClientAuthOpt;

/**
 *  @method reconnect
 *
 *  @discussion  Load the SP530 profile from iOS document folder and try to reconnect with it
 *
 */
-(void)reconnect;

/**
 *  @method disconnect
 *
 *  @discussion        Disconnect with the SP530
 *
 */
-(void)disconnect;

/**
 *  @method findDevices
 *
 *  @param enabled  true:start scanning SP530
 *      false: stop scanning SP530
 *
 *  @discussion        Connect to the SP530 (Default the Channel 1 is disabled SSL)
 *
 */
-(void)findDevices:(bool)enabled;

/**
 *  @method savePeripheralProfile
 *
 *  @discussion  Save last discovered SP530 profile to iOS document folder
 *
 */
-(void)savePeripheralProfile;

/**
 *  @method getPeripheralProfile
 *
 *  @discussion  get last saved profile from iOS document folder
 *
 */
-(CBPeripheral *)getPeripheralProfile;

/**
 *  @method forgetPeripheralProfile
 *
 *  @discussion  Remove the stored SP530 profile from the iOS document folder
 *
 */
-(void)forgetPeripheralProfile;

/**
 *  @method startTransWithCmdPkt
 *
 *  @param mCmdPkt  Padded SP530 application command such as Sales, void and etc
 *
 *  @discussion Send the command to the SP530 for process
 *
 */
-(void)startTransWithCmdPkt:(NSData *)mCmdPkt;

/**
 *  @method getTCPStatusWithChIdx
 *
 *  @param mChannelIdx  TCP channel index
 *
 *  @discussion Get TCP channel connection status (Connected - K_TCP_READY or disconnected - 0)
 *
 */
-(int)getTCPStatusWithChIdx:(int)mChannelIdx;



// Temporary function
-(NSArray*) DevicesList  __attribute__((deprecated("Please use devicesList")));

-(NSArray*) devicesList;

-(CBCentralManagerState)centralManagerState;


#define kCentralManagerStateDidUpdate @"kCentralManagerStateDidUpdate"

#define kBTIsReadyTransmit @"kBTIsReadyTransmit"

// Not for public use, Please do not use below function
-(void)appendRxData:(NSData *) data;

-(void)endBluetoothRxData;

-(void)WakeUpAllThreads;


-(void)resetFF;

-(void) writeMCPWithData:(NSData*)data chId:(int)chId;
@end

