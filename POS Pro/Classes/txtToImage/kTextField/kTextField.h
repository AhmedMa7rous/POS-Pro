//
//  kTextView.h
//  apptemplate
//
//  Created by khaled on 7/24/16.
//  Copyright © 2016 com.el-abda3. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface kTextField : UITextField < UITextFieldDelegate,UIPickerViewDelegate, UIPickerViewDataSource ,UIGestureRecognizerDelegate>
{
    NSDictionary *dictypem;
    NSArray *allkeys;
    UIPickerView *datePicker;
    
    int currentvalue;
   
   NSString *SelectedValue;
    
    UIGestureRecognizer *tapper;

    
}
@property(nonatomic,strong) IBOutlet UIViewController *parent;
@property(nonatomic,strong) UILabel *validation_lable ;


// Picker
@property(nonatomic) IBInspectable BOOL  userPicker;
@property(nonatomic) IBInspectable BOOL  userDatePicker;


@property(nonatomic) BOOL EnableEditing;
@property(nonatomic) BOOL DescSort;
@property(nonatomic) BOOL IsNumber;
@property(nonatomic,strong) NSString *txtValue;

-(void) setcategitems:(NSDictionary *) dic;
-(void) settextbykey:(NSString *) key;
-(void) setselectedvalueByText:(NSString *) val;
-(void) setselectedValue:(NSString *)val;

-(NSString *) getkeybyval:(NSString *) val;
-(NSString *) getselectedValue;
-(NSString *) GetText;



// Text
@property(nonatomic) IBInspectable BOOL  ShowToolBar;
@property(nonatomic) IBInspectable BOOL  validation_Animation;
@property(nonatomic) IBInspectable BOOL  MoveView;
@property(nonatomic) IBInspectable BOOL  DecimalOnly;
@property(nonatomic) IBInspectable BOOL  enableTab;
@property(nonatomic) IBInspectable BOOL  phoneNumber;

@property(nonatomic) IBInspectable int  maxLength;
@property(nonatomic) IBInspectable float  maxValue;


@property(nonatomic,strong) IBInspectable  NSString *wb_prm;
@property(nonatomic,strong) IBInspectable NSString* Placeholder_ar;
@property(nonatomic,strong) IBInspectable UIColor* PlaceholderColor;
@property(nonatomic,strong) IBInspectable  NSString *type;




@property(nonatomic,strong) IBInspectable NSString  *validation_Type;
@property(nonatomic,strong) IBInspectable  NSString *validation_msg;
@property(nonatomic,strong) IBInspectable NSString  *validation_postion;
@property(nonatomic,strong) IBInspectable UIColor *  validation_TextColor;
@property(nonatomic,strong) IBInspectable NSString *  validation_textAlignment;


@property(nonatomic) IBInspectable int        validation_Font_size;
@property(nonatomic) IBInspectable CGRect    validation_fram;




@property (nonatomic) IBInspectable NSInteger borderWidth;
@property (nonatomic) IBInspectable CGFloat cornerRadious;
@property (nonatomic) IBInspectable CGFloat shadowOpacity;
@property (nonatomic) IBInspectable CGFloat shadowRadius;

@property (nonatomic) IBInspectable CGFloat padding_x;
@property (nonatomic) IBInspectable CGFloat padding_y;

@property (nonatomic,strong) IBInspectable UIColor *shadowColor;
@property (nonatomic,strong) IBInspectable UIColor *borderColor;

-(void) initDatePicker;

-(void) showValidateMsg:(NSString *) msg;

-(void) showValidateMsg;
-(void) hideValidateMsg;
-(void) hideMsg;
-(BOOL) validate;
-(BOOL) isValidate;

- (BOOL)validateString:(NSString *)pattern;

-(BOOL) EnableDecimalOnly: (UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString: (NSString *)string ;

@end

@protocol kTextFieldDelegate <NSObject>
- (void)KtextFieldDidEndEditing:(UITextField *)textField;
- (void)KtextFieldDidBeginEditing:(UITextField *)textField;



 - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text

-(void) validate:(NSString *) type isValid:(BOOL)isValid;

-(void) selectedValue:(NSString *) value;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;

@end
