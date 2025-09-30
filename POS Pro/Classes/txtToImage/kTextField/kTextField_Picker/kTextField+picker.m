//
//  kTextField+picker.m
//  KLib
//
//  Created by khaled on 10/29/17.
//  Copyright © 2017 com.greatideas4ap. All rights reserved.
//

#import "kTextField+picker.h"
#import "Sort.h"
#import "Global.h"
@implementation kTextField (picker)


// ============================================
// picker


-(void)initForPicker
{
    
    UIToolbar *keyboardToolbar;
    
    
    if (keyboardToolbar == nil) {
        keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [keyboardToolbar setBarStyle:UIBarStyleBlackTranslucent];
        
        UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIButton *btnOK = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnOK setFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
        [btnOK addTarget:self action:@selector(doneWithNumberPad) forControlEvents:UIControlEventTouchUpInside];
        if ( [Global shared].Lang_ar == NO) {
            [btnOK setTitle:@"OK" forState:UIControlStateNormal];
        }
        else
        {
            [btnOK setTitle:@"موافق" forState:UIControlStateNormal];
        }
        
        UIBarButtonItem *barbtnOK = [[UIBarButtonItem alloc] initWithCustomView:btnOK];
        // UIBarButtonItem *aceptar = [[UIBarButtonItem alloc] initWithTitle:@"موافق" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)];
        
        
        [keyboardToolbar setItems:[[NSArray alloc] initWithObjects: extraSpace, barbtnOK, nil]];
    }
    
    self.inputAccessoryView = keyboardToolbar;
    
    
    SelectedValue =@"0";
}
-(void)doneWithNumberPad_picker {
    
    id dlg = self.parent;
    if (dlg != nil) {
        
        if ([dlg respondsToSelector:@selector(selectedValue:)]) {
            [dlg selectedValue:[NSString stringWithFormat:@"%d",currentvalue]];
        }
        
    }
    if ([self.text isEqualToString:@""])
    {
        self.text = [dictypem objectForKey:[NSString stringWithFormat:@"%@" ,[allkeys objectAtIndex:0] ]];
    }
    else
    {
        //  self.text = [self getkeybyval:self.text];
    }
    
    
    [self resignFirstResponder];
    
}




-(void) setcategitems:(NSDictionary *) dic
{
    
    if ([dic count] >0) {
        
        
        dictypem = dic;
        
        
        allkeys = [[NSArray alloc] init];
        
        if ( self.IsNumber == YES) {
            allkeys = [Sort sortArrNumber: [dictypem allKeys]];
        }
        else
        {
            if (self.DescSort == YES) {
                allkeys = [Sort sortArrAlphabetically_Desc: [dictypem allKeys]];
            }
            else
            {
                allkeys = [Sort sortArrAlphabetically: [dictypem allKeys]];
            }
        }
        
        
        
        //  self.text = [dictypem objectForKey:[NSString stringWithFormat:@"%@" ,[allkeys objectAtIndex:0] ]];
        SelectedValue =[allkeys objectAtIndex:0];
        
        currentvalue = [SelectedValue intValue];
        
        
        
        datePicker = [[UIPickerView alloc] init];
        datePicker.delegate = self ;
        datePicker.dataSource = self;
        datePicker.showsSelectionIndicator = YES;
        datePicker.backgroundColor = [UIColor whiteColor];
        
        
        self.inputView = datePicker;
        
        [datePicker reloadAllComponents];
        
    }
    else
    {
        self.text = @"";
        dictypem = nil;
        allkeys = nil;
        
        self.inputView = nil;
        
        SelectedValue =@"0";
        
        currentvalue = [SelectedValue intValue];
        //  self.enabled = NO;
    }
    
    
}
-(void) setselectedvalueByText:(NSString *) val
{
    
    SelectedValue = [self getkeybyval:val];
    
}
-(void) setselectedValue:(NSString *)val
{
    currentvalue = [val intValue];
    SelectedValue =val;
}

-(void) settextbykey:(NSString *) key
{
    self.text = [dictypem objectForKey:key ] ;
    int index = (int)[allkeys indexOfObject:key];
    if (index < 0) {
        index = 0;
    }
    SelectedValue = [allkeys objectAtIndex:index];
    
    currentvalue = [SelectedValue intValue];
    
}
-(NSString *) getkeybyval:(NSString *) val
{
    NSString *returnval = nil;
    int count =(int) [allkeys count];
    
    for (int i =0; i < count; i++) {
        NSString *v = [dictypem objectForKey:[allkeys objectAtIndex:i]];
        if ([v isEqualToString: val]) {
            returnval =[allkeys objectAtIndex:i];
            break;
        }
    }
    return returnval;
}

-(NSString *) getselectedValue
{
    
    SelectedValue = [NSString stringWithFormat:@"%d",currentvalue];
    return SelectedValue;
    
    
    
}

#pragma mark -
#pragma mark UIPickerViewDataSource
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *St =[dictypem objectForKey:[NSString stringWithFormat:@"%@" ,[allkeys objectAtIndex:row] ]];
    self.text =St;
    SelectedValue = [allkeys objectAtIndex:row];
    currentvalue = [SelectedValue intValue];
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40.0;
}
//-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//
//    return  [dictypem objectForKey:[NSString stringWithFormat:@"%@" ,[allkeys objectAtIndex:row] ]];
//}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)];
    lbl.text = [dictypem objectForKey:[NSString stringWithFormat:@"%@" ,[allkeys objectAtIndex:row] ]];
    lbl.adjustsFontSizeToFitWidth = YES;
    lbl.textAlignment=NSTextAlignmentCenter;
    lbl.font=[UIFont systemFontOfSize:20];
    return lbl;
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [dictypem count];
}


-(NSString *) GetText
{
    NSString *v =@"";
    
    if (self.txtValue != nil) {
        v =  self.txtValue;
    }
    else
    {
        v = self.text;
    }
    
    return v;
}


@end
