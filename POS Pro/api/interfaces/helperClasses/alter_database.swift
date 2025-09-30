//
//  alter_database.swift
//  pos
//
//  Created by Khaled on 8/19/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation


class alter_database: NSObject {

    static func check(_ alterType:alter_database_enum)
    {
        if alterType.getIsDoneBefore(){
          //  return
        }
        create_table_delivery_type_category()
        create_table_pos_return_reason()
        create_table_ir_translation()
        create_ios_rule()
        create_ios_group()
        create_ios_setting()
        create_printer_error()
        
        create_log()
        create_queue_log()
        create_table_printer_log()
        create_table_multipeer_log()
        
        create_ingenico_order_class()
        create_ingenico_log()
 
        create_load_loyalty_config_settings()
 
        create_pos_driver()
       
//        create_promotions_products_class()
        create_res_brand()
        
        create_socket_device()
        create_pos_order_integration()
        create_pos_insurance_order()
        create_messages_ip_queue()
        create_product_combo_price_line()
        create_pos_line_add_on_price_list()
        create_pos_delivery_area()
        create_device_ip_info()

        create_log_ip_queue()
        create_product_avaliable()
        create_pos_order_qr_code()
        create_pos_e_invoice()
        create_promo_bonat()
        create_promo_coupon()
        add_column(table: "pos_e_invoice", column: "sgin_xml_hash", type: "VARCHAR")
        add_column(table: "pos_e_invoice", column: "base64_content_unsgin", type: "VARCHAR")
        add_column(table: "pos_e_invoice", column: "signedPropertiesHash", type: "VARCHAR")
        add_column(table: "pos_e_invoice", column: "signing_time", type: "VARCHAR")

        add_column(table: "socket_device", column: "device_mac", type: "VARCHAR")

        add_column(table: "pos_order", column: "write_pos_code", type: "VARCHAR")
        add_column(table: "pos_order", column: "create_pos_code", type: "VARCHAR")
        add_column(table: "pos_order", column: "platform_name", type: "VARCHAR")
        
        add_column(table: "pos_order_line", column: "write_pos_code", type: "VARCHAR")
        add_column(table: "pos_order_line", column: "create_pos_code", type: "VARCHAR")
        add_column(table: "pos_order_line", column: "note_kds", type: "VARCHAR")
        add_column(table: "pos_order_line", column: "line_repeat", type: "INTEGER")
        add_column(table: "pos_order_line", column: "return_reason", type: "VARCHAR")

        add_column(table: "pos_session", column: "server_session_name", type: "VARCHAR")
        add_column(table: "pos_order", column: "delivery_type_reference", type: "VARCHAR")
        add_column(table: "pos_order", column: "return_reason_id", type: "INTEGER")
        add_column(table: "pos_order", column: "pos_multi_session_write_date", type: "VARCHAR")
         add_column(table: "pos_order", column: "order_menu_status", type: "INTEGER")

        add_column(table: "pos_order", column: "loyalty_earned_point", type: "INTEGER")
        add_column(table: "pos_order", column: "loyalty_earned_amount", type: "INTEGER")
        add_column(table: "pos_order", column: "loyalty_redeemed_point", type: "INTEGER")
        add_column(table: "pos_order", column: "loyalty_redeemed_amount", type: "INTEGER")
        add_column(table: "pos_order", column: "loyalty_points_remaining_partner", type: "INTEGER"  )
        add_column(table: "pos_order", column: "loyalty_amount_remaining_partner", type: "INTEGER"  )
        add_column(table: "pos_order", column: "void_status", type: "INTEGER"  )
        add_column(table: "pos_order", column: "promotion_code", type: "VARCHAR"  )
        add_column(table: "pos_order", column: "coupon_id", type: "INTEGER"  )
        add_column(table: "pos_order", column: "coupon_code", type: "VARCHAR"  )
        add_column(table: "pos_order", column: "kds_preparation_total_time", type: "INTEGER"  , DEFAULT: "0" )

        add_column(table: "res_company", column: "company_registry", type: "VARCHAR")
        add_column(table: "res_company", column: "account_sale_tax_id", type: "INTEGER")
        add_column(table: "res_company", column: "account_sale_tax_name", type: "VARCHAR")
        add_column(table: "res_company", column: "l10n_sa_edi_building_number", type: "VARCHAR")
        add_column(table: "res_company", column: "l10n_sa_edi_plot_identification", type: "VARCHAR")
        add_column(table: "res_company", column: "street", type: "VARCHAR")
        add_column(table: "res_company", column: "state_id_name", type: "VARCHAR")
        add_column(table: "res_company", column: "city", type: "VARCHAR")
        add_column(table: "res_company", column: "zip", type: "VARCHAR")
        add_column(table: "res_company", column: "country_name", type: "VARCHAR")
        add_column(table: "res_company", column: "country_code", type: "VARCHAR")
        add_column(table: "res_company", column: "country_code", type: "VARCHAR")
        add_column(table: "res_company", column: "l10n_sa_private_key", type: "VARCHAR")

        add_column(table: "res_partner", column: "l10n_sa_edi_building_number", type: "VARCHAR")
        add_column(table: "res_partner", column: "l10n_sa_edi_plot_identification", type: "VARCHAR")
        add_column(table: "res_partner", column: "state_id_name", type: "VARCHAR")

        add_column(table: "pos_config", column: "requestID", type: "INTEGER")
        add_column(table: "pos_config", column: "tokenType", type: "VARCHAR")
        add_column(table: "pos_config", column: "dispositionMessage", type: "VARCHAR")
        add_column(table: "pos_config", column: "binarySecurityToken", type: "VARCHAR")
        add_column(table: "pos_config", column: "secret", type: "VARCHAR")
//        add_column(table: "pos_config", column: "last_chain_index", type: "INTEGER")

        add_column(table: "pos_order", column: "l10n_sa_uuid", type: "VARCHAR")
        add_column(table: "pos_order", column: "l10n_sa_chain_index", type: "VARCHAR")
        add_column(table: "pos_order_account_journal", column: "mean_code", type: "INTEGER")


        add_column(table: "pos_order_line", column: "uid", type: "VARCHAR")
        add_column(table: "pos_order_line", column: "printed", type: "INTEGER")
        add_column(table: "pos_order_line", column: "last_qty", type: "INTEGER")
        add_column(table: "pos_order_line", column: "product_tmpl_id", type: "INTEGER")
        add_column(table: "pos_order_line", column: "discount_program_id", type: "INTEGER" , DEFAULT: "0" )
        add_column(table: "pos_order_line", column: "pos_multi_session_write_date", type: "VARCHAR")
        add_column(table: "pos_order_line", column: "promotion_row_parent", type: "INTEGER")
        add_column(table: "pos_order_line", column: "pos_promotion_id", type: "INTEGER")
        add_column(table: "pos_order_line", column: "pos_conditions_id", type: "INTEGER")
        add_column(table: "pos_order_line", column: "custom_price", type: "INTEGER")
        add_column(table: "pos_order_line", column: "void_status", type: "INTEGER"  )
        add_column(table: "pos_order_line", column: "is_promotion", type: "INTEGER" , DEFAULT: "0" )
        add_column(table: "pos_order_line", column: "sync_void", type: "INTEGER" , DEFAULT: "0" )
        add_column(table: "pos_order_line", column: "kds_preparation_item_time", type: "INTEGER"  , DEFAULT: "0" )
        add_column(table: "pos_order_line", column: "discount_extra_fees", type: "INTEGER" )
        add_column(table: "pos_order_line", column: "product_combo_id", type: "INTEGER" )
        

        add_column(table: "pos_config", column: "code", type: "VARCHAR")
        add_column(table: "pos_config", column: "pin_code", type: "VARCHAR")
        add_column(table: "pos_config", column: "allow_pin_code", type: "INTEGER")
        add_column(table: "pos_config", column: "multi_session_accept_incoming_orders", type: "INTEGER")
 
        add_column(table: "pos_config", column: "enable_pos_loyalty", type: "INTEGER")
        add_column(table: "pos_config", column: "loyalty_journal_id", type: "INTEGER")
        add_column(table: "pos_config", column: "loyalty_journal_id_name", type: "VARCHAR")
        add_column(table: "pos_config", column: "minimum_fees", type: "INTEGER")
        add_column(table: "pos_config", column: "minimum_item_price", type: "INTEGER")

        add_column(table: "pos_config", column: "extra_fees", type: "INTEGER")
        add_column(table: "pos_config", column: "extra_product_id", type: "INTEGER")
        add_column(table: "pos_config", column: "extra_product_id_name", type: "VARCHAR")
        add_column(table: "pos_config", column: "extra_percentage", type: "INTEGER")
        add_column(table: "pos_config", column: "pos_type", type: "VARCHAR")
        add_column(table: "pos_config", column: "fb_token", type: "VARCHAR")
        add_column(table: "pos_config", column: "logo", type: "VARCHAR")
        add_column(table: "pos_config", column: "brand_id", type: "INTEGER")
        add_column(table: "pos_config", column: "brand_name", type: "VARCHAR")

        add_column(table: "pos_config", column: "insurance_product_delivery_note", type: "VARCHAR")
        add_column(table: "pos_config", column: "loyalty_type", type: "VARCHAR")
        add_column(table: "pos_config", column: "bonat_api_key", type: "VARCHAR")
        add_column(table: "pos_config", column: "bonat_api_url", type: "VARCHAR")
        add_column(table: "pos_config", column: "api_url_type", type: "VARCHAR")
        add_column(table: "pos_config", column: "force_update_journal_id", type: "INTEGER")
        add_column(table: "pos_config", column: "force_update_journal_name", type: "VARCHAR")

        add_column(table: "product_combo_price", column: "attribute_value_id", type: "INTEGER")
        
        add_column(table: "product_combo", column: "sequence", type: "INTEGER")
        add_column(table: "product_combo", column: "min_no_of_items", type: "INTEGER")
        add_column(table: "product_combo", column: "deleted", type: "INTEGER" , DEFAULT: "0")
        
        add_column(table: "product_template_attribute_value", column: "own_sequence", type: "INTEGER")

        add_column(table: "delivery_type", column: "sequence", type: "INTEGER")
        add_column(table: "delivery_type", column: "require_info", type: "BOOLEAN")
        add_column(table: "delivery_type", column: "category_id", type: "INTEGER")
        add_column(table: "delivery_type", column: "extra_product_id", type: "INTEGER")
        add_column(table: "delivery_type", column: "default_customer_id", type: "INTEGER")
        add_column(table: "delivery_type", column: "tip_product_id", type: "INTEGER")
        add_column(table: "delivery_type", column: "service_product_id", type: "INTEGER")
        add_column(table: "delivery_type", column: "service_charge", type: "INTEGER")
        add_column(table: "delivery_type", column: "required_guest_number", type: "BOOLEAN")
        
        add_column(table: "product_product", column: "deleted", type: "INTEGER" , DEFAULT: "0")
        add_column(table: "product_product", column: "type", type: "VARCHAR" )
        add_column(table: "product_product", column: "company_id", type: "INTEGER"  )
        add_column(table: "product_product", column: "list_price", type: "INTEGER"  )
        add_column(table: "product_product", column: "insurance_product", type: "BOOLEAN" , DEFAULT: "0")
        add_column(table: "product_product", column: "allow_extra_fees", type: "BOOLEAN" , DEFAULT: "0")
        add_column(table: "product_product", column: "select_weight", type: "BOOLEAN" , DEFAULT: "0")

        add_column(table: "product_template", column: "open_price", type: "INTEGER"  )

        
        
        add_column(table: "account_journal", column: "image_small", type: "VARCHAR"  )
        add_column(table: "account_journal", column: "stc_test_account_code", type: "VARCHAR"  )
        add_column(table: "account_journal", column: "stc_test_username", type: "VARCHAR"  )
        add_column(table: "account_journal", column: "stc_test_password", type: "VARCHAR"  )
        add_column(table: "account_journal", column: "is_support_geidea", type: "BOOLEAN"  )

        add_column(table: "pos_promotion", column: "product_id_amt", type: "INTEGER")
        add_column(table: "pos_promotion", column: "product_id_qty", type: "INTEGER")
        add_column(table: "pos_promotion", column: "no_of_applied_times", type: "INTEGER")
        add_column(table: "pos_promotion", column: "required_code", type: "INTEGER")
        add_column(table: "pos_promotion", column: "filter_code", type: "VARCHAR")
        add_column(table: "pos_promotion", column: "max_discount", type: "INTEGER")

        add_column(table: "pos_conditions", column: "no_of_applied_times", type: "INTEGER")
        add_column(table: "get_discount", column: "no_of_applied_times", type: "INTEGER")
        add_column(table: "get_discount", column: "discount_fixed_x", type: "INTEGER")

        add_column(table: "quantity_discount", column: "no_of_applied_times", type: "INTEGER")
        add_column(table: "quantity_discount_amt", column: "no_of_applied_times", type: "INTEGER")
//branch_id
        
        
        add_column(table: "pos_discount_program", column: "customer_restricted", type: "INTEGER" , DEFAULT: "0")

        add_column(table: "res_partner", column: "discount_program_id", type: "INTEGER"  )
        add_column(table: "res_partner", column: "loyalty_points_remaining", type: "INTEGER"  )
        add_column(table: "res_partner", column: "loyalty_amount_remaining", type: "INTEGER"  )
        add_column(table: "res_partner", column: "blacklist", type: "INTEGER"  )
        add_column(table: "res_partner", column: "website", type: "VARCHAR"  )
        add_column(table: "res_partner", column: "function", type: "VARCHAR"  )
        add_column(table: "res_partner", column: "street2", type: "VARCHAR"  )
        add_column(table: "res_partner", column: "building_no", type: "VARCHAR"  )
        add_column(table: "res_partner", column: "district", type: "VARCHAR"  )
        add_column(table: "res_partner", column: "additional_no", type: "VARCHAR"  )
        add_column(table: "res_partner", column: "other_id", type: "VARCHAR"  )

        
        
        add_column(table: "res_users", column: "company_id", type: "INTEGER"  )
        add_column(table: "restaurant_printer", column: "epson_printer_ip", type: "VARCHAR"  )
        add_column(table: "restaurant_printer", column: "connectionType", type: "VARCHAR"  )
        
        add_column(table: "delivery_type", column: "required_driver", type: "BOOLEAN")
        add_column(table: "delivery_type", column: "required_table", type: "BOOLEAN")
        add_column(table: "delivery_type", column: "show_customer_info", type: "BOOLEAN")

        add_column(table: "pos_order", column: "driver_id", type: "INTEGER")
        add_column(table: "pos_order", column: "driver_row_id", type: "INTEGER")
        add_column(table: "pos_order", column: "membership_sale_order_id", type: "INTEGER")
        add_column(table: "pos_order", column: "reward_bonat_code", type: "VARCHAR")
        add_column(table: "pos_order", column: "previous_table_id", type: "INTEGER")
        add_column(table: "pos_order", column: "table_control_by_user_id", type: "INTEGER")
        add_column(table: "pos_order", column: "table_control_by_user_name", type: "VARCHAR")
//force_update_order_owner
        add_column(table: "pos_order", column: "force_update_order_owner", type: "INTEGER")
        add_column(table: "pos_order", column: "need_print_bill", type: "INTEGER")

        
        add_column(table: "restaurant_printer", column: "test_printer_status", type: "INTEGER")
        add_column(table: "restaurant_printer", column: "printer_type", type: "VARCHAR")
        add_column(table: "restaurant_printer", column: "printer_ip", type: "VARCHAR")
        add_column(table: "restaurant_printer", column: "company_id", type: "INTEGER")
        
        add_column(table: "restaurant_printer", column: "brand", type: "VARCHAR")
        add_column(table: "restaurant_printer", column: "model", type: "VARCHAR")
        add_column(table: "restaurant_printer", column: "type", type: "VARCHAR")
        add_column(table: "restaurant_printer", column: "is_active", type: "INTEGER", DEFAULT: "1")
        add_column(table: "restaurant_printer", column: "server_id", type: "INTEGER", DEFAULT: "0")
        add_column(table: "restaurant_printer", column: "available_in_pos", type: "INTEGER")
        add_column(table: "restaurant_printer", column: "mac_address", type: "VARCHAR",DEFAULT: "''")



        add_column(table: "pos_driver", column: "driver_cost", type: "INTEGER")
        add_column(table: "pos_driver", column: "deleted", type: "INTEGER" , DEFAULT: "0")

        alter_res_users_remove_UNIQUE()
        add_column(table: "ios_rule", column: "other_lang_name", type: "VARCHAR")
        add_column_log(table: "log", column: "req_count", type: "INTEGER"  )
        
        add_column_printer_log(table: "log", column: "print_sequence", type: "INTEGER"  )
        add_column_printer_log(table: "log", column: "order_id", type: "INTEGER"  )
        add_column_printer_log(table: "log", column: "printed", type: "INTEGER"  )
        add_column_printer_log(table: "log", column: "sequence", type: "INTEGER"  )
        add_column_printer_log(table: "log", column: "printer_name", type: "VARCHAR"  )
        add_column_printer_log(table: "log", column: "row_type", type: "VARCHAR"  )
        add_column_printer_log(table: "log", column: "html", type: "VARCHAR"  )
        add_column_printer_log(table: "log", column: "updated_at", type: " DATETIME DEFAULT (CURRENT_TIMESTAMP) NOT NULL"  )
        add_column_printer_log(table: "log", column: "wifi_ssid", type: "VARCHAR"  )
        add_column_printer_log(table: "log", column: "is_from_ip", type: "INTEGER")

        add_column_printer_log(table: "queue_log", column: "init_qty", type: "INTEGER")
        add_column_printer_log(table: "queue_log", column: "last_qty", type: "INTEGER")
        
        add_column(table: "relations", column: "deleted", type: "INTEGER" , DEFAULT: "0")
        add_column(table: "res_users", column: "deleted", type: "INTEGER" , DEFAULT: "0")
        add_column(table: "pos_discount_program", column: "deleted", type: "INTEGER" , DEFAULT: "0")
        add_column(table: "product_template", column: "deleted", type: "INTEGER" , DEFAULT: "0")
        add_column(table: "res_company", column: "deleted", type: "INTEGER" , DEFAULT: "0")
        //l10n_sa_additional_identification_number
        add_column(table: "res_company", column: "l10n_sa_additional_identification_number", type: "VARCHAR" )
        add_column(table: "res_company", column: "l10n_sa_additional_identification_scheme", type: "VARCHAR" )

        add_column(table: "product_combo_price", column: "deleted", type: "INTEGER" , DEFAULT: "0")
        add_column(table: "delivery_type_category", column: "deleted", type: "INTEGER" , DEFAULT: "0")
        add_column(table: "delivery_type", column: "deleted", type: "INTEGER" , DEFAULT: "0")
        add_column(table: "product_pricelist", column: "deleted", type: "INTEGER" , DEFAULT: "0")
        add_column(table: "product_pricelist_item", column: "deleted", type: "INTEGER" , DEFAULT: "0")
        add_column(table: "account_tax", column: "deleted", type: "INTEGER" , DEFAULT: "0")
        add_column(table: "account_journal", column: "deleted", type: "INTEGER" , DEFAULT: "0")
        add_column(table: "get_discount", column: "deleted", type: "INTEGER" , DEFAULT: "0")
        add_column(table: "pos_product_notes", column: "deleted", type: "INTEGER" , DEFAULT: "0")
        add_column(table: "ingenico_order_class", column: "account_journal_id", type: "INTEGER")
        add_column(table: "product_product", column: "calculated_quantity", type: "INTEGER" , DEFAULT: "1")

        
 
        add_column(table: "restaurant_table", column: "update_postion", type: "INTEGER" , DEFAULT: "0")
//min_no_of_items
        
        add_column(table: "pos_config", column: "vat", type: "VARCHAR"  )
        add_column(table: "res_brand", column: "is_select", type: "INTEGER" , DEFAULT: "0")
        add_column(table: "pos_order", column: "brand_id", type: "INTEGER")
        add_column(table: "product_product", column: "brand_id", type: "INTEGER")
        add_column(table: "product_product", column: "brand_name", type: "VARCHAR")
        add_column(table: "pos_category", column: "brand_id", type: "INTEGER")
        add_column(table: "pos_category", column: "brand_name", type: "VARCHAR")
        add_column(table: "pos_order", column: "order_integration", type: "INTEGER")
        add_column(table: "pos_order", column: "time_out_duration", type: "INTEGER")
        add_column(table: "delivery_type", column: "require_customer", type: "INTEGER")
        //taxes_id_array_string
        add_column(table: "product_product", column: "taxes_id_array_string", type: "VARCHAR")
        add_column(table: "product_template", column: "storage_unit_qty_available", type: "INTEGER" , DEFAULT: "0")

        //guests_number
        add_column(table: "pos_order", column: "guests_number", type: "INTEGER")


        //pickup_user_id
        add_column(table: "pos_order", column: "pickup_user_id", type: "INTEGER",DEFAULT: "0")
        add_column(table: "pos_order", column: "pickup_write_date", type: "VARCHAR")
        add_column(table: "pos_order", column: "bill_uid", type: "VARCHAR")
        add_column(table: "pos_order", column: "pickup_write_user_id", type: "INTEGER")
        //active
        add_column(table: "res_partner", column: "active", type: "INTEGER")
        add_column(table: "res_partner", column: "row_parent_id", type: "INTEGER")
        add_column(table: "res_partner", column: "parent_id", type: "INTEGER")
        add_column(table: "res_partner", column: "parent_name", type: "VARCHAR")
        add_column(table: "res_partner", column: "pos_delivery_area_id", type: "INTEGER")
        add_column(table: "res_partner", column: "pos_delivery_area_name", type: "VARCHAR")
        add_column(table: "res_partner", column: "parent_partner_id", type: "INTEGER")
        add_column(table: "res_partner", column: "res_partner_id", type: "INTEGER")

        add_column_meesage_ip_log(table: "log", column: "messageIdentifier", type: "VARCHAR")
        
        add_column_printer_log(table: "printer_error", column: "no_tries", type: "INTEGER"  )
        add_column_printer_log(table: "printer_error", column: "rePrinting_status", type: "INTEGER"  )
        //count_stock_available
        add_column(table: "product_product", column: "count_stock_available", type: "INTEGER",DEFAULT: "0")

        add_column(table: "restaurant_printer", column: "is_ble_con_2", type: "INTEGER", DEFAULT: "0")

        add_column(table: "pos_order", column: "recieve_date", type: "VARCHAR")
        add_column(table: "pos_order", column: "sent_ip_date", type: "VARCHAR")
        add_column_meesage_ip_log(table: "device_ip_info", column: "pos_name", type: "VARCHAR")
        add_column_meesage_ip_log(table: "device_ip_info", column: "user_name", type: "VARCHAR")
        add_column(table: "restaurant_printer", column: "is_ble_con", type: "INTEGER", DEFAULT: "0")
        add_column(table: "pos_config", column: "branch_id", type: "INTEGER"  )

        add_column(table: "pos_order", column: "table_control_by_user_id", type: "VARCHAR")
        
        MaintenanceInteractor.shared.checkMaintance()
 
        SharedManager.shared.alterCashImagesDataBase()

        alterType.setIsDone(with: true)

     }
    static func create_messages_ip_queue()
     {
         let sql = "CREATE TABLE IF NOT EXISTS messages_ip_queue (id INTEGER PRIMARY KEY AUTOINCREMENT, queue_ip_type INTEGER, message BLOB, targetIp VARCHAR, messageIdentifier VARCHAR,messagesUIDS VARCHAR,ipMessageType INTEGER,target VARCHAR ,noTries INTEGER , updated_at DATETIME DEFAULT (CURRENT_TIMESTAMP) NOT NULL);"
         
        _ =  database_class(connect: .meesage_ip_log).runSqlStatament(sql: sql)
  
     }
    static func create_device_ip_info()
     {
         let sql = "CREATE TABLE IF NOT EXISTS device_ip_info (id INTEGER PRIMARY KEY AUTOINCREMENT, sockect_device_id INTEGER,  order_sequces INTEGER, is_open_session BOOLEAN,is_online BOOLEAN, updated_at DATETIME DEFAULT (CURRENT_TIMESTAMP) NOT NULL);"
   _ =  database_class(connect: .meesage_ip_log).runSqlStatament(sql: sql)
  
     }
    static func create_log_ip_queue()
     {
         let sql = "CREATE TABLE IF NOT EXISTS log ( id INTEGER PRIMARY KEY AUTOINCREMENT, from_ip VARCHAR, to_ip VARCHAR, status VARCHAR, wifi_ssid VARCHAR, body BLOB, response BLOB, isFaluire INTEGER, updated_at DATETIME DEFAULT (CURRENT_TIMESTAMP) NOT NULL, messageIdentifier VARCHAR);"
         
        _ =  database_class(connect: .meesage_ip_log).runSqlStatament(sql: sql)
  
     }
    static func create_pos_insurance_order()
     {
         let sql = "CREATE TABLE IF NOT EXISTS pos_insurance_order (id INTEGER PRIMARY KEY AUTOINCREMENT, insurance_id INTEGER, order_id INTEGER);"
         
        _ =  database_class(connect: .database).runSqlStatament(sql: sql)
  
     }
    static func create_pos_delivery_area()
     {
         let sql = "CREATE TABLE IF NOT EXISTS pos_delivery_area (id INTEGER PRIMARY KEY AUTOINCREMENT, delivery_product_id INTEGER, delivery_product_name VARCHAR,name VARCHAR,display_name VARCHAR,delivery_amount INTEGER,active INTEGER, deleted INTEGER, __last_update VARCHAR);"
         
        _ =  database_class(connect: .database).runSqlStatament(sql: sql)
  
     }
    static func create_product_avaliable()
     {
         let sql = "CREATE TABLE IF NOT EXISTS product_avaliable (id INTEGER PRIMARY KEY AUTOINCREMENT, product_product_id INTEGER,avaliable_status INTEGER,avaliable_qty INTEGER, updated_at DATETIME DEFAULT (CURRENT_TIMESTAMP) NOT NULL);"
           _ =  database_class(connect: .database).runSqlStatament(sql: sql)
  
     }
    //pos_order_qr_code_class
    static func create_pos_order_qr_code()
     {
         let sql = "CREATE TABLE IF NOT EXISTS pos_order_qr_code (id INTEGER PRIMARY KEY AUTOINCREMENT, order_id INTEGER, order_uid VARCHAR, status INTEGER, qrCodeValue BLOB, recieve_qr_date VARCHAR, fileType VARCHAR, openDrawer INTEGER , updated_at DATETIME DEFAULT (CURRENT_TIMESTAMP) NOT NULL);"
         
        _ =  database_class(connect: .database).runSqlStatament(sql: sql)
  
     }
    static func create_pos_e_invoice()
     {
         let sql = "CREATE TABLE IF NOT EXISTS pos_e_invoice (id INTEGER PRIMARY KEY AUTOINCREMENT, order_id INTEGER, order_uid VARCHAR, base64_content VARCHAR,un_sgin_xml_hash VARCHAR, pih VARCHAR, signature VARCHAR, x509_signature VARCHAR, x509_public_key VARCHAR,certificate_str VARCHAR, l10n_sa_uuid VARCHAR , l10n_sa_chain_index INTEGER,qr_code_value VARCHAR, is_sync BOOLEAN , updated_at DATETIME DEFAULT (CURRENT_TIMESTAMP) NOT NULL);"
         
        _ =  database_class(connect: .database).runSqlStatament(sql: sql)
  
     }
    //promo_bonat_class
    static func create_promo_bonat()
     {
         let sql = "CREATE TABLE IF NOT EXISTS promo_bonat (id INTEGER PRIMARY KEY AUTOINCREMENT, is_percentage INTEGER, order_uid VARCHAR, mobile_number VARCHAR,discount_amount INTEGER, max_discount_amount INTEGER, is_void INTEGER,is_redeem INTEGER,promo_code VARCHAR, updated_at DATETIME DEFAULT (CURRENT_TIMESTAMP) NOT NULL);"
        
        _ =  database_class(connect: .database).runSqlStatament(sql: sql)
  
     }
    //promo_coupon_class
    static func create_promo_coupon()
     {
         let sql = "CREATE TABLE IF NOT EXISTS promo_coupon (id INTEGER PRIMARY KEY, name VARCHAR, order_uid VARCHAR, code VARCHAR, active INTEGER, number_of_apply INTEGER, type VARCHAR, amount INTEGER, min_order_amount INTEGER, max_amount INTEGER, expiry_date VARCHAR, orders_count INTEGER, remaining_coupons_number INTEGER, coupon_category_id INTEGER, display_name VARCHAR, create_date VARCHAR, write_date VARCHAR);"
         
        _ =  database_class(connect: .database).runSqlStatament(sql: sql)
  
     }
    static func create_load_loyalty_config_settings()
     {
         let sql = "CREATE TABLE IF NOT EXISTS load_loyalty_config_settings (id INTEGER PRIMARY KEY AUTOINCREMENT, points INTEGER, points_based_on VARCHAR, minimum_purchase INTEGER, point_calculation INTEGER, to_amount INTEGER);"
         
        _ =  database_class(connect: .database).runSqlStatament(sql: sql)
  
     }
    
   
    static func create_log()
     {
         let sql = "CREATE TABLE IF NOT EXISTS log (id INTEGER PRIMARY KEY AUTOINCREMENT, row_id INTEGER, \"key\" VARCHAR, prefix VARCHAR, data BLOB, updated_at DATETIME DEFAULT (CURRENT_TIMESTAMP) NOT NULL);"
         
        _ =  database_class(connect: .log).runSqlStatament(sql: sql)
  
     }
    static func create_ingenico_log()
     {
         let sql = "CREATE TABLE IF NOT EXISTS log (id INTEGER PRIMARY KEY AUTOINCREMENT, ingenico_id INTEGER, \"key\" VARCHAR, prefix VARCHAR, data BLOB, updated_at DATETIME DEFAULT (CURRENT_TIMESTAMP) NOT NULL);"
         
        _ =  database_class(connect: .ingenico_log).runSqlStatament(sql: sql)
  
     }
    static func create_product_combo_price_line(){
        let sql = "CREATE TABLE IF NOT EXISTS product_combo_price_line (id INTEGER PRIMARY KEY AUTOINCREMENT, price INTEGER,  price_list_id INTEGER, \"price_list_name\" VARCHAR, combo_price_id INTEGER, \"combo_price_name\" VARCHAR, product_tmpl_id INTEGER, \"product_tmpl_id_name\" VARCHAR, product_id INTEGER, \"product_id_name\" VARCHAR, attribute_value_id INTEGER, \"attribute_value_id_name\" VARCHAR, \"display_name\" VARCHAR, \"__last_update\" VARCHAR ,deleted INTEGER);"
        
       _ =  database_class(connect: .database).runSqlStatament(sql: sql)
 
    }
    //pos_line_add_on_price_list_class
    static func create_pos_line_add_on_price_list(){
        let sql = "CREATE TABLE IF NOT EXISTS pos_line_add_on_price_list (id INTEGER PRIMARY KEY AUTOINCREMENT,    \"line_uid\" VARCHAR, \"product_combo_price_line_ids\" VARCHAR, extra_price INTEGER);"
        
       _ =  database_class(connect: .database).runSqlStatament(sql: sql)
 
    }
    static func create_pos_driver()
     {
         let sql = "CREATE TABLE IF NOT EXISTS pos_driver (id INTEGER PRIMARY KEY AUTOINCREMENT, row_id INTEGER, \"name\" VARCHAR, \"code\" VARCHAR );"
         
        _ =  database_class(connect: .database).runSqlStatament(sql: sql)
  
     }
    
