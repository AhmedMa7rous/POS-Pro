//
//  clsfunction.m
//  arabia
//
//  Created by khaled on 3/31/14.
//  Copyright (c) 2014 abda3. All rights reserved.
//

#import "clsfunction.h"



@implementation clsfunction

+(NSString *) getTextEmoj:(NSString*) str
{
    
    
    NSData *data = [str  dataUsingEncoding:NSNonLossyASCIIStringEncoding];
   
    NSString *txt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
  
    return txt;
}


+(NSString *) readvalue:(id) value
{
 
    NSString *temp= @"";
     if ([value isKindOfClass:[NSNull class]])
    {
        temp = @"";
    }
   else if (value != nil) {
        temp = [NSString stringWithFormat:@"%@",value];
    }
   
  return temp;
}
+(NSString *) StringInNav:(NSString *) str
{
    if (str == nil) {
          return nil;
    }
    int len=18;
    if (str.length <= len) {
        return str;
    }
    else
    {
        str = [str substringToIndex:len];
        str = [NSString stringWithFormat:@"%@ ..." ,str];
        return str;
    }
    
    return nil;
}


+(NSArray *) readnitmes :(NSArray *) json count:(int)count
{
    if (json == nil) {
        return nil;
    }
    
    if (![json isKindOfClass:[NSDictionary class]]) {
        NSMutableArray * arrdep = [[NSMutableArray alloc] init];
        
        NSMutableArray * temprow = [[NSMutableArray alloc] init];
        // count >=count
        if ([json count] >=count) {
            
            int x =0;
            int b = [json count] % count;
            
            for (int i =0; i<  [json count]; i++) {
                x +=1 ;
                [temprow addObject:[json objectAtIndex:i]];
                if (x == count) {
                    
                    x=0;
                    [arrdep addObject:[temprow copy] ];
                    [temprow removeAllObjects];
                }
                
                
            }
            
            if (b> 0) {
                [arrdep addObject:[temprow copy] ];
            }
        }
        else
            
        {
            
            
            [arrdep addObject: [json  copy] ];
        }
        
        return arrdep;
    }
    else
        return nil;
}



+(CGSize) StringSize :(NSString *) txt font:(UIFont *) font maxWidth:(int)maxWidth
{
     CGSize constraintSize = CGSizeMake(maxWidth, MAXFLOAT);
    CGSize labelSize      = [txt sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByCharWrapping];
    
    
    return labelSize;
}
+(NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}



+ (CGSize)sizeOfStringWithFont:(NSString *) txt font:(UIFont *)font {
    return [self sizeOfStringWithFont:txt font:font constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
}

+ (CGSize)sizeOfStringWithFont:(NSString *) txt font:(UIFont *)font constrainedToSize:(CGSize)size
{
    return [self sizeOfStringWithFont:txt font:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
}

+ (CGSize)sizeOfStringWithFont: (NSString *) txt font:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode {
    
 
        
        NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:txt];
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:size];
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        [layoutManager addTextContainer:textContainer];
        [textStorage addLayoutManager:layoutManager];
        [textStorage addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, txt.length)];
        [textContainer setLineBreakMode:lineBreakMode];
        [textContainer setLineFragmentPadding:0.0];
        (void)[layoutManager glyphRangeForTextContainer:textContainer];
        return [layoutManager usedRectForTextContainer:textContainer].size;
        
 
    
    return [txt sizeWithFont:font
            constrainedToSize:size
                lineBreakMode:lineBreakMode];
}


@end
