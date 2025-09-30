//
//  UIViewController+textViewreposwithkeyboard.m
//  libraryapp
//
//  Created by khaled on 6/30/13.
//  Copyright (c) 2013 elbeyt. All rights reserved.
//

#import "UIViewController+textViewreposwithkeyboard.h"

UITextView *text_View;


CGFloat animatedDistance;
static const CGFloat KEYBOARD_ANIMATION_DURATION1 = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION1 = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION1 = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT1 = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT1 = 162;

@implementation UIViewController (textViewreposwithkeyboard)



-(void) textViewDidEndEditing:(UITextView *)textField
{
    if (textField.tag != -1) {
        
        if (TextViewaddDist ==0) {
            TextViewaddDist =60;
        }
 
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    CGRect viewFrame = self.view.frame;
    
    if (TextViewUsedTabBar == YES)
    {
       viewFrame.origin.y += animatedDistance  + 40;
    }
    else
    {
     viewFrame.origin.y += animatedDistance +TextViewaddDist  ;
    }
   
    
 
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION1];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
           }
}


-(void) textViewDidBeginEditing:(UITextView *)textField
{
        if (textField.tag != -1) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appEnteredBackgroundtextview)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
     text_View = textField;
    
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION1 * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION1 - MINIMUM_SCROLL_FRACTION1)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT1 * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT1 * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
            
            if (TextViewaddDist ==0) {
                TextViewaddDist =60;
            }
    if (TextViewUsedTabBar == YES)
    {
            viewFrame.origin.y -= animatedDistance + 40;
    }
    else
    {
        viewFrame.origin.y -= animatedDistance +TextViewaddDist  ;
    }

    
  
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION1];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
        }
    
   // NSLog(@"%ld" , (long)textField.tag);
}

- (void)appEnteredBackgroundtextview{
    [text_View resignFirstResponder];
}

@end