    static func create_res_brand()
         {
             let sql = "CREATE TABLE IF NOT EXISTS res_brand (id INTEGER PRIMARY KEY AUTOINCREMENT, company_id INTEGER,\"logo\" VARCHAR, \"display_name\" VARCHAR, \"header\" VARCHAR, \"tax_id\" VARCHAR, \"telephone\" VARCHAR, \"name\" VARCHAR , \"footer\" VARCHAR, \"email\" VARCHAR, \"website\" VARCHAR, \"currency_name\" VARCHAR, \"currency_id\" INTEGER, \"write_date\" VARCHAR, \"register_name\" VARCHAR,\"__last_update\" VARCHAR, \"create_date\" VARCHAR, \"address\" VARCHAR, \"company_name\" VARCHAR );"
             
            _ =  database_class(connect: .database).runSqlStatament(sql: sql)
      
         }
    
    static func create_table_printer_log()
     {
         let sql = "CREATE TABLE IF NOT EXISTS log (id INTEGER PRIMARY KEY AUTOINCREMENT, ip VARCHAR, status VARCHAR, print_job_id VARCHAR, print_sequence VARCHAR, start_at VARCHAR, stop_at VARCHAR);"
         
        _ =  database_class(connect: .printer_log).runSqlStatament(sql: sql)
 
        
     }
    static func create_table_multipeer_log()
     {
         let sql = "CREATE TABLE IF NOT EXISTS multipeer_log (id INTEGER PRIMARY KEY AUTOINCREMENT, log VARCHAR, note VARCHAR, date VARCHAR);"
         
        _ =  database_class(connect: .multipeer_log).runSqlStatament(sql: sql)
 
        
     }
    static func add_column_printer_log(table:String,column:String,type:String)
     {
         let sql = "ALTER TABLE \(table) ADD COLUMN \(column) \(type)"
         
       let success =  database_class(connect: .printer_log).runSqlStatament(sql: sql)
       SharedManager.shared.printLog("add column \(column) : \(success)")
        if !success && column == "updated_at"{
            printer_log_class.deleteAll(prefix: nil)
            printer_log_class.vacuum_database()
            _ =  database_class(connect: .printer_log).runSqlStatament(sql: sql)

        }
     }
    static func add_column_meesage_ip_log(table:String,column:String,type:String)
     {
         let sql = "ALTER TABLE \(table) ADD COLUMN \(column) \(type)"
         
       let success =  database_class(connect: .meesage_ip_log).runSqlStatament(sql: sql)
       SharedManager.shared.printLog("add column \(column) : \(success)")
       
     }
 
