//
//  textfiledpickerviewDate.m
//  twitter
//
//  Created by khaled on 7/6/13.
//  Copyright (c) 2013 abda3. All rights reserved.
//

#import "kTextField_datePicker.h"

@implementation kTextField_datePicker

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)doneWithNumberPad {
    [self resignFirstResponder];
    
    if ([_dlg respondsToSelector:@selector(DoneSelect)])
    {
        [_dlg DoneSelect];
    }
}
 
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    
 
      if (pv == nil)
      {
          [self initPicker];
      }
    
  
    
   
}

-(void) initPicker
{
    UIToolbar *keyboardToolbar;
    
    
    if (keyboardToolbar == nil) {
        keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [keyboardToolbar setBarStyle:UIBarStyleBlackTranslucent];
        
        UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        //UIBarButtonItem *aceptar = [[UIBarButtonItem alloc] initWithTitle:@"موافق" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)];
        UIButton *btnOK = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnOK setFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
        [btnOK addTarget:self action:@selector(doneWithNumberPad) forControlEvents:UIControlEventTouchUpInside];
        [btnOK setTitle:@"OK" forState:UIControlStateNormal];
        UIBarButtonItem *barbtnOK = [[UIBarButtonItem alloc] initWithCustomView:btnOK];
        
        
        [keyboardToolbar setItems:[[NSArray alloc] initWithObjects: extraSpace, barbtnOK, nil]];
    }
    self.inputAccessoryView = keyboardToolbar;
    
    pv = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,245,0,0)];
    
    pv.backgroundColor = [UIColor whiteColor];
    
    // [UIView appearanceWhenContainedIn:[UITableView class], [UIDatePicker class], nil].backgroundColor =[UIColor whiteColor];
    
    //    [pv setValue:@"0.8" forKeyPath:@"alpha"];
    //    [pv setValue:[UIColor blackColor] forKeyPath:@"textColor"];
    //
    
    
    
    
    [pv addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    if (_dateonly) {
        pv.datePickerMode = UIDatePickerModeDate;
    }
    else if (_timeonly)
    {
        pv.datePickerMode = UIDatePickerModeTime;
    }
    // [self addSubview:pv];
    self.inputView = pv;
    
    
    
    [self LoadInitdate:pv];
}

-(void) SetColorOfPlaceholder:(UIColor *) color
{
    [self setValue:color forKeyPath:@"_placeholderLabel.textColor"];
}
-(void) LoadInitdate:(UIDatePicker *)pv1
{
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    if (_formateDate != nil) {
        [outputFormatter setDateFormat:_formateDate];
    }
    else
    {
        if (_dateonly) {
            [outputFormatter setDateFormat:@"yyyy/MM/dd"];
        }
        else if (_timeonly)
        {
          [outputFormatter setDateFormat:@"hh:mm a"];
        }
        else
        {
            [outputFormatter setDateFormat:@"yyyy/MM/dd hh:mm a"];
        }
    }
    
    self.text = [outputFormatter stringFromDate:pv1.date];
 
     if (_TextDate == nil)
     {
     self.text = [outputFormatter stringFromDate:pv1.date];
     }
     else
     {
     [self selectdate:_TextDate];
     }
  
    
    
    if (self.text == nil) {
        self.text =@"";
    }
}

-(void) Showdate:(UIDatePicker *)pv1
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    if (_formateDate != nil) {
        [outputFormatter setDateFormat:_formateDate];
    }
    else
    {
    if (_dateonly) {
            [outputFormatter setDateFormat:@"yyyy/MM/dd"];
    }
    else if (_timeonly)
    {
        [outputFormatter setDateFormat:@"hh:mm a"];
    }
    else
    {
            [outputFormatter setDateFormat:@"yyyy/MM/dd hh:mm a"];
    }
}
    
    
       _timestamp = [pv1.date timeIntervalSince1970];

      self.text = [outputFormatter stringFromDate:pv1.date];
    
    /*
    if (_TextDate == nil)
    {
        self.text = [outputFormatter stringFromDate:pv1.date];
    }
    else
    {
        [self selectdate:_TextDate];
    }
     */
    
    
    if (self.text == nil) {
    self.text =@"";
    }
}

 -(IBAction)datePickerValueChanged:(id)sender
{
    UIDatePicker *pv1 = sender;
 
    [self Showdate:pv1];
  
    
  
}

-(void) selectdate:(NSString *) dt
{
    if (![dt isEqualToString:@""]) {
        

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (_formateDate != nil) {
        [dateFormatter setDateFormat:_formateDate];
    }
    else
    {
    if (_dateonly) {
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    }
    else if (_timeonly)
    {
        [dateFormatter setDateFormat:@"hh:mm a"];
    }
    else
    {
        [dateFormatter setDateFormat:@"yyyy/MM/dd hh:mm a"];
    }
    }
    NSDate *dateFromString = [[NSDate alloc] init];
    
    dateFromString = [dateFormatter dateFromString: dt];
    
   [pv setDate:dateFromString animated:YES];
    
    self.text = dt;
   }
    else
    {
     self.text =@"";
    }

 
}

@end
