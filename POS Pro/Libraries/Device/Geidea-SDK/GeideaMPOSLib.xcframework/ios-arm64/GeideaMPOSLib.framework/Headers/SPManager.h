//
//  SPManager.h
//  SP530Core
//
//  Created by Desmond on 20/11/2017.
//  Copyright © 2017 Spectra Technologies Holdings Company Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
/// Class docs
@interface SPManager : NSObject
/// Method docs
+ (instancetype)sharedManager;
- (void) createData;
@end
