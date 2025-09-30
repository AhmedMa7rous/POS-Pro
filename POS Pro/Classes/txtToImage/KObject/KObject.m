//
//  KObject.m
//  KLib
//
//  Created by khaled on 6/27/16.
//  Copyright © 2016 com.greatideas4ap. All rights reserved.
//

#import "KObject.h"
//#import "FBEncryptorAES.h"

@interface KObject()

@end
@implementation KObject
//
//+ (void)load
//{
//    
//  [self instance];
//    
//}
//
//
//+ (KObject *)instance
//{
//    static KObject *instance = nil;
//    
//    @synchronized(self)
//    {
//        if (instance == nil)
//        {
//            instance = [[KObject alloc] init];
//            [instance CheckKey:instance];
//        }
//    }
//    
//    return instance;
//}
//
//-(void) CheckKey:(KObject *)instance
//{
//    NSBundle* mainBundle = [NSBundle mainBundle];
//    NSString *appkey = [mainBundle objectForInfoDictionaryKey:@"appkey"];
//    NSString *bundle = [mainBundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
//    
//    if (![appkey isEqualToString:[self validekey]]) {
//      
//        @try {
//            
//         // NSString *e = [instance Encrypt :instance];
//            NSString *de = [instance Decrypt :appkey instance:instance];
//            
//            if (![de isEqualToString:bundle]  ) {
//                [instance FireExp];
//            }
//            
//        } @catch (NSException *exception) {
//            
//            [instance FireExp];
//            
//        } @finally {
//            
//        }
//        
//
//    }
//    
//    
//    
//}
//
//-(void) FireExp
//{
//    @throw [NSException exceptionWithName:NSInvalidArgumentException
//                                   reason:@"invalid appkey please check plist"
//                                 userInfo:nil];
//    
//    // NSAssert(NO,  @"invalid appkey please check plist") ;
//    
//}
//
//
//
//-(NSString *) Encrypt :(KObject *)instance
//{
//    
//    NSString *aPassword = [instance ps];
//    
//    NSBundle* mainBundle = [NSBundle mainBundle];
//    NSString *bundle = [mainBundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
//    
//   //NSData *data = [bundle dataUsingEncoding:NSUTF8StringEncoding];
//     // NSData *data = [[NSData alloc] initWithBase64EncodedString:bundle options:0];
//    
//    
// NSString *encString = @"";
//    
//    encString = [FBEncryptorAES encryptBase64String:bundle
//                                          keyString:aPassword
//                                      separateLines:NO];
//    
//   /*
//    
//    NSError *error;
//    NSData *encryptedData = [RNEncryptor encryptData:data
//                                        withSettings:kRNCryptorAES256Settings
//                                            password:aPassword
//                                               error:&error];
//    
//    
//    NSString *encString = [encryptedData base64EncodedStringWithOptions:0];
//    
//    */
//    
//    
//    
//    return encString;
//}
//
//
//-(NSString *) Decrypt :(NSString *) encrypted instance:(KObject *)instance
//{
//    NSString *aPassword =[instance ps];
//    
//  //  NSData *encryptedData = [[NSData alloc] initWithBase64EncodedString:encrypted options:0];
//    
//    
//
//     NSString* newStr = @"";
//    
//     newStr =  [FBEncryptorAES decryptBase64String:encrypted
//                              keyString:aPassword];
//    
//    
//    //    NSError *error;
//    
////    NSData *decryptedData = [RNDecryptor decryptData:encryptedData
////                                        withPassword:aPassword
////                                               error:&error];
////    
////    
////    
////   //   NSString *newStr = [decryptedData base64EncodedStringWithOptions:0];
////    
////    NSString* newStr = [NSString stringWithUTF8String:[decryptedData bytes]];
//    
//    
//    
//    return newStr;
//}
//
//
//-(NSString *) validekey
//{
//    return @"asdfwefvg435gtrwe43va124564798324safadf323fcc223dsfddsasdf";
//}
//
//
//-(NSString *) ps
//{
//    return @"tewewefsdfsaw";
//}




@end
