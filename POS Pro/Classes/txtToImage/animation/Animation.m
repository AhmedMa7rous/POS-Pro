//
//  Animation.m
//  genfa46
//
//  Created by khaled on 10/3/13.
//  Copyright (c) 2013 abda3. All rights reserved.
//

#import "Animation.h"

NSString *const kCATransitionCube = @"cube";
NSString *const kCATransitionSuckEffect = @"suckEffect";
NSString *const kCATransitionOglFlip = @"oglFlip";
NSString *const kCATransitionRippleEffect = @"rippleEffect";
NSString *const kCATransitionPageCurl = @"pageCurl";
NSString *const kCATransitionPageUnCurl = @"pageUnCurl";
NSString *const kCATransitionCameraIrisHollowOpen = @"cameraIrisHollowOpen";
NSString *const kCATransitionCameraIrisHollowClose = @"cameraIrisHollowClose";

@implementation Animation

+(Animation *) transform_scale
{
    // Create a basic animation changing the transform.scale value
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    // Set the initial and the final values
    [animation setFromValue:[NSNumber numberWithFloat:1.5f]];
    [animation setToValue:[NSNumber numberWithFloat:1.f]];
    
    // Set duration
    [animation setDuration:0.5f];
    
    // Set animation to be consistent on completion
    [animation setRemovedOnCompletion:NO];
    [animation setFillMode:kCAFillModeForwards];
    
    // Add animation to the view's layer
   // [[theView layer] addAnimation:animation forKey:@"scale"];
    
   
    
    Animation *an = [[Animation alloc] init];
    an.anmi = animation ;
    an.key = @"scale";
    
    return an;
}

+(Animation *) scale_button
{
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.duration = 0.5;
    anim.repeatCount = 1;
    anim.autoreverses = YES;
    anim.removedOnCompletion = YES;
    anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)];
 
    
    Animation *an = [[Animation alloc] init];
    an.anmi = anim ;
    an.key = nil;
    
    return an;
}

+(Animation *) flip
{
    CATransition* transition = [CATransition animation];
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    transition.duration = 1.0f;
    transition.type =  @"flip";
    transition.subtype = @"fromTop";
 
    
    Animation *an = [[Animation alloc] init];
    an.anmi = transition ;
    an.key = kCATransition;
    
    return an;
}

+(Animation *) flip_fromRight
{
    CATransition* transition = [CATransition animation];
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    transition.duration = 0.5f;
    transition.type =  @"flip";
    transition.subtype = @"fromRight";
    
    
    Animation *an = [[Animation alloc] init];
    an.anmi = transition ;
    an.key = kCATransition;
    
    return an;
}


+(Animation *) flip_fromLeft
{
    CATransition* transition = [CATransition animation];
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    transition.duration = 0.5f;
    transition.type =  @"flip";
    transition.subtype = @"fromLeft";
    
    
    Animation *an = [[Animation alloc] init];
    an.anmi = transition ;
    an.key = kCATransition;
    
    return an;
}


+(Animation *) Reveal
{
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromTop;
    
    
    Animation *an = [[Animation alloc] init];
    an.anmi = transition ;
    an.key = kCATransition;
    
    return an;
}

+(Animation *) Fade
{
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromTop;
    
    
    Animation *an = [[Animation alloc] init];
    an.anmi = transition ;
    an.key = kCATransition;
    
    return an;
}
+(Animation *) suckEffect
{
    CATransition *animation = [CATransition animation];
    animation.type = @"suckEffect";
    animation.duration = 2.0f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
   
    
    Animation *an = [[Animation alloc] init];
    an.anmi = animation ;
 
    
    return an;

}

+(Animation *) rippleEffect
{
    CATransition *animation = [CATransition animation];
    // animation.type = @"suckEffect";
    animation.duration = 2.0f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = @"rippleEffect";
    animation.subtype = @"fromTop";
    
    Animation *an = [[Animation alloc] init];
    an.anmi = animation ;
    
    
    return an;
    
}

