
//
//  TblViewControllerFindDevice.h
//  SP530 find device
//
//  Created by spectra on 4/8/15.
//  Copyright (c) 2015 Spectra Technologies Holdings Company Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SP530Core.h"
#import "TableCellFindNearBy.h"

/*
@protocol checkINSwift <NSObject>
- (void)backClicked;
@end
*/
@interface TblViewControllerFindDevice : UIViewController
<SP530ManagerDelegate,
TableCellFindNearByDelegate,
UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource,CBCentralManagerDelegate>
{
   
    int mCounter;
    bool mScanning;
    
    UIView *mScanningLayer;
    UIView *mConnectionStatusLayer;
    
    UILabel *mCntLabel;
    UILabel *mConnectionMsg;
    
    bool mClearTable;
    bool mSP530SecurityChkOk;
    bool isTerminalInfo;
    
    NSString *mConnectedDevice;
    NSString *terminalInfoCmd;
    
    TableCellFindNearBy *mSelectedTblCell;
    int firstTime ;
    
    CBCentralManager *cBCentralManager;
    
    //MyPeripheral *selectedSP530;
}
@property (strong, nonatomic) IBOutlet UIButton *BtnForgetIt;
@property (strong, nonatomic) IBOutlet UILabel *SavedDeviceName;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *connectionMsg;
@property(strong, nonatomic) SP530Manager *mSP530Manager;


//@property (nonatomic, weak) id <checkINSwift> delegate;
- (IBAction)btnReconnect_OnTouchDown:(UIButton *)sender;

-(void)reloadTableView;
@end





