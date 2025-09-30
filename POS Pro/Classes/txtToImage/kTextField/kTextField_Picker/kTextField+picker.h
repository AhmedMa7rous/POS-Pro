//
//  kTextField+picker.h
//  KLib
//
//  Created by khaled on 10/29/17.
//  Copyright © 2017 com.greatideas4ap. All rights reserved.
//

#import "kTextField.h"

@interface kTextField (picker)
// Picker
@property(nonatomic) IBInspectable BOOL  userPicker;
@property(nonatomic) IBInspectable BOOL EnableEditing;
@property(nonatomic) IBInspectable BOOL DescSort;
@property(nonatomic) IBInspectable BOOL IsNumber;

@property(nonatomic,strong) NSString *txtValue;

-(void)initForPicker;
-(void)doneWithNumberPad_picker;
-(void) setcategitems:(NSDictionary *) dic;
-(void) settextbykey:(NSString *) key;
-(void) setselectedvalueByText:(NSString *) val;
-(void) setselectedValue:(NSString *)val;

-(NSString *) getkeybyval:(NSString *) val;
-(NSString *) getselectedValue;
-(NSString *) GetText;
@end
