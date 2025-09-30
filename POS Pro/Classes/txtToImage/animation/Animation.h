//
//  Animation.h
//  genfa46
//
//  Created by khaled on 10/3/13.
//  Copyright (c) 2013 abda3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KObject.h"
@interface Animation : KObject

@property(nonatomic,strong) CAAnimation *anmi;
@property(nonatomic,strong) NSString *key;



+(Animation *) transform_scale;
+(Animation *) scale_button;
+(Animation *) Fade;
+(Animation *) Reveal;
+(Animation *) flip;
+(Animation *) flip_fromLeft;
+(Animation *) flip_fromRight;
+(Animation *) shake;
+(Animation *) suckEffect;
+(Animation *) cubeTop;
+(Animation *) cubeBottom;
+(Animation *) rotationINy;
+(Animation *) rotationINx;
+(Animation *) rotationINx_half;
+(Animation *) rippleEffect;
+(Animation *) MovinginfromLTR;
+(Animation *) MovinginfromRTL;
+(Animation *) changeTextTransitionMove;
+(Animation *) changeTextTransitionFade;
+(Animation *) MoveToTop;
+(Animation *) PageCurl;
@end
