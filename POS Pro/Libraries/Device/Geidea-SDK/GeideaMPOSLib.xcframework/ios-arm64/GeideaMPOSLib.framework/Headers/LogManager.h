//
//  LogManager.h
//  SP530Core
//
//  Created by Desmond on 10/11/2017.
//  Copyright © 2017 Spectra Technologies Holdings Company Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Class docs
@interface LogManager : NSObject
+(LogManager *)sharedInstance;
@property (nonatomic, strong, readonly) NSString* log;

/// Method docs
- (void) addLog:(NSString*) log;
- (void) clearLog;
- (NSString*)logPath;
@end