    static func add_column_log(table:String,column:String,type:String)
     {
         let sql = "ALTER TABLE \(table) ADD COLUMN \(column) \(type)"
         
       let success =  database_class(connect: .log).runSqlStatament(sql: sql)
       SharedManager.shared.printLog("add column \(column) : \(success)")
       
     }
     
    
   static func add_column(table:String,column:String,type:String)
    {
        let sql = "ALTER TABLE \(table) ADD COLUMN \(column) \(type)"
        
      let success =  database_class(connect: .database).runSqlStatament(sql: sql)
      SharedManager.shared.printLog("add column \(column) : \(success)")
      
    }
    
    
    
    static func add_column(table:String,column:String,type:String,DEFAULT:String)
     {
         let sql = "ALTER TABLE \(table) ADD COLUMN \(column) \(type) DEFAULT \(DEFAULT)"
         
       let success =  database_class(connect: .database).runSqlStatament(sql: sql)
       SharedManager.shared.printLog("add column \(column) : \(success)")
       
     }
    
    static func create_table_delivery_type_category()
     {
         let sql = "CREATE TABLE IF NOT EXISTS delivery_type_category (id INTEGER PRIMARY KEY ,name VARCHAR,display_name VARCHAR,__last_update VARCHAR);"
         
        _ =  database_class(connect: .database).runSqlStatament(sql: sql)
 
        
     }
    
