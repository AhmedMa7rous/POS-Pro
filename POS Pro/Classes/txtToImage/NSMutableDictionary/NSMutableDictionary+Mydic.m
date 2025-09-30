//
//  Mydic.m
//  apptemplate
//
//  Created by khaled on 7/30/15.
//  Copyright (c) 2015 com.el-abda3. All rights reserved.
//

#import "NSMutableDictionary+Mydic.h"

@implementation NSMutableDictionary (Mydic)

-(id) objectForKeyMe:(id)aKey
{
    id obj = [self objectForKey:aKey];
    
    if (obj == nil) {
        return @"";
    }
    else
    {
        return obj;
    }
}


- (void)setObjectMe:(id)anObject forKey:(id)aKey
{
    BOOL addObj = YES;
    
    if (aKey == nil) {
        addObj = NO;
        
        if (anObject !=nil) {
              NSLog(@"Key == nil for Object=%@",anObject);
        }
        else{
          NSLog(@"Key == nil");
        }
      
    }
   
    if (anObject == nil) {
        addObj = NO;
        
        if (aKey != nil) {
            NSLog(@"Object == nil for key=%@",aKey);
        }
        else
        {
        NSLog(@"Object == nil");
        }
        
    }
    
    if (addObj == YES) {
            [self setObject:anObject forKey:aKey];
    }
  
}

@end
