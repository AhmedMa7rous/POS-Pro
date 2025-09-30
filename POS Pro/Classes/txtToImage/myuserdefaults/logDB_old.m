//
//  myuserdefaults.m
//  pos
//
//  Created by Khaled on 1/20/20.
//  Copyright © 2020 khaled. All rights reserved.
//

#import "logDB_old.h"
#import "JsonToDictionary.h"
 

//FMDatabase *cash_db;

@implementation logDB_old
//
//+(FMDatabase *) cash_db
//{
//    [sharedInstance.Queue_db inDatabase:^(FMDatabase * _Nonnull db) {
//
//    }];
//
//    FMDatabase *db = [self sharedManager].db ;
////    [db  close];
////    [db open] ;
//
//    return db ;
//}


+(void) initDataBase
{
    [self sharedManager].dbPath = [self pathDataBase];
}

+(FMDatabaseQueue *)  databaseQueue
{
     if ([self sharedManager].dbPath == nil)
     {
         [self sharedManager].dbPath = [self pathDataBase];
     }
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:[self sharedManager].dbPath];

//    FMDatabaseQueue *db = [self sharedManager].Queue_db ;
    return queue;
}
 
static logDB_old *sharedInstance = nil;

 + (logDB_old *)sharedManager
 {
     if (sharedInstance == nil)
     {
         static dispatch_once_t  oncePredecate;

           dispatch_once(&oncePredecate,^{
               sharedInstance=[[logDB_old alloc] init];

            });
         
        
         
     }
     
     
     
     
//  if (sharedInstance.Queue_db == nil)
//          {
//              sharedInstance.Queue_db = [ myuserdefaults checkDataBase];
//          }
     
   return sharedInstance;
 }

//- (id)init {
//  if (self = [super init]) {
//      _db = [myuserdefaults checkDataBase] ;
//  }
//  return self;
//}

+(FMDatabaseQueue *) getDatabase:(NSString *) filePath
{
 //
  //  FMDatabase *db = [FMDatabase databaseWithPath:filePath];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:filePath];

 
//    if (![db open]) {
//        // [db release];   // uncomment this line in manual referencing code; in ARC, this is not necessary/permitted
//        db = nil;
//
//    }
    
 
    
//    cash_db = db ;
  
    return queue ;
  
}

+(NSString *) pathDataBase
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    
       NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
       NSString *documentsPath = [paths objectAtIndex:0];
    
       NSString *filePath = [documentsPath stringByAppendingPathComponent:@"log.db"];

        NSFileManager *fileManager = [NSFileManager defaultManager];
           if ( ![fileManager fileExistsAtPath:filePath] ) {
               
             NSString*  fromPath = [[[NSBundle mainBundle] resourcePath ]stringByAppendingPathComponent:@"log.db"];
               
               [fileManager copyItemAtPath:fromPath toPath:filePath error:nil];
           }
    dispatch_semaphore_signal(semaphore);
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

     
    NSLog(@"path : %@" , [NSString stringWithFormat:@"%@" ,filePath] );

    return  filePath;  // [self getDatabase:filePath];
}

+(NSString *) printPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
 
 
       NSLog(@"path : %@" , [NSString stringWithFormat:@"%@" ,documentsPath] );
    return  [NSString stringWithFormat:@"%@" ,documentsPath] ;
}

+(void) deleteDatabase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
     
        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"log.db"];

         NSFileManager *fileManager = [NSFileManager defaultManager];
        if (  [fileManager fileExistsAtPath:filePath] ) {
                  
            [fileManager removeItemAtPath:filePath error:nil];
            [self sharedManager].dbPath = nil ;
         }
}



//+(BOOL) isitems:(NSString *) ItemID   Prefix:(NSString*) Prefix {
//    NSArray *arr = [NSArray arrayWithObjects:ItemID,Prefix, nil];
//
//  __block  BOOL exist =false;
//
//    [sharedInstance.Queue_db inDatabase:^(FMDatabase *db) {
//
//        FMResultSet *s = [[self cash_db] executeQuery:@"SELECT COUNT(*) FROM cash where key=? and Prefix=?" withArgumentsInArray:arr];
//           if ([s next]) {
//               int totalCount = [s intForColumnIndex:0];
//               if (totalCount > 0)
//               {
//                   exist = YES;
//               }
//
//                  [s close];
//           }
//
//            [s close];
//    }];
//
//    return exist;
//}