    static func create_table_ir_translation()
     {
         let sql = "CREATE TABLE IF NOT EXISTS ir_translation (id INTEGER PRIMARY KEY ,res_id INTEGER  ,name VARCHAR,lang VARCHAR,value VARCHAR,state VARCHAR,src VARCHAR,__last_update VARCHAR);"
         
        _ =  database_class(connect: .database).runSqlStatament(sql: sql)
 
        add_column(table: "ir_translation", column: "src", type: "VARCHAR"  )

     }
    
    static func create_table_pos_return_reason()
     {
         let sql = "CREATE TABLE IF NOT EXISTS pos_return_reason (id INTEGER PRIMARY KEY ,name VARCHAR,display_name VARCHAR,__last_update VARCHAR,company_id INTEGER,deleted INTEGER);"
         
        _ =  database_class(connect: .database).runSqlStatament(sql: sql)
 
        
     }
    static func create_ios_rule()
     {
         let sql = "CREATE TABLE IF NOT EXISTS ios_rule (id INTEGER PRIMARY KEY ,name VARCHAR,key VARCHAR,description VARCHAR);"
         
        _ =  database_class(connect: .database).runSqlStatament(sql: sql)
 
        
        add_column(table: "ios_rule", column: "default_value", type: "INTEGER"  )

        
     }
    
