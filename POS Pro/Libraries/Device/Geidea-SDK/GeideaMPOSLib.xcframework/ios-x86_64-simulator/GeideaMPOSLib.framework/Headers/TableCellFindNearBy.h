//
//  TableCellFindNearBy.h
//  SP530 find device
//
//  Created by spectra on 26/8/15.
//  Copyright (c) 2015 Spectra Technologies Holdings Company Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SP530Core.h"

@class TableCellFindNearBy;

@protocol TableCellFindNearByDelegate <NSObject>

-(void)didNearbyTableCellStatusChg:(bool)status SP530Profile:(MyPeripheral *)sp530Profile;

-(void)didNearbyTableCellStatusChg:(TableCellFindNearBy *)tableCellFindNearBy;
@end

@interface TableCellFindNearBy : UITableViewCell
{
    
}

@property (weak, nonatomic) id<TableCellFindNearByDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *DeviceName;
@property (strong, nonatomic) MyPeripheral *SP530Profile;
@property (strong, nonatomic) IBOutlet UILabel *ConnectionStatus;
@property (strong, nonatomic) IBOutlet UIButton *btnConnectStatus;


@end