+(void) lstitems:(NSString*) Prefix completionAction:(resultCompletionBlock) completionBlock {
    
    
    
   [[self databaseQueue] inDatabase:^(FMDatabase *db) {
           
    NSMutableArray *lst = [[NSMutableArray alloc] init];
    
    NSArray *arr = [NSArray arrayWithObjects:Prefix, nil];
    
    FMResultSet *s = [db executeQuery:@"SELECT * FROM cash where  Prefix=?" withArgumentsInArray:arr];
    
    while ([s next]) {
        //retrieve values for each record
        NSString *st = [s stringForColumn:@"data"];
        [lst addObject:st];
    }
       [s close];
       
       completionBlock(lst);
    
   }];
 
}
+(NSArray *) lstitems:(NSString*) Prefix  limit:(NSArray *)limit orderASC:(BOOL) orderASC  {
    
    NSMutableArray *lst = [[NSMutableArray alloc] init];

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    
   [[self databaseQueue] inDatabase:^(FMDatabase *db) {
    
       NSString *sql = @"SELECT * FROM cash where  Prefix=? order by updated_at asc limit ?,? ";
       
     if (orderASC == NO)
     {
         sql = @"SELECT * FROM cash where  Prefix=? order by updated_at desc limit ?,? ";
     }
       
    NSArray *arr = [NSArray arrayWithObjects:Prefix,limit[0],limit[1], nil];
    
    FMResultSet *s = [db executeQuery:sql  withArgumentsInArray:arr];
    
    while ([s next]) {
        //retrieve values for each record
        NSString *stringJson = [s stringForColumn:@"data"];
        NSString *time_in_ms = [s stringForColumn:@"key"];
        int ID = [s intForColumn:@"id"];

        NSData *data = [stringJson dataUsingEncoding:NSUTF8StringEncoding];
        id value =  [NSJSONSerialization JSONObjectWithData:data   options:0  error:nil];
        if (value != nil)
        {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:value];
            
            [dic setObject:[NSString stringWithFormat:@"%d" , ID] forKey:@"cash_id"];
            [dic setObject:time_in_ms forKey:@"cash_key"];

            [lst addObject:dic];

        }
    }
       [s close];
       
      dispatch_semaphore_signal(semaphore);

    
   }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    
    return lst;
 
}


+(void) Setitems:(NSString *)ItemID SetValue:(id) dic  Prefix:(NSString*) Prefix   {
    
    //    BOOL isExist = [self isitems:ItemID Prefix:Prefix];
    
    [[self databaseQueue] inDatabase:^(FMDatabase *db) {
        
        NSString *jsonString = [self JSONString:dic prettyPrinted:true];
        
        BOOL isExist = false ;
        
        FMResultSet *s = [db executeQuery:@"SELECT COUNT(*) FROM cash where key=? and Prefix=?" ,ItemID,Prefix];
        if ([s next]) {
            int totalCount = [s intForColumnIndex:0];
            if (totalCount > 0)
            {
                isExist = YES;
            }
        }
        [s close];
        
        if ( isExist == NO) {
            NSString *sql = @"insert into cash (key,Prefix,data) values (?,?,?)" ;
            
            BOOL success = [db executeUpdate:sql, ItemID, Prefix, jsonString];
            if (!success) {
                int errorcode = [db lastErrorCode];
                [self checkError:errorcode];
                
                NSLog(@"error = %@", [db lastErrorMessage]);
            }
        }
        else
        {
            
            NSString *sql = @"update cash set  data = ? , updated_at = current_timestamp where key=? and Prefix=?  " ;
            
            BOOL success = [db executeUpdate:sql, jsonString,ItemID, Prefix ];
            if (!success) {
                int errorcode = [db lastErrorCode];
        [self checkError:errorcode];
                NSLog(@"error = %@", [db lastErrorMessage]);
            }
            
        }
        
    }];
    
    
    
    
}

+(void) checkError:(int ) errorcode
{
    if (errorcode == 1)
    {
//        removeDataBase_data(database: "log")
       

        [self deleteDatabase];
        
    }
 
}




