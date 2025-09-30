//
//  Mydic.h
//  apptemplate
//
//  Created by khaled on 7/30/15.
//  Copyright (c) 2015 com.el-abda3. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Mydic)
- (void)setObjectMe:(id)anObject forKey:(id)aKey;
-(id) objectForKeyMe:(id)aKey;
@end