+(Animation *) cubeTop
{
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionCube;
    animation.duration = 1.0f;
     animation.timingFunction = UIViewAnimationCurveEaseInOut;
     animation.subtype = kCATransitionFromRight;
    
    Animation *an = [[Animation alloc] init];
    an.anmi = animation ;
    an.key = kCATransition;
    
    return an;
    
}
+(Animation *) cubeBottom
{
    CATransition *animation = [CATransition animation];
    animation.type = @"cube";
    animation.duration = 1.0f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.subtype = kCATransitionFromBottom;
    
    Animation *an = [[Animation alloc] init];
    an.anmi = animation ;
    an.key = kCATransition;
    
    return an;
    
}


+(Animation *) shake
{
    CABasicAnimation* shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    shake.fromValue = [NSNumber numberWithFloat:-0.1];
    
    shake.toValue = [NSNumber numberWithFloat:+0.1];
    
    shake.duration = 0.1;
    
    shake.autoreverses = YES;
    
    shake.repeatCount = 4;
    
    
    Animation *an = [[Animation alloc] init];
    an.anmi = shake ;
    an.key = kCATransition;
    
    return an;
}

+(Animation *) rotationINy
{
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    anim.duration = 2;
    anim.repeatCount = 1;
    anim.autoreverses = NO;
    anim.fromValue = [NSNumber numberWithFloat:M_PI * 1.5];
    anim.toValue = [NSNumber numberWithFloat: 2 * M_PI ];
    
    Animation *an = [[Animation alloc] init];
    an.anmi = anim ;
    an.key = @"rotation";
    
    return an;
}
+(Animation *) PageCurl
{
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionPageCurl;
    animation.duration = 1.0f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.subtype = kCATransitionFromRight;
    
    Animation *an = [[Animation alloc] init];
    an.anmi = animation ;
    an.key = kCATransition;
    
    return an;
    
}

+(Animation *) rotationINx_half
{
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    anim.duration = 2;
    anim.repeatCount = 1;
    anim.autoreverses = NO;
    anim.fromValue = [NSNumber numberWithFloat:M_PI * 1.5];
    anim.toValue = [NSNumber numberWithFloat: 2 * M_PI ];
    
    Animation *an = [[Animation alloc] init];
    an.anmi = anim ;
    an.key = @"rotation";
    
    return an;
}
+(Animation *) rotationINx
{
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    anim.duration = 1;
    anim.repeatCount = 1;
    anim.autoreverses = NO;
    anim.fromValue = [NSNumber numberWithFloat:0];
    anim.toValue = [NSNumber numberWithFloat: 2 * M_PI ];
    
 
    
    Animation *an = [[Animation alloc] init];
    an.anmi = anim ;
    an.key = @"rotation";
    
    return an;
}
+(Animation *) MovinginfromLTR
{
    
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    theAnimation.duration=1;
    theAnimation.repeatCount=1;
    theAnimation.autoreverses=NO;
    theAnimation.fromValue=[NSNumber numberWithFloat:-300];
    theAnimation.toValue=[NSNumber numberWithFloat:0];
 
    Animation *an = [[Animation alloc] init];
    an.anmi = theAnimation ;
    an.key = @"animateLayer";
    
    return an;
}
+(Animation *) MovinginfromRTL
{
    
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    theAnimation.duration=1;
    theAnimation.repeatCount=1;
    theAnimation.autoreverses=NO;
    theAnimation.fromValue=[NSNumber numberWithFloat:300];
    theAnimation.toValue=[NSNumber numberWithFloat:0];
    
    Animation *an = [[Animation alloc] init];
    an.anmi = theAnimation ;
    an.key = @"animateLayer";
    
    return an;
}
+(Animation *) changeTextTransitionMove
{
    
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.type = kCATransitionPush;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  
    Animation *an = [[Animation alloc] init];
    an.anmi = animation ;
    an.key = @"changeTextTransition";
    
    return an;
}
+(Animation *) changeTextTransitionFade
{
    
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    Animation *an = [[Animation alloc] init];
    an.anmi = animation ;
    an.key = @"changeTextTransition";
    
    return an;
}

+(Animation *) MoveToTop
{
    
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"bounds.size.height"];
    theAnimation.duration=0.3;
    theAnimation.repeatCount=1;
    theAnimation.autoreverses=NO;
    theAnimation.fromValue=[NSNumber numberWithFloat:0];
    theAnimation.toValue=[NSNumber numberWithFloat:135];
    
    Animation *an = [[Animation alloc] init];
    an.anmi = theAnimation ;
    an.key = nil;
    
    return an;
}

@end
