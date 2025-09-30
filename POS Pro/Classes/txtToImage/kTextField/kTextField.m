//
//  kTextView.m
//  apptemplate
//
//  Created by khaled on 7/24/16.
//  Copyright © 2016 com.el-abda3. All rights reserved.
//

#import "kTextField.h"
#import "Animation.h"
#import "Sort.h"
#import "LanguageManager.h"
#import "Global.h"
@implementation kTextField 

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    
    }
    return self;
}


//- (void)setNeedsLayout {
//    [super setNeedsLayout];
//    [self setNeedsDisplay];
//}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    
    [self kinit];
}

-(void) kinit
{
 
    if (_ShowToolBar == YES) {
        [self Showtoolbar];
    }
    
    if (_PlaceholderColor != nil) {
        [self SetColorOfPlaceholder:_PlaceholderColor];
    }
    
    if (_Placeholder_ar != nil) {
        if ([LanguageManager CurrentLang] == AR) {
            self.placeholder = _Placeholder_ar;
        }
    }
    

    self.delegate = self;
    
    
    if ([_validation_Type isEqualToString:@"empty"] ) {
         [self createPopValidate];
    }
    
    if (_userPicker == YES) {
        [self initForPicker];
    }
    
     [self customlayout];
     
  
    if (_parent!= nil) {
        tapper = [[UITapGestureRecognizer alloc]
                  initWithTarget:self action:@selector(handleSingleTap:)];
        tapper.cancelsTouchesInView = NO;
        tapper.delegate = self;
        [_parent.view addGestureRecognizer:tapper];
    }
   
    
}


- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    if (_parent!= nil) {
        [_parent.view endEditing:YES];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]){
        return NO;
    }
    return YES;
}

-(void) SetColorOfPlaceholder:(UIColor *) color
{
    @try {
         [self setValue:color forKeyPath:@"_placeholderLabel.textColor"];

    } @catch (NSException *exception) {
         
    } @finally {
         
    }
    
}

-(void)  Showtoolbar
{
    
    
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    //    numberToolbar.items = [NSArray arrayWithObjects:
    //                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
    //                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
    //                           [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad )],
    //                           nil];
    
    UIButton *btnOK = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnOK setFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
    [btnOK addTarget:self action:@selector(doneWithNumberPad) forControlEvents:UIControlEventTouchUpInside];
    [btnOK setTitle:@"OK" forState:UIControlStateNormal];
    UIBarButtonItem *barbtnOK = [[UIBarButtonItem alloc] initWithCustomView:btnOK];
    
    numberToolbar.items = [NSArray arrayWithObjects:
                           
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           barbtnOK,
                           nil];
    [numberToolbar sizeToFit];
    self.inputAccessoryView = numberToolbar;
    
    
}
-(void)doneWithNumberPad {
    
    if (_userPicker == YES) {
        [self doneWithNumberPad_picker];
    }
    else
    {
        id dlg = _parent;
        if (dlg != nil) {
            
            if ([dlg respondsToSelector:@selector(textFieldShouldReturn:)]) {
                [dlg textFieldShouldReturn:self];
            }
            else
            {
                [self resignFirstResponder];
            }
            
        }
        else
        {
            [self resignFirstResponder];

        }
    }

}




- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    id dlg = _parent;
    if (dlg != nil) {
        
        if ([dlg respondsToSelector:@selector(textFieldShouldReturn:)]) {
            [dlg textFieldShouldReturn:textField];
        }
        
    }
    
    if (_enableTab == YES) {
        NSInteger nextTag = textField.tag + 1;
        // Try to find next responder
        UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
        if (nextResponder) {
            // Found next responder, so set it.
            [nextResponder becomeFirstResponder];
        } else {
            // Not found, so remove keyboard.
            [textField resignFirstResponder];
        }
        return NO; // We do not want UITextField to insert line-breaks.
    }
    else
    {
        [textField resignFirstResponder];
        
        return YES;
    }

    
    
 
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (_parent != nil && _MoveView == YES) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        
        [self animateTextField: textField up: NO];
    }

    if (![_validation_Type isEqualToString:@""]) {
           [self validate];
    }
    
    
    id dlg = _parent;
    
    if ([dlg respondsToSelector:@selector(KtextFieldDidEndEditing:)]) {
        
        return [dlg KtextFieldDidEndEditing:textField];
    }
    
    
}




- (void)textFieldDidBeginEditing:(UITextField *)textField
{
   
    
    
    if (_parent != nil && _MoveView == YES) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appEnteredBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        [self animateTextField: textField up: YES];
    }
   
    id dlg = _parent;
    
    if ([dlg respondsToSelector:@selector(KtextFieldDidBeginEditing:)]) {
        
        return [dlg KtextFieldDidBeginEditing:textField];
    }
    
    
