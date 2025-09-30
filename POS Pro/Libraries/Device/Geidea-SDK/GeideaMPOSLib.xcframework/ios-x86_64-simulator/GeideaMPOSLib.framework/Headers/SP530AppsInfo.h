//
//  SP530AppsInfo.h
//  SP530Core
//
//  Created by spectra on 22/2/2016.
//  Copyright © 2016 Spectra Technologies Holdings Company Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SP530AppsInfo : NSObject
{
    
}

#pragma mark Property
/**
 *  @discussion Contains the application module name
 */
@property(strong, nonatomic)NSString *Name;

/**
 *  @discussion Contains the Module Version
 */
@property(strong, nonatomic)NSString *Verion;

/**
 *  @discussion Contains the application module sub Version
 */
@property(strong, nonatomic)NSString *SubVersion;

/**
 *  @discussion Contains the application module real CRC32 checksum
 */
@property(strong, nonatomic)NSString *RealChecksum;

/**
 *  @discussion Contains the application module display CRC32 checksum
 */
@property(strong, nonatomic)NSString *DisplayChecksum;



@end