    static func create_socket_device()
     {
         let sql = "CREATE TABLE IF NOT EXISTS socket_device (id INTEGER PRIMARY KEY AUTOINCREMENT ,name VARCHAR ,device_ip VARCHAR,type VARCHAR,device_status INTEGER,updated_at DATETIME DEFAULT (CURRENT_TIMESTAMP) NOT NULL);"
         
        _ =  database_class(connect: .database).runSqlStatament(sql: sql)
        
     }
    static func create_ios_setting()
     {
         let sql = "CREATE TABLE IF NOT EXISTS ios_settings (id INTEGER PRIMARY KEY ,name VARCHAR,value VARCHAR,option VARCHAR,type VARCHAR,scope VARCHAR,version VARCHAR, pos_id INTEGER);"
         
        _ =  database_class(connect: .database).runSqlStatament(sql: sql)
 
        
        add_column(table: "ios_settings", column: "default_value", type: "VARCHAR"  )

        
     }
    static func create_printer_error()
     {
         let sql = "CREATE TABLE IF NOT EXISTS printer_error (id INTEGER PRIMARY KEY AUTOINCREMENT,log_id INTEGER, order_id INTEGER,time INTEGER, error VARCHAR,printer_id INTEGER, \"IP\" VARCHAR,type_printer_error VARCHAR, printer_name VARCHAR,openDeawer BOOLEAN,html VARCHAR, updated_at DATETIME DEFAULT (CURRENT_TIMESTAMP) NOT NULL);"
         
        _ =  database_class(connect: .printer_log).runSqlStatament(sql: sql)
        
     }
    