//    if (![_validation_Type isEqualToString:@""]) {
//           [self showValidateMsg];
//  
//        
//    }
//    

   
}



- (void)appEnteredBackground{
    [self resignFirstResponder];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    if (textField.tag != -1) {
        
        
        
          int y = _parent.view.frame.origin.y; //textField.superview.frame.origin.y;
         //  int y1 = textField.frame.origin.y;
        
      //   CGPoint p = [textField.superview convertPoint:textField.center toView:_parent.view];
        CGPoint p = [textField.superview convertPoint:textField.frame.origin toView:_parent.view];

        int y1 = p.y;


        
        
        
        if (y==0) {
            if (up == YES) {
            y = y1;
            }
            
        }
        else if (y < y1)
        {
            y = y1;
        }
        
        int Distance = (int) textField.tag;
        int movementDistance = y / 2; // tweak as needed
        movementDistance = movementDistance + Distance ;
        const float movementDuration = 0.3f; // tweak as needed
        
        int movement = (up ? -movementDistance : movementDistance);
        
 
        
        [UIView beginAnimations: @"anim" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: movementDuration];
        
         _parent.view.frame = CGRectOffset(_parent.view.frame, 0, movement);
        [UIView commitAnimations];
        
    }
}

// ===================================================================================
// Validate
-(void) createPopValidate
{
    
    if (_validation_lable != NULL) {
        
        return;
        
    }
    self.clipsToBounds = NO;

    _validation_lable =[[UILabel alloc] init];
    _validation_lable.numberOfLines = 0;
    _validation_lable.lineBreakMode = NSLineBreakByWordWrapping;
    _validation_lable.font = [UIFont systemFontOfSize:_validation_Font_size];
    _validation_lable.textColor = _validation_TextColor;
    [_validation_lable setBackgroundColor:[UIColor clearColor]];
    _validation_lable.clipsToBounds =NO;
    _validation_lable.tag = 2000;
    
    if ([_validation_textAlignment isEqualToString:@"right"]) {
        _validation_lable.textAlignment = NSTextAlignmentRight;
    }
    else if ([_validation_textAlignment isEqualToString:@"left"])
    {
    _validation_lable.textAlignment = NSTextAlignmentLeft;
    }
    else
    {
    _validation_lable.textAlignment = NSTextAlignmentCenter;
    }
    
    
    if ([_validation_postion isEqualToString:@"top"]) {
        _validation_lable.frame = CGRectMake(0, -self.frame.size.height, self.frame.size.width, 20);
    }
    else if ([_validation_postion isEqualToString:@"bottom"])
    {
        _validation_lable.frame = CGRectMake(0,   self.frame.size.height, self.frame.size.width, 20);
    }
    else
    {
        _validation_lable.frame = _validation_fram;
    }
    
   
    
    _validation_lable.hidden = YES;
     [self addSubview:_validation_lable];
   // [self insertSubview:_validation_lable atIndex:0];
    
}


-(void) showValidateMsg:(NSString *) msg
{
    _validation_lable.hidden = NO;
    _validation_lable.text = msg;
    
    if (_validation_Animation == YES) {
        Animation *an = [Animation scale_button];
        [_validation_lable.layer addAnimation:an.anmi forKey:an.key];
    }
    
    
    
    
}

-(void) showValidateMsg
{

    [self showValidateMsg:_validation_msg];
    
    
   
    id dlg = _parent;
    
    if ([dlg respondsToSelector:@selector(validate:isValid:)]) {
        
        return [dlg validate:_type isValid:NO];
    }
    
   
    
    
}

-(void) hideMsg
{
    _validation_lable.hidden = YES;
 
    
    
}
-(void) hideValidateMsg
{
     _validation_lable.hidden = YES;
//    for (UIView *view in self.subviews) {
//        NSLog(@"%@", view);
//        if ([view isKindOfClass:[UILabel class]]) {
//            UILabel *lbl = (UILabel *)view;
//            if (lbl.tag == 2000) {
//                 lbl.hidden = YES;
//            }
//            
//        }
//    }
    
    id dlg = _parent;
    
    if ([dlg respondsToSelector:@selector(validate:isValid:)]) {
        
        return [dlg validate:_type isValid:YES];
    }
 
  
}

-(BOOL) isValidate
{
 
        NSString *st =self.text ;
        if (![st isEqualToString:@""]) {
            return YES;
        }
        else
        {
            return NO;
        }
    

}



-(BOOL) validate
{
    if ([_validation_Type isEqualToString:@"empty"]) {
        NSString *st =self.text ;
        if (![st isEqualToString:@""]) {
                [self hideValidateMsg];
                return YES;
        }
        else
        {
            [self showValidateMsg];
             return NO;
        }
    }
    
    
     return YES;
    

}


