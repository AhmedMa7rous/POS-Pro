//
//  BluetoothClass.h
//  MPOS
//
//  Created by GEIDEA on 18/09/17.
//  Copyright © 2017 GEIDEA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@protocol BluetoothStatusDelegate <NSObject>
@required
- (void) BluetoothStatus: (BOOL)Status;
@end


@interface BluetoothClass : NSObject<CBCentralManagerDelegate>
{
    id <BluetoothStatusDelegate> delegate;
}

@property (nonatomic) CBCentralManager *bluetoothManager;

@property (nonatomic, assign) NSInteger blueToothStatus;

@property (retain) id delegate;

-(void)startSomeProcess;


@end
