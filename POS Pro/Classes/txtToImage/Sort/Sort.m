//
//  Sort.m
//  aqa
//
//  Created by khaled on 11/14/13.
//  Copyright (c) 2013 abda3. All rights reserved.
//

#import "Sort.h"
 
#import "NSMutableDictionary+Mydic.h"

@implementation Sort

+(NSArray *)  Random_Array :(NSArray *)arr
{
    NSMutableArray *normal = [[NSMutableArray alloc] initWithArray:arr];
    
    NSUInteger count = [normal count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        int nElements = count - i;
        int n = (arc4random() % nElements) + i;
        [normal exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    return  normal;
}

+(NSArray *) ReversedArray :(NSArray *)arr
{
   return   [[arr reverseObjectEnumerator] allObjects];
}


+(NSDictionary *) sortdicBykeyAlphabetically:(NSDictionary *) dic
{
    NSArray *sortedValues = [[dic allValues] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSMutableDictionary *orderedDictionary=[[NSMutableDictionary alloc]init];
    for(NSString *valor in sortedValues){
        for(NSString *clave in [dic allKeys]){
            if ([valor isEqualToString:[dic valueForKey:clave]]) {
                [orderedDictionary setValue:valor forKey:clave];
            }
        }
    }
    return orderedDictionary;
}
+(NSArray *) sortArrNumber:(NSArray *)arr
{

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self > 0"];
    NSMutableArray *filteredArray = [[arr filteredArrayUsingPredicate:predicate] mutableCopy];
    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [filteredArray sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];

    return filteredArray;
}


+(NSArray *) sort_array_of_dic_bykey:(NSArray *) array key:(NSString *) key  ascending:(BOOL)ascending
{
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:key  ascending:ascending];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    NSArray *sortedArray = [array sortedArrayUsingDescriptors:sortDescriptors];
    
    return  sortedArray;
    
}

+(NSArray *) sortArrAlphabetically:(NSArray *) arr
{
   return  [arr sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

}
+(NSArray *) sortArrAlphabetically_Desc:(NSArray *) arr
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(localizedCompare:)];
   arr = [arr sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
     
    return arr;
    
}

+(NSArray *) GetDistinctValues_from_Dictionary:(NSArray *) arr keyindic:(NSString *)keyindic
{
//    NSArray *uniqueStates;
//    uniqueStates = [arr valueForKeyPath:[NSString stringWithFormat:@"@distinctUnionOfObjects.%@" , keyindic]];
    
    NSMutableArray *uniqueStates = [[NSMutableArray alloc] init];
    for (int i =0 ; i < [arr count]; i++) {
        NSDictionary *dic = [arr objectAtIndex:i];
        NSString *value = [dic objectForKey:keyindic];
        if (value != nil) {
            if ([uniqueStates indexOfObject:value] == NSNotFound  ) {
                [uniqueStates addObject:value];
            }
        }
     
    }
    
    return uniqueStates;
}


+(NSDictionary *) array_from_Dictionary_Bykey:(NSArray *) arr keyindic:(NSString *)keyindic
{
    
    NSArray * response = [Sort GetDistinctValues_from_Dictionary:arr keyindic:keyindic];
    
    
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    for (NSString *key in response)
    {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        for (NSDictionary *tempdic in arr) {
            NSString *keydic = [clsfunction readvalue: [tempdic objectForKey:keyindic]];
   
            if ([ keydic isEqualToString:[clsfunction readvalue: key]]) {
                [list addObject:tempdic];
            }
            [dic setObjectMe:list forKey:key];
        
        }
        
        
    }
    
    
    return dic;
}



+(NSArray *) array_To_arrayOFarray :(NSArray *) json count:(int)count
{
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


@end