- (void)customlayout {
    
    
    if (_shadowRadius > 0) {
        self.layer.masksToBounds = NO;
        self.layer.shadowColor = _shadowColor.CGColor;
        self.layer.shadowOffset = CGSizeMake(-1, 1);
        self.layer.shadowOpacity = _shadowOpacity;
        self.layer.shadowRadius = _shadowRadius;
        [self.layer setShadowPath: [[UIBezierPath bezierPathWithRoundedRect:[self bounds] cornerRadius:4] CGPath]];
    }
    
    
    
    
    if (self.cornerRadious > 0) {
        
        
       // self.layer.masksToBounds = YES;
        self.layer.cornerRadius = self.cornerRadious;
        
        
    }
    
    if (self.borderWidth > 0) {
        
        
        self.layer.borderWidth = self.borderWidth;
        self.layer.borderColor = _borderColor.CGColor;
        
    }
    
    
    
}



- (CGRect)textRectForBounds:(CGRect)bounds
{
    
    return CGRectInset(bounds, _padding_x, _padding_y);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}
- (BOOL) textField: (UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString: (NSString *)string {
    
  
    //return yes or no after comparing the characters
    if (_DecimalOnly) {
        return [self EnableDecimalOnly:theTextField shouldChangeCharactersInRange:range replacementString:string];
    }
    
    if (_phoneNumber) {
           return [self EnablePhoneNumber:theTextField shouldChangeCharactersInRange:range replacementString:string];
       }
    
    if (_maxLength != 0) {
        NSString *st = [NSString stringWithFormat:@"%@%@",theTextField.text , string];
        if ([st length] > _maxLength) {
            return NO;
        }
    }
       id dlg = _parent;
    
    if ([dlg respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
     
        return [dlg textField:theTextField shouldChangeCharactersInRange:range replacementString:string];
    }
    
    
    return YES;
}

-(BOOL) EnableDecimalOnly: (UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString: (NSString *)string
{
    // allow backspace
    if (!string.length)
    {
        return YES;
    }
    
    if (_maxLength != 0) {
        if ([theTextField.text length] > _maxLength) {
            return NO;
        }
    }
    
    if (_maxValue != 0) {
        NSString *st = [NSString stringWithFormat:@"%@%@",theTextField.text , string];

        float f =  [st floatValue];
        if ( f > _maxValue) {
            return NO;
        }
    }
 
    ////for Decimal value start//////This code use use for allowing single decimal value
    if ([theTextField.text rangeOfString:@"."].location == NSNotFound)
    {
        if ([string isEqualToString:@"."]) {
            return YES;
        }
    }
    else
    {
        NSUInteger  location_dot =[theTextField.text rangeOfString:@"."].location;
        
        if (range.location > location_dot) {
            if ([[theTextField.text substringFromIndex:location_dot] length]>2)   // this allow 2 digit after decimal
            {
                return NO;
            }
        }
        
    }
    ////for Decimal value End//////This code use use for allowing single decimal value
    
    
    // allow digit 0 to 9
    
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location == NSNotFound) {
        return YES;
    }
    
    

//
//    if ([string intValue])
//    {
//        return YES;
//    }
    
   return NO;

}
-(BOOL) EnablePhoneNumber: (UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString: (NSString *)string
{
    // allow backspace
    if (!string.length)
    {
        return YES;
    }
    
    if (_maxLength != 0) {
        if ([theTextField.text length] > _maxLength) {
            return NO;
        }
    }
    
   if ([string isEqualToString:@"+"]) {
       if (theTextField.text.length == 0)
       {
              return YES;
       }
       else
       {
           return  NO;
       }
    
   }
 
    
    
    // allow digit 0 to 9
    
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"+0123456789"];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location == NSNotFound) {
        return YES;
    }
    
    

//
//    if ([string intValue])
//    {
//        return YES;
//    }
    
   return NO;

}

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
    
    id dlg = _parent;
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
        
        if (_IsNumber == YES) {
            allkeys = [Sort sortArrNumber: [dictypem allKeys]];
        }
        else
        {
            if (_DescSort == YES) {
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
    
    if (_txtValue != nil) {
        v =  _txtValue;
    }
    else
    {
        v = self.text;
    }
    
    return v;
}



- (BOOL)validateString:(NSString *)pattern
{
    NSString *string =self.text;
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSAssert(regex, @"Unable to create regular expression");
    
    NSRange textRange = NSMakeRange(0, string.length);
    NSRange matchRange = [regex rangeOfFirstMatchInString:string options:NSMatchingReportProgress range:textRange];
    
    BOOL didValidate = NO;
    
    // Did we find a matching range
    if (matchRange.location != NSNotFound)
        didValidate = YES;
    
    return didValidate;
}



@end
