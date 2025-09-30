//
//  textfiledpickerviewDate.h
//  twitter
//
//  Created by khaled on 7/6/13.
//  Copyright (c) 2013 abda3. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "kTextField.h"

@interface kTextField_datePicker : UITextField
{
    UIDatePicker *pv ;
}

-(void) selectdate:(NSString *) dt;

@property(nonatomic) NSTimeInterval timestamp;


@property(nonatomic) IBInspectable BOOL dateonly;
@property(nonatomic) IBInspectable BOOL timeonly;

@property(nonatomic,strong) IBInspectable NSString* TextDate;
@property(nonatomic,strong) IBInspectable NSString *formateDate;

-(void) SetColorOfPlaceholder:(UIColor *) color;
@property(nonatomic) id dlg;

@end

@protocol textfiledpickerviewDate_delegate <NSObject>

-(void) DoneSelect;

@end
