//
//  itemslist.m
//  store
//

//  Copyright (c) 2013 el-adbda3. All rights reserved.
//

#import "myuserdefaults_old.h"

@implementation myuserdefaults_old
/*
+(NSString *) replace:(NSString *) st
{
  
        st = [st stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        st = [st stringByReplacingOccurrencesOfString:@"." withString:@""];
        st = [st stringByReplacingOccurrencesOfString:@"/" withString:@""];
        st = [st stringByReplacingOccurrencesOfString:@"?" withString:@""];
        st = [st stringByReplacingOccurrencesOfString:@"&" withString:@""];
        st = [st stringByReplacingOccurrencesOfString:@"=" withString:@""];
        st = [st stringByReplacingOccurrencesOfString:@"" withString:@""];
    
      st = [st stringByReplacingOccurrencesOfString:@"[" withString:@""];
      st = [st stringByReplacingOccurrencesOfString:@"]" withString:@""];
      st = [st stringByReplacingOccurrencesOfString:@")" withString:@""];
      st = [st stringByReplacingOccurrencesOfString:@"(" withString:@""];
   // st =@"0123456789_newskolalwatnnetappapiphpmoditemssnewscid27newskolalwatnnetappapiphpmoditemssnewscid27newskolalwatnnetappapiphpmoditemssnewscid27newskolalwatnnetappapiphpmoditemssnewscid27newskolalwatnnetappapiphpmoditemssnewscid27ddddddddddafasfdasdfasdfasfdasdfddadf132";
    
    int len = (int) [st length];
    if (len >=255) {
        int start = len - 255 ;
        st = [st substringFromIndex:start];
    }
    
    
    return st;
    
}

+(NSString *) printPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
 
    // NSFileManager *fileManager = [NSFileManager defaultManager];
    //    if ( ![fileManager fileExistsAtPath:filePath] ) {
    //        filePath = [[[NSBundle mainBundle] resourcePath ]stringByAppendingPathComponent:filename];
    //    }
    
       NSLog(@"path : %@" , [NSString stringWithFormat:@"%@" ,documentsPath] );
    return  [NSString stringWithFormat:@"%@" ,documentsPath] ;
}
+(NSString *) path: (NSString *) filename
{
    filename = [myuserdefaults replace:filename];
   
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath  stringByAppendingPathComponent:filename];
    
    // NSFileManager *fileManager = [NSFileManager defaultManager];
//    if ( ![fileManager fileExistsAtPath:filePath] ) {
//        filePath = [[[NSBundle mainBundle] resourcePath ]stringByAppendingPathComponent:filename];
//    }
    
//   NSLog(@"path : %@" , [NSString stringWithFormat:@"%@.plist" ,filePath] );
  return  [NSString stringWithFormat:@"%@.plist" ,filePath] ;
    
}

+(NSString *) getname:(NSString *)ItemID  Prefix:(NSString*) Prefix
{
    NSString *name =[NSString stringWithFormat:@"%@%@",Prefix,ItemID];
   name = [myuserdefaults replace:name];
    return name;
}

+(NSString *) getname:(NSString *)ItemID  suffix:(NSString*) suffix
{
    NSString *name =[NSString stringWithFormat:@"%@%@",ItemID,suffix];
    name = [myuserdefaults replace:name];
    return name;
}



+(void) isuploadfile:(NSString *) filename
{
    //  NSNumber *isUploaded = [filename valueForAttribute:NSMetadataUbiquitousItemIsUploadedKey];
    //    NSNumber *isUploading = [file valueForAttribute:NSMetadataUbiquitousItemIsUploadingKey];
    //    NSNumber *uploadPercent = [file valueForAttribute:NSMetadataUbiquitousItemPercentUploadedKey];
    
}
//+(NSArray *) lstitems_withkey:(NSString*) Prefix
//{
//    
//    Prefix = [NSString stringWithFormat:@"appcach%@" , Prefix];
//    
//    //    return items;
//    
//    NSMutableArray *items = [[NSMutableArray alloc] init]  ;
//    NSDictionary *dictionary =     [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
//    
//    
//    for (NSString *key in [dictionary allKeys]) {
//        if ([key hasPrefix:Prefix]) {
//            
//            
//            NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
//            
//            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//            NSString *temp =[NSKeyedUnarchiver unarchiveObjectWithData:data] ;
//            if (temp != nil) {
//                [dic setObjectMe:[NSKeyedUnarchiver unarchiveObjectWithData:data] forKey:key];
//                
//                [items addObject:dic];
//            }
//          
//            
//        }
//    }
//    
//    return items;
//}

+(NSArray *) lstitems:(NSString*) Prefix
{
 
//   Prefix = [NSString stringWithFormat:@"appcach%@" , Prefix];
//    
//    
//    NSMutableArray *items = [[NSMutableArray alloc] init]  ;
//    NSDictionary *dictionary =     [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
//    
//    
//    for (NSString *key in [dictionary allKeys]) {
//        if ([key hasPrefix:Prefix]) {
//            
//            
//            NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
//            
//            [items addObject:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
//            
//        }
//    }
//    
//    return items;
    
    NSMutableArray *items = [[NSMutableArray alloc] init]  ;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:NULL];
    for (int count = 0; count < (int)[directoryContent count]; count++)
    {
        NSString *filename =[directoryContent objectAtIndex:count];
       // NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
         if ([ filename hasPrefix:Prefix]) {
             
             filename = [filename stringByReplacingOccurrencesOfString:@".plist" withString:@""];
             
             id x =[myuserdefaults getitem:filename Prefix:@""] ;
             if (x != nil) {
                            [items addObject:x];
             }
  
         }
        
    }
    
    
     return items;
}


+(NSArray *) lstitems_suffix:(NSString*) suffix
{
    
    NSMutableArray *items = [[NSMutableArray alloc] init]  ;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:NULL];
    
    suffix = [NSString stringWithFormat:@"%@.plist",suffix];
    
    
    for (int count = 0; count < (int)[directoryContent count]; count++)
    {
        NSString *filename =[directoryContent objectAtIndex:count];
        
        // NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
        if ([ filename hasSuffix:suffix]) {
            
            filename = [filename stringByReplacingOccurrencesOfString:@".plist" withString:@""];
            
            id x =[myuserdefaults getitem:filename suffix:@""] ;
            if (x != nil) {
                [items addObject:x];
            }
            
        }
        
    }
    
    
    return items;
}

+(void) deleteAll:(NSArray *) ignoreFiles
{
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:NULL];
    for (int count = 0; count < (int)[directoryContent count]; count++)
    {
        NSString *filename =[directoryContent objectAtIndex:count];
        filename = [filename stringByReplacingOccurrencesOfString:@".plist" withString:@""];

        NSUInteger fooIndex = [ignoreFiles indexOfObject: filename];
 
        if(NSNotFound == fooIndex) {
            
            
            [myuserdefaults deleteitems:filename Prefix:@""];
        }
        
    }
    
    
    
}

+(void) Deletelstitems:(NSString*) Prefix
{
 
 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:NULL];
    for (int count = 0; count < (int)[directoryContent count]; count++)
    {
        NSString *filename =[directoryContent objectAtIndex:count];
        // NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
        if ([ filename hasPrefix:Prefix]) {
            
            filename = [filename stringByReplacingOccurrencesOfString:@".plist" withString:@""];
            
            [myuserdefaults deleteitems:filename Prefix:@""];
        }
        
    }
    
    
 
}

+(NSArray *) lstfiles_fullPath:(NSString*) Prefix
{
    
    
    NSMutableArray *items = [[NSMutableArray alloc] init]  ;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:NULL];
    for (int count = 0; count < (int)[directoryContent count]; count++)
    {
        NSString *filename =[directoryContent objectAtIndex:count];
        
        // NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
        if ([ filename hasPrefix:Prefix]) {
            
//            filename = [filename stringByReplacingOccurrencesOfString:@".plist" withString:@""];
            filename = [NSString stringWithFormat:@"%@/%@", documentsPath , filename];
            [items addObject:filename];
        }
        
    }
    
    
    return items;
}

+(NSArray *) lstfiles:(NSString*) Prefix
{
    
 
    NSMutableArray *items = [[NSMutableArray alloc] init]  ;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:NULL];
    for (int count = 0; count < (int)[directoryContent count]; count++)
    {
        NSString *filename =[directoryContent objectAtIndex:count];
        // NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
        if ([ filename hasPrefix:Prefix]) {
            
            filename = [filename stringByReplacingOccurrencesOfString:@".plist" withString:@""];
            
                  [items addObject:filename];
        }
        
    }
    
    
    return items;
}

+(NSArray *) alllstitems
{
  
    NSMutableArray *items = [[NSMutableArray alloc] init]  ;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:NULL];
    for (int count = 0; count < (int)[directoryContent count]; count++)
    {
        NSString *filename =[directoryContent objectAtIndex:count];
        // NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
  
            
            filename = [filename stringByReplacingOccurrencesOfString:@".plist" withString:@""];
            
           // [items addObject:[myuserdefaults getitem:filename Prefix:@""]];
        [items addObject:filename];
        
    }
    
    
    return items;
}

+(id) getitem:(NSString *)ItemID   Prefix:(NSString*) Prefix defalutValue:(NSString *)defalutValue
{
    id obj = [self getitem:ItemID Prefix:Prefix ];
    if (obj == nil) {
        return defalutValue;
    }
    else
    {
        return obj;
    }
}

+(id) getitem:(NSString *)ItemID   suffix:(NSString*) suffix
{
    //  return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",Prefix,ItemID]];
    //    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"appcach%@%@",Prefix,ItemID]];
    //    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSString *key =[myuserdefaults getname:ItemID suffix:suffix];
    
    
    NSString   *filePath=[myuserdefaults path:key];
    
    
    // NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:@"/Users/khaled/Library/Application Support/iPhone Simulator/7.1/Applications/9FA3A3BD-D437-4D82-905D-CCEA9C3EC0B3/Documents/lastupdatenews.plist"];
    
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    if (data == nil)
    {
        return nil;
    }
    else
    {
        id d =[NSKeyedUnarchiver unarchiveObjectWithData:[data objectForKey:key]];
        
        return d;
    }
    
}

+(id) getitem:(NSString *)ItemID   Prefix:(NSString*) Prefix
{
    //  return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",Prefix,ItemID]];
//    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"appcach%@%@",Prefix,ItemID]];
//    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
     NSString *key =[myuserdefaults getname:ItemID Prefix:Prefix];
    
 
    NSString   *filePath=[myuserdefaults path:key];
    
   
   // NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:@"/Users/khaled/Library/Application Support/iPhone Simulator/7.1/Applications/9FA3A3BD-D437-4D82-905D-CCEA9C3EC0B3/Documents/lastupdatenews.plist"];
    
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    if (data == nil)
    {
        return nil;
    }
    else
    {
     id d =[NSKeyedUnarchiver unarchiveObjectWithData:[data objectForKey:key]];
    
    return d;
    }
    
}



+(BOOL) isitems:(NSString *) ItemID  Prefix:(NSString*) Prefix
{
 
//    if([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"appcach%@%@",Prefix,ItemID]] != nil) {
//        return YES;
//    }
//    else
//        return NO;
    
      NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *filePath =[myuserdefaults getname:ItemID Prefix:Prefix];
    filePath  = [myuserdefaults path:filePath];
      if ( [fileManager fileExistsAtPath:filePath] ) {
          return YES;
     }
    else
    {
    
    return NO;
    }
    
}

+(void) deleteitems:(NSString *)ItemID   Prefix:(NSString*) Prefix
{
   // [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"appcach%@%@",Prefix,ItemID]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
  
    NSString *key =[myuserdefaults getname:ItemID Prefix:Prefix];
    NSString   *filePath=[myuserdefaults path:key];
    
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    
    if (success) {
         NSLog(@"delete file :%@",filePath);
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}

+(void) Setitems:(NSString *)ItemID SetValue:(id) dic  Prefix:(NSString*) Prefix
{
    //[[NSUserDefaults standardUserDefaults] setObjectMe:dic forKey:[NSString stringWithFormat:@"%@%@",Prefix,ItemID]];
    
     NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
//    
//    [[NSUserDefaults standardUserDefaults] setObjectMe:data forKey:[NSString stringWithFormat:@"appcach%@%@",Prefix,ItemID]];
    
    NSString *key =[myuserdefaults getname:ItemID Prefix:Prefix];
    

    NSDictionary *dicst = [[NSDictionary alloc] initWithObjectsAndKeys:data,key, nil];
 
   [ dicst writeToFile:[myuserdefaults path:key] atomically:YES];
    
}




+(void) Setitems:(NSString *)ItemID SetValue:(id) dic  Prefix:(NSString*) Prefix directory:(NSSearchPathDirectory) directory
{
    //[[NSUserDefaults standardUserDefaults] setObjectMe:dic forKey:[NSString stringWithFormat:@"%@%@",Prefix,ItemID]];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    //
    //    [[NSUserDefaults standardUserDefaults] setObjectMe:data forKey:[NSString stringWithFormat:@"appcach%@%@",Prefix,ItemID]];
    
    NSString *key =[myuserdefaults getname:ItemID Prefix:Prefix];
    
    
    NSDictionary *dicst = [[NSDictionary alloc] initWithObjectsAndKeys:data,key, nil];
    
    [ dicst writeToFile:[myuserdefaults path:key directory:directory] atomically:YES];
    
}


+(NSString *) path: (NSString *) filename directory:(NSSearchPathDirectory )directory
{
    filename = [myuserdefaults replace:filename];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(directory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath  stringByAppendingPathComponent:filename];
    
    // NSFileManager *fileManager = [NSFileManager defaultManager];
    //    if ( ![fileManager fileExistsAtPath:filePath] ) {
    //        filePath = [[[NSBundle mainBundle] resourcePath ]stringByAppendingPathComponent:filename];
    //    }
    
    //   NSLog(@"path : %@" , [NSString stringWithFormat:@"%@.plist" ,filePath] );
    return  [NSString stringWithFormat:@"%@.plist" ,filePath] ;
    
}


+(id) getitem:(NSString *)ItemID   Prefix:(NSString*) Prefix directory:(NSSearchPathDirectory) directory
{
    //  return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",Prefix,ItemID]];
    //    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"appcach%@%@",Prefix,ItemID]];
    //    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSString *key =[myuserdefaults getname:ItemID Prefix:Prefix];
    
    
    NSString   *filePath=[myuserdefaults path:key directory:directory];
    
    
    // NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:@"/Users/khaled/Library/Application Support/iPhone Simulator/7.1/Applications/9FA3A3BD-D437-4D82-905D-CCEA9C3EC0B3/Documents/lastupdatenews.plist"];
    
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    if (data == nil)
    {
        return nil;
    }
    else
    {
        id d =[NSKeyedUnarchiver unarchiveObjectWithData:[data objectForKey:key]];
        
        return d;
    }
    
}

+(NSArray *) lstitems:(NSString*) Prefix  directory:(NSSearchPathDirectory) directory
{
 
    
    NSMutableArray *items = [[NSMutableArray alloc] init]  ;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(directory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:NULL];
    for (int count = 0; count < (int)[directoryContent count]; count++)
    {
        NSString *filename =[directoryContent objectAtIndex:count];
        // NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
        if ([ filename hasPrefix:Prefix]) {
            
            filename = [filename stringByReplacingOccurrencesOfString:@".plist" withString:@""];
            
            id x =[myuserdefaults getitem:filename Prefix:@"" directory:directory] ;
            if (x != nil) {
                [items addObject:x];
            }
            
        }
        
    }
    
    
    return items;
}

+(void) Deletelstitems:(NSString*) Prefix   directory:(NSSearchPathDirectory) directory
{
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(directory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:NULL];
    for (int count = 0; count < (int)[directoryContent count]; count++)
    {
        NSString *filename =[directoryContent objectAtIndex:count];
        // NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
        if ([ filename hasPrefix:Prefix]) {
            
            filename = [filename stringByReplacingOccurrencesOfString:@".plist" withString:@""];
            
            [myuserdefaults deleteitems:filename Prefix:@"" directory:directory];
        }
        
    }
    
}

+(void) deleteitems:(NSString *)ItemID   Prefix:(NSString*) Prefix directory:(NSSearchPathDirectory) directory
{
    // [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"appcach%@%@",Prefix,ItemID]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *key =[myuserdefaults getname:ItemID Prefix:Prefix];
    NSString   *filePath=[myuserdefaults path:key directory:directory];
    
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    
    if (success) {
        NSLog(@"delete file :%@",filePath);
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}
*/
@end