+(id) getitem:(NSString *)ItemID   Prefix:(NSString*) Prefix
{
//    FMDatabase *database = [self cash_db];

    __block id object= nil;
    
 
         

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    
  [[self databaseQueue] inDatabase:^(FMDatabase *db) {
        
    FMResultSet *s = [db executeQuery:@"SELECT * FROM cash where key=? and Prefix=?" , ItemID,Prefix];
    if ([s next]) {
        
        NSString *stringJson = [s stringForColumn:@"data"];
        NSData *data = [stringJson dataUsingEncoding:NSUTF8StringEncoding];
        id value =  [NSJSONSerialization JSONObjectWithData:data   options:0  error:nil];
         if (value == nil)
         {
             object = stringJson;
         }
        else
        {
              object =  value;
        }
    }
      [s close];
      
 dispatch_semaphore_signal(semaphore);

    }];
    
 
    
    
     dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    
    return  object;
}


+(void) getitem:(NSString *)ItemID   Prefix:(NSString*) Prefix completionAction:(resultCompletionBlock) completionBlock
{
//    FMDatabase *database = [self cash_db];

    __block id object= nil;
    
  [[self databaseQueue] inDatabase:^(FMDatabase *db) {
        
    FMResultSet *s = [db executeQuery:@"SELECT * FROM cash where key=? and Prefix=?" , ItemID,Prefix];
    if ([s next]) {
        
        NSString *stringJson = [s stringForColumn:@"data"];
        NSData *data = [stringJson dataUsingEncoding:NSUTF8StringEncoding];

        id value =  [NSJSONSerialization JSONObjectWithData:data   options:0  error:nil];
         if (value == nil)
         {
             object = stringJson;
         }
        else
        {
              object =  value;
        }
    }
      [s close];
      
      completionBlock(object);
            
    }];
    
 
}

+(void) deleteAll:(NSArray *) ignoreFiles {
    
  [[self databaseQueue] inDatabase:^(FMDatabase *db) {

    
    NSString *where = @"" ;
    
    for (int i= 0; i < ignoreFiles.count ; i++) {
        if (i == 0)
        {
            where = [NSString stringWithFormat:@" Prefix not like '%@%@' "  , [ignoreFiles objectAtIndex:i],@"%"];

        }
        else
        {
            where = [NSString stringWithFormat:@"%@ and Prefix not like '%@%@'" , where , [ignoreFiles objectAtIndex:i],@"%"];

        }
    }
    
    if (![where isEqualToString:@""])
    {
       where = [NSString stringWithFormat:@"where %@" , where  ];

    }
    
    NSString *sql = [NSString stringWithFormat:@"%@ %@" , @"delete from cash  " , where] ;
              
              BOOL success = [db executeUpdate:sql ];
              if (!success) {
                  NSLog(@"error = %@", [db lastErrorMessage]);
              }
      
  }];
}

+(void) Deletelstitems:(NSString*) Prefix {
      [[self databaseQueue] inDatabase:^(FMDatabase *db) {
          
  
    
    NSString *sql = [NSString stringWithFormat:@"delete from cash where  Prefix like '%@%@' " , Prefix , @"%"] ;
           
           BOOL success = [db executeUpdate:sql ];
           if (!success) {
               NSLog(@"error = %@", [db lastErrorMessage]);
           }
   }];
}

+(void) deleteitems:(NSString *)ItemID   Prefix:(NSString*) Prefix
{
 [[self databaseQueue] inDatabase:^(FMDatabase *db) {
    
    NSString *sql = [NSString stringWithFormat:@"delete from cash where key='%@' and Prefix like '%@%@' " , ItemID ,Prefix,@"%"] ;
           
           BOOL success = [db executeUpdate:sql  ];
           if (!success) {
               NSLog(@"error = %@", [db lastErrorMessage]);
           }
           }];
}

+ (NSString*)JSONString:(id)dictionary prettyPrinted:(BOOL)prettyPrinted
{
    if ([dictionary isKindOfClass:[NSString class]])
    {
        return dictionary ;
    }
    
    
    NSJSONWritingOptions options = (prettyPrinted) ? NSJSONWritingPrettyPrinted : 0;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:options error:nil];
    return  [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
}
 
+(void) vacuum_database
{
      [[self databaseQueue] inDatabase:^(FMDatabase *db) {
            
     
      NSString *sql = @"vacuum" ;
             
             BOOL success = [db executeUpdate:sql ];
             if (!success) {
                 NSLog(@"error = %@", [db lastErrorMessage]);
             }
     }];
}
 
@end
