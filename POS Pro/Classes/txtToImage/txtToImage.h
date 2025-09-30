//
//  txtToImage.h
//  pos
//
//  Created by Khaled on 1/14/20.
//  Copyright © 2020 khaled. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface txtToImage : NSObject
-(UIImage *) test;
 
- (UIImage *)imageFromAttributedString:(NSAttributedString *)text size:(CGSize) size;

@end

NS_ASSUME_NONNULL_END
