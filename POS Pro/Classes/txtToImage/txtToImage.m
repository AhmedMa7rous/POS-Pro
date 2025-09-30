//
//  txtToImage.m
//  pos
//
//  Created by Khaled on 1/14/20.
//  Copyright © 2020 khaled. All rights reserved.
//

#import "txtToImage.h"

@implementation txtToImage

-(UIImage *) test
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"Hello. That is a test attributed string."];
    [str addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(3,5)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(10,7)];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0] range:NSMakeRange(20, 10)];
    UIImage *customImage = [self imageFromAttributedString:str  size: [str size] ];
    
    return customImage;
}

 
- (UIImage *)imageFromAttributedString:(NSAttributedString *)text size:(CGSize) size
{
 
//    @autoreleasepool{
        CGRect rect = CGRectMake(0, 0, size.width,  size.height);
        UIColor *backColor = UIColor.whiteColor ;
        
        UIGraphicsBeginImageContextWithOptions(text.size, NO, 0.0);
        
        [backColor setFill];
        UIRectFill(rect) ;

        
        // draw in context
        [text drawAtPoint:CGPointMake(0.0, 0.0)];
        
        // transfer image
        UIImage *image = [UIGraphicsGetImageFromCurrentImageContext() imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIGraphicsEndImageContext();
        
        return image;
//    }
   
}


@end
