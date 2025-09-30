//
//  pos_base_class.swift
//  pos
//
//  Created by khaled on 14/10/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

class pos_base_class: NSObject {
    
    static func create_temp(_ dbClass:database_class)  {
 
        _ =    dbClass.runSqlStatament(sql: "DROP TABLE IF EXISTS temp_\( dbClass.table_name)")

         let sql = " CREATE   TABLE temp_\( dbClass.table_name) AS select * from \( dbClass.table_name)"
        _ =   dbClass.runSqlStatament(sql: sql)
    }
    
    static func copy_temp(_ dbClass:database_class)  {
        
 
        let table =  dbClass.table_name
        
        let sql = """
            PRAGMA foreign_keys=off;

            BEGIN TRANSACTION;
            
            Delete From \(table);

            INSERT  into \(table)  SELECT * FROM temp_\(table);

            DROP TABLE IF EXISTS temp_\(table);

            COMMIT;

            PRAGMA foreign_keys=on;

            """

//        let sql = """
//            PRAGMA foreign_keys=off;
//
//            BEGIN TRANSACTION;
//
//            ALTER TABLE \(table) RENAME TO old_\(table);
//
//            ALTER TABLE temp_\(table) RENAME TO \(table);
//
//            DROP TABLE IF EXISTS old_\(table);
//
//            COMMIT;
//
//            PRAGMA foreign_keys=on;
//
//            """
        
       _ =   dbClass.runSqlStatament(sql: sql)
         
    }
    static func rest_temp(_ dbClass:database_class)  {
 
        //_ =    dbClass.runSqlStatament(sql: "Delete From temp_\( dbClass.table_name)")

    }
     
}