    static func create_queue_log()
     {
         let sql = "CREATE TABLE IF NOT EXISTS queue_log (id INTEGER PRIMARY KEY AUTOINCREMENT, order_id INTEGER, printer_name VARCHAR, \"ip\" VARCHAR,type_printer VARCHAR,state_printed INTEGER,numb_lines INTEGER, updated_at DATETIME DEFAULT (CURRENT_TIMESTAMP) NOT NULL);"
         
        _ =  database_class(connect: .printer_log).runSqlStatament(sql: sql)
        
     }
    static func create_pos_order_integration()
     {
        let sql = "CREATE TABLE IF NOT EXISTS pos_order_integration (id INTEGER PRIMARY KEY ,order_uid VARCHAR,time_out_duration INTEGER,receive_datetime VARCHAR,write_datetime VARCHAR,is_paid BOOLEAN, amount_total VARCHAR, online_order_source VARCHAR,force_payment_journal_id INTEGER,order_status INTEGER, updated_at DATETIME DEFAULT (CURRENT_TIMESTAMP) NOT NULL );"
        
        _ =  database_class(connect: .database).runSqlStatament(sql: sql)
 
        
     }
    
    static func create_ios_group()
     {
        let sql = "CREATE TABLE IF NOT EXISTS ios_group (id INTEGER PRIMARY KEY ,name VARCHAR,company_id INTEGER);"
        
        _ =  database_class(connect: .database).runSqlStatament(sql: sql)
 
        
     }
    
    
    static func alter_res_users_remove_UNIQUE()
    {
        let UNIQUE_exist = "select sql from sqlite_master where type='table' and name='res_users'"
        let result = database_class(connect: .database).get_row(sql: UNIQUE_exist) ?? [:]
        let sql_table = result["sql"] as? String ?? ""
        if sql_table != ""
        {
            if sql_table.uppercased().contains("UNIQUE")
            {
                let sql_remove_UNIQUE = """
                PRAGMA foreign_keys=off;

                BEGIN TRANSACTION;

                ALTER TABLE res_users RENAME TO _res_users_old;

                CREATE TABLE res_users (id INTEGER PRIMARY KEY, active BOOLEAN, login VARCHAR NOT NULL , password VARCHAR, pos_security_pin VARCHAR, name VARCHAR, image VARCHAR, function VARCHAR, pos_user_type VARCHAR, fristLogin VARCHAR, lastLogin VARCHAR, __last_update VARCHAR, is_login BOOLEAN,company_id INTEGER);

                INSERT INTO res_users SELECT * FROM _res_users_old;

                COMMIT;

                PRAGMA foreign_keys=on;
                """
                
                _ =  database_class(connect: .database).runSqlStatament(sql: sql_remove_UNIQUE)

            }
        }
    }
    static func create_ingenico_order_class()
     {
         let sql = "CREATE TABLE IF NOT EXISTS ingenico_order_class (id INTEGER PRIMARY KEY AUTOINCREMENT ,response_code VARCHAR,ecr_no VARCHAR,ecr_receipt VARCHAR,amount VARCHAR,card_no VARCHAR, card_expire VARCHAR,card_type VARCHAR,auth VARCHAR,txt_date VARCHAR,txt_time VARCHAR,rRN VARCHAR,tID VARCHAR,start_date_and_time VARCHAR,information VARCHAR,card_scheme VARCHAR, card_details_number_and_expiry VARCHAR,auth_code VARCHAR,txn_end_date_and_time VARCHAR,emv_data VARCHAR,order_uid VARCHAR,order_id INTEGER );"
         
        _ =  database_class(connect: .database).runSqlStatament(sql: sql)
 
        
        add_column(table: "ios_rule", column: "default_value", type: "INTEGER"  )

        
     }
    
    
  
    
//    static func create_promotions_products_class()
//     {
//         let sql = """
//            CREATE TABLE IF NOT EXISTS  promotions_products (
//            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
//            "product_x" INTEGER,
//            promotion_id INTEGER,operator_x INTEGER, quantity_x INTEGER, product_y INTEGER, operator_y TEXT, quantity_y INTEGER, discount INTEGER, total INTEGER, no_applied INTEGER);
//
//            """
//
//        _ =  database_class(connect: .database).runSqlStatament(sql: sql)
//
//
//     }
    
}
