//
//  enum_settings.swift
//  pos
//
//  Created by  Mahmoud Wageh on 4/19/21.
//  Copyright © 2021 khaled. All rights reserved.
// item.name == show_all_products_inHome

import Foundation
//MARK:- SETTING APP KEY
enum SETTING_KEY : String, CaseIterable {
    case prevent_new_order_if_empty = "prevent_new_order_if_empty",
         printer_mode = "printer_mode",
         force_connect_with_printer = "force_connect_with_printer" ,
         sales_report_filtter =  "sales_report_filtter",
         STC_force_done = "STC_force_done" ,
         copy_right = "copy_right" ,
         qr_enable = "qr_enable" ,
         receipt_copy_number = "receipt_copy_number" ,
         clear_log_everyDays = "clear_log_everyDays" ,
         qr_url = "qr_url" ,
         category_scroll_direction_vertical = "category_scroll_direction_vertical" ,
         receipt_custom_header = "receipt_custom_header" ,
         receipt_copy_number_journal_type_bank = "receipt_copy_number_journal_type_bank" ,
         open_drawer_only_with_cash_payment_method = "open_drawer_only_with_cash_payment_method" ,
         receipt_logo_width = "receipt_logo_width" ,
         enable_testMode = "enable_testMode" ,
         new_invocie_report = "new_invocie_report" ,
         show_log = "show_log" ,
         is_STC_productions = "is_STC_productions" ,
         auto_print_zreport = "auto_print_zreport" ,
         timePaymentSuccessfullMessage = "timePaymentSuccessfullMessage" ,
         cash_time = "cash_time" ,
         enable_autoPrint = "enable_autoPrint" ,
         clearPenddingOrders_everyDays = "clearPenddingOrders_everyDays" ,
         show_all_products_inHome = "show_all_products_inHome" ,
         enable_OrderType = "enable_OrderType" ,
         time_close_old_session_to_allow_create_new_orders = "time_close_old_session_to_allow_create_new_orders" ,
         close_old_session_to_allow_create_new_orders = "close_old_session_to_allow_create_new_orders" ,
         enable_payment = "enable_payment" ,
         clearOrders_everyDays = "clearOrders_everyDays",
         show_invocie_notes = "show_invocie_notes",
         default_printer_name = "default_printer_name",
         default_printer_ip = "default_printer_ip",
         link_setting_with_odoo_2 = "link_setting_with_odoo_2",
         
         enable_record_all_log_multisession = "enable_record_all_log_multisession",
         enable_record_all_log = "enable_record_all_log",
         tries_non_priinted_number = "tries_non_priinted_number_zero",
         ingenico_name = "ingenico_name",
         ingenico_ip = "ingenico_ip",
         enable_multi_cash = "enable_multi_cash",
         enable_draft_mode = "enable_draft_mode",
         enable_UOM_kg = "enable_UOM_kg",
         enable_customer_return_order = "enable_customer_return_order",
         enable_email_mandatory_add_customer = "enable_email_mandatory_add_customer",
         enable_phone_mandatory_add_customer = "enable_phone_mandatory_add_customer",
         mw_minuts_fail_report = "mw_minuts_fail_report",
         clear_error_log = "clear_error_log",
         
         show_loyalty_details_in_invoice = "show_loyalty_details_in_invoice",
         show_number_of_items_in_invoice = "show_number_of_items_in_invoice",
         close_session_with_closed_orders = "close_session_with_closed_orders",
         
         enable_auto_accept_order_menu = "enable_auto_accept_order_menu",
         enable_play_sound_while_auto_accept_order_menu = "enable_play_sound_while_auto_accept_order_menu",
         enable_play_sound_order_menu = "enable_play_sound_order_menu_nd",
         start_session_sequence_order = "start_session_sequence_order",
         end_sessiion_sequence_order = "end_sessiion_sequence_order",
         enable_enter_sessiion_sequence_order = "enable_enter_sessiion_sequence_order",
         enable_traing_mode = "enable_traing_mode",
         enable_qr_for_draft_bill = "enable_qr_for_draft_bill",
         font_size_for_kitchen_invoice = "font_size_for_kitchen_invoice_50",
         enable_sequence_orders_over_wifi = "enable_sequence_orders_over_wifi",
         enable_log_sync_success_orders = "enable_log_sync_success_orders",
         enable_simple_invoice_vat = "enable_simple_invoice_vat_new",
         enable_auto_sent_to_kitchen = "enable_auto_sent_to_kitchen",
         connection_printer_time_out = "connection_printer_time_out",
         enable_show_combo_details_invoice = "enable_show_combo_details_invoice",
         terminalID_geidea = "terminalID_geidea",
         port_geidea = "port_geidea",
         enable_quantity_factor_product_reports = "enable_quantity_factor_product_reports",
         enable_support_multi_printer_brands = "enable_support_multi_printer_brands",
         enable_add_kds_via_wifi = "enable_add_kds_via_wifi",
         enable_cloud_kitchen = "enable_cloud_kitchen",
         enable_force_longPolling_multisession = "enable_force_longPolling_multisession",
         enable_show_discount_name_invoice = "enable_show_discount_name_invoice",
         enable_show_new_render_invoice = "enable_show_new_render_invoice",
         port_connection_ip = "port_connection_ip",
         hide_sent_to_kitchen_btn = "hide_sent_to_kitchen_btn",
         enable_show_unite_price_invoice = "enable_show_unite_price_invoice",
         no_retry_sent_ip = "no_retry_sent_ip",
         enable_add_waiter_via_wifi = "enable_add_waiter_via_wifi",
         enable_sync_order_sequence_wifi = "enable_sync_order_sequence_wifi",
         make_all_orders_defalut = "make_all_orders_defalut",
         show_print_last_session_dashboard = "show_print_last_session_dashboard",
         enable_chosse_account_journal_for_return_order = "enable_chosse_account_journal_for_return_order",
         enable_give_reason_for_void_sent_line = "enable_give_reason_for_void_sent_line",
         enable_hide_void_before_line = "enable_hide_void_before_line",
         enable_initalize_adjustment_with_zero = "enable_initalize_adjustment_with_zero",
         enable_new_combo = "enable_new_combo",
         disable_idle_timer = "disable_idle_timer",
         enable_resent_failure_ip_kds_order_automatic = "enable_resent_failure_ip_kds_order_automatic",
         time_pass_to_go_lock_screen = "time_pass_to_go_lock_screen",
         enable_reconnect_with_printer_automatic = "enable_reconnect_with_printer_automatic",
         auto_arrange_table_default = "auto_arrange_table_default",
         enable_work_with_bill_uid_default = "enable_work_with_bill_uid_default",
         enable_invoice_width = "enable_invoice_width",
         width_invoice_to_set_new_dimensions = "width_invoice_to_set_new_dimensions",
    
    
         time_sleep_print_queue = "time_sleep_print_queue",
         enable_local_qty_avaliblity = "enable_local_qty_avaliblity",
         enable_enhance_printer_cyle = "enable_enhance_printer_cyle",
         options_for_require_customer = "options_for_require_customer",
         enable_cloud_qr_code = "enable_cloud_qr_code",
         margin_invoice_left_value = "margin_invoice_left_value",
         margin_invoice_right_value = "margin_invoice_right_value",
         enable_phase2_Invoice_Offline_default = "enable_phase2_Invoice_Offline_default",
         use_app_return = "use_app_return",
         enable_zebra_scanner_barcode = "enable_zebra_scanner_barcode",
         enable_enter_reason_void = "enable_enter_reason_void",
         enable_stop_paied_intergrate_order = "enable_stop_paied_intergrate_order",
         start_value_containous_sequence = "start_value_containous_sequence",
         enable_enter_containous_sequence = "enable_enter_containous_sequence",
         enable_show_price_without_tax = "enable_show_price_without_tax",
         enable_check_duplicate_lines = "enable_check_duplicate_lines",





    

         enable_recieve_update_order_online = "enable_recieve_update_order_online",

    
         enable_new_product_style = "enable_new_product_style",
    
         enable_sequence_at_master_only = "enable_sequence_at_master_only",
         enable_retry_long_poll = "enable_retry_long_poll",
         enable_make_user_resposiblity_for_order = "enable_make_user_resposiblity_for_order",
         enable_force_update_by_owner = "enable_force_update_by_owner",
         enable_move_pending_orders = "enable_move_pending_orders",
         enter_bar_code_length = "enter_bar_code_length",
         start_value_for_bar_code = "start_value_for_bar_code",
         postion_start_id_for_bar_code = "postion_start_id_for_bar_code",
         postion_end_id_for_bar_code = "postion_end_id_for_bar_code",
         postion_start_qty_for_bar_code = "postion_start_qty_for_bar_code",
         postion_end_qty_for_bar_code = "postion_end_qty_for_bar_code",
         enable_scoket_mobile_scanner_barcode = "enable_scoket_mobile_scanner_barcode",
    enable_reecod_all_ip_log = "enable_reecod_all_ip_log",
    enter_time_for_auto_send_fail_ip_message = "enter_time_for_auto_send_fail_ip_message",
         enter_count_page_fail_ip_message = "enter_count_page_fail_ip_message",
    enable_check_duplicate_message_ids = "enable_check_duplicate_message_ids"

        
    
    func stringKey()->String{
        return "\(self)"
    }
    func getID() -> Int{
        switch self {
        case .printer_mode : return 1;
        case .force_connect_with_printer :  return 2;
        case .sales_report_filtter :   return 3;
        case .STC_force_done :  return 4;
        case .copy_right :  return 5;
        case .qr_enable :  return 6;
        case .receipt_copy_number :  return 7;
        case .clear_log_everyDays :  return 8;
        case .qr_url :  return 9;
        case .category_scroll_direction_vertical :  return 10;
        case .receipt_custom_header :  return 11;
        case .receipt_copy_number_journal_type_bank :  return 12;
        case .open_drawer_only_with_cash_payment_method :  return 13;
        case .receipt_logo_width :  return 14;
        case .enable_testMode :  return 15;
        case .new_invocie_report :  return 16;
        case .show_log :  return 17;
        case .is_STC_productions :  return 18;
        case .auto_print_zreport :  return 19;
        case .timePaymentSuccessfullMessage :  return 20;
        case .cash_time :  return 21;
        case .enable_autoPrint :  return 22;
        case .clearPenddingOrders_everyDays :  return 23;
        case .show_all_products_inHome :  return 24;
        case .enable_OrderType :  return 25;
        case .        time_close_old_session_to_allow_create_new_orders :  return 26;
        case .        close_old_session_to_allow_create_new_orders :  return 27;
        case .enable_payment :  return 28;
        case .clearOrders_everyDays :  return 29
        case .show_invocie_notes: return 30
        case .default_printer_name: return 31
        case .default_printer_ip: return 32
        case .link_setting_with_odoo_2 : return 33
            
        case .enable_record_all_log_multisession : return 35
        case .enable_record_all_log : return 36
        case .tries_non_priinted_number: return 37
            
        case .ingenico_name:
            return 34
        case .ingenico_ip:
            return 35
            
        case .enable_multi_cash: return 38
        case .enable_draft_mode: return 39
            
        case .enable_UOM_kg:
            return 40
        case .enable_customer_return_order:
            return 41
        case .enable_email_mandatory_add_customer:
            return 42
        case .enable_phone_mandatory_add_customer:
            return 43
        case .mw_minuts_fail_report:
            return 44
        case .clear_error_log:
            return 45
            
            
        case .show_loyalty_details_in_invoice:
            return 46
            
        case .enable_auto_accept_order_menu:
            return 47
        case .start_session_sequence_order:
            return 48
        case .end_sessiion_sequence_order:
            return 49
        case .enable_enter_sessiion_sequence_order:
            return 50
        case .enable_play_sound_order_menu:
            return 51
        case .enable_traing_mode:
            return 52
        case .show_number_of_items_in_invoice:
            return 53
        case .close_session_with_closed_orders:
            return 54
        case .enable_qr_for_draft_bill:
            return 55
        case .font_size_for_kitchen_invoice:
            return 56
        case .enable_sequence_orders_over_wifi:
            return 57
        case .enable_log_sync_success_orders:
            return 58
        case .enable_simple_invoice_vat:
            return 59
        case .enable_auto_sent_to_kitchen:
            return 60
        case .connection_printer_time_out:
            return 61
        case .enable_show_combo_details_invoice:
            return 62
        case  .terminalID_geidea:
            return 63
            
        case .port_geidea:
            return 64
        case .enable_support_multi_printer_brands:
            return 65
        case .enable_quantity_factor_product_reports:
            return 66
        case .enable_add_kds_via_wifi:
            return 67
        case .enable_cloud_kitchen:
            return 68
        case .enable_force_longPolling_multisession:
            return 69
        case .enable_show_discount_name_invoice:
            return 70
        case .port_connection_ip:
            return 71
        case .hide_sent_to_kitchen_btn:
            return 72
        case .enable_show_unite_price_invoice:
            return 73
        case .no_retry_sent_ip:
            return 74
        case .enable_add_waiter_via_wifi:
            return 75
        case .enable_sync_order_sequence_wifi:
            return 76
        case .make_all_orders_defalut:
            return 77
        case .show_print_last_session_dashboard:
            return 78
        case .enable_chosse_account_journal_for_return_order:
            return 79
        case .enable_give_reason_for_void_sent_line:
            return 80
        case .enable_new_combo:
            return 81
        case .disable_idle_timer:
            return 82
        case .time_pass_to_go_lock_screen:
            return 83
        case .enable_show_new_render_invoice:
            return 84
        case .enable_resent_failure_ip_kds_order_automatic:
            return 85
        case .enable_reconnect_with_printer_automatic:
            return 86
        case .enable_work_with_bill_uid_default:
            return 87
        case .enable_hide_void_before_line:
            return 88
        case .enable_initalize_adjustment_with_zero:
            return 89
        case .auto_arrange_table_default:
            return 90

        case .enable_invoice_width:
            return 91
        case .width_invoice_to_set_new_dimensions:
            return 92
        case .time_sleep_print_queue:
            return 93
        case .enable_enhance_printer_cyle:
            return 94
        case .enable_local_qty_avaliblity:
            return 95
        case .options_for_require_customer:
            return 96
        case .enable_cloud_qr_code:
            return 97
        case .enable_recieve_update_order_online:
            return 98
        case .margin_invoice_left_value:
            return 99
        case .margin_invoice_right_value:
            return 100
        case .enable_new_product_style:
            return 101
        case .prevent_new_order_if_empty:
            return 102
        case .use_app_return:
            return 103
        case .use_app_return:
        return 104
        case .enable_sequence_at_master_only:
            return 105
        case .enable_phase2_Invoice_Offline_default:
        return 106
            
        case .enable_make_user_resposiblity_for_order:
                    return 107

        case .enable_retry_long_poll:
            return 108
        case .enable_force_update_by_owner:
            return 109
        case .enable_zebra_scanner_barcode:
            return 110
        case .enable_move_pending_orders:
            return 111
        case .enter_bar_code_length : return 112;
        case .start_value_for_bar_code : return 113;
        case .postion_start_id_for_bar_code : return 114;
        case .postion_end_id_for_bar_code : return 115;
        case .postion_start_qty_for_bar_code : return 116;
        case .postion_end_qty_for_bar_code : return 117;
        case .enable_scoket_mobile_scanner_barcode : return 118;
        case .enable_reecod_all_ip_log : return 119;
        case .enter_time_for_auto_send_fail_ip_message : return 120
        case .enter_count_page_fail_ip_message : return 121
        case .enable_check_duplicate_message_ids : return 122

        case .enable_phase2_Invoice_Offline_default:
        return 123
        case .use_app_return:
            return 124
        case .enable_enter_reason_void:
            return 125
        case .enable_stop_paied_intergrate_order:
            return 126
        case .start_value_containous_sequence:
            return 127
        case .enable_enter_containous_sequence:
            return 128
        case .enable_show_price_without_tax:
            return 129
        case .enable_check_duplicate_lines:
            return 130
            
        case .enable_play_sound_while_auto_accept_order_menu:
            return 131
        
        
        }
        
    }
    
    func getDefaultValue() -> Any{
        switch self {
        case .printer_mode : return Int(0);
        case .force_connect_with_printer :  return false;
        case .sales_report_filtter :   return "";
        case .STC_force_done :  return true;
        case .copy_right :  return true;
        case .qr_enable :  return false;
        case .receipt_copy_number :  return Int(1);
        case .clear_log_everyDays :  return Double(3);
        case .qr_url :  return "";
        case .category_scroll_direction_vertical :  return true;
        case .receipt_custom_header :  return false;
        case .receipt_copy_number_journal_type_bank :  return Int(1);
        case .open_drawer_only_with_cash_payment_method :  return true;
        case .receipt_logo_width :  return Double(60);
        case .enable_testMode :  return false;
        case .new_invocie_report :  return true;
        case .show_log :  return true;
        case .is_STC_productions :  return true;
        case .auto_print_zreport :  return true;
        case .timePaymentSuccessfullMessage :  return Double(3);
        case .cash_time :  return Double(1440);
        case .enable_autoPrint :  return true;
        case .clearPenddingOrders_everyDays :  return Double(10);
        case .show_all_products_inHome :  return false;
        case .enable_OrderType :  return Int(1);
        case .        time_close_old_session_to_allow_create_new_orders : return "12:00 AM" ;
        case .        close_old_session_to_allow_create_new_orders :  return false;
        case .enable_payment :  return true;
        case .clearOrders_everyDays :  return Double(60)
        case .show_invocie_notes: return true
        case .default_printer_name: return ""
        case .default_printer_ip: return ""
        case .link_setting_with_odoo_2: return false
            
        case .enable_record_all_log_multisession : return false
        case .enable_record_all_log : return false
        case .tries_non_priinted_number : return Int(0)
            
        case .ingenico_name:
            return ""
        case .ingenico_ip:
            return ""
            
        case .enable_multi_cash : return false
        case .enable_draft_mode : return false
        case .enable_UOM_kg:
            return false
        case .enable_customer_return_order:
            return false
        case .enable_email_mandatory_add_customer:
            return false
        case .enable_phone_mandatory_add_customer:
            return false
            
        case .mw_minuts_fail_report:
            return 5
            
        case .clear_error_log:
            return 2
            
            
        case .show_loyalty_details_in_invoice:
            return false
            
        case .show_number_of_items_in_invoice:
            return true
            
        case .enable_auto_accept_order_menu:
            return false
        case .enable_play_sound_while_auto_accept_order_menu:
            return false
        case .enable_play_sound_order_menu:
            return true
        case .start_session_sequence_order:
            return Double(1)
            
        case .end_sessiion_sequence_order:
            return Double(500)
        case .enable_enter_sessiion_sequence_order:
            return false
        case .enable_traing_mode:
            return false
        case .close_session_with_closed_orders:
            return true
        case .enable_qr_for_draft_bill:
            return false
        case .font_size_for_kitchen_invoice:
            return 50
        case .enable_sequence_orders_over_wifi:
            return false
        case .enable_log_sync_success_orders:
            return false
        case .enable_simple_invoice_vat:
            return false
        case .enable_auto_sent_to_kitchen:
            return false
        case .connection_printer_time_out:
            return 15
        case .enable_show_combo_details_invoice:
            return true
        case  .terminalID_geidea:
            return ""
            
        case .port_geidea:
            return 6100
        case .enable_support_multi_printer_brands:
            return false
        case .enable_quantity_factor_product_reports:
            return false
        case .enable_add_kds_via_wifi:
            return false
        case .enable_cloud_kitchen:
            return Int(0)
        case .enable_force_longPolling_multisession:
            return false
        case .enable_show_discount_name_invoice:
            return false
        case .port_connection_ip:
            return  Int(9090)
        case .hide_sent_to_kitchen_btn:
            return false
        case .enable_show_unite_price_invoice:
            return false
        case .no_retry_sent_ip:
            return  Int(3)
        case .enable_add_waiter_via_wifi:
            return false
        case .enable_sync_order_sequence_wifi:
            return false
        case .make_all_orders_defalut:
            return false
        case .show_print_last_session_dashboard:
            return true
        case .enable_chosse_account_journal_for_return_order:
            return false
        case .enable_give_reason_for_void_sent_line:
            return false
        case .enable_hide_void_before_line:
            return false
        case .enable_initalize_adjustment_with_zero:
            return false
        case .enable_new_combo:
            return false
            
        case .disable_idle_timer:
            return true
        case .time_pass_to_go_lock_screen:
            return Int(0)
        case .enable_show_new_render_invoice:
            return false
        case .enable_resent_failure_ip_kds_order_automatic:
            return false
        case .enable_reconnect_with_printer_automatic:
            return false
        case .auto_arrange_table_default:
            return true
        case .enable_work_with_bill_uid_default:
            return true
        case .enable_invoice_width:
            return false
        case .width_invoice_to_set_new_dimensions:
            return "8 MM"
        case .time_sleep_print_queue:
            return 0.0
        case .enable_local_qty_avaliblity:
            return false
        case .enable_enhance_printer_cyle:
            return false
        case .options_for_require_customer:
            return Int(2)
        case .enable_cloud_qr_code:
            return false
        case .enable_recieve_update_order_online:
            return false
       
        case .margin_invoice_left_value:
            return 35
        case .margin_invoice_right_value:
            return 25
        case .enable_new_product_style:
            return false
        case .enable_phase2_Invoice_Offline_default:
        return true
        case .use_app_return:
            return false
        case .enable_zebra_scanner_barcode:
            return false

        case .prevent_new_order_if_empty:
            return false
        case .enable_sequence_at_master_only:
            return false
            
        case .enable_make_user_resposiblity_for_order:
            return false
        case .enable_retry_long_poll:
return false
        case .enable_force_update_by_owner:
            return false
        case .enable_move_pending_orders:
            return false
        case .enter_bar_code_length : return 14;
        case .start_value_for_bar_code : return 9;
        case .postion_start_id_for_bar_code : return 3;
        case .postion_end_id_for_bar_code : return 7;
        case .postion_start_qty_for_bar_code : return 8;
        case .postion_end_qty_for_bar_code : return 13;
        case .enable_scoket_mobile_scanner_barcode : return false
        case .enable_reecod_all_ip_log : return false;
        case .enter_time_for_auto_send_fail_ip_message : return 5.0
        case .enter_count_page_fail_ip_message : return 5
        case .enable_check_duplicate_message_ids : return true

        case .enable_enter_reason_void:
            return false
        case .enable_stop_paied_intergrate_order:
            return false
        case .enable_enter_containous_sequence:
            return false
        case .start_value_containous_sequence:
            return 0
        case .enable_show_price_without_tax:
            return false
        case .enable_check_duplicate_lines:
            return false



        }
    }
    func getType() -> TYPE_SETTINGS{
        switch self {
        case .printer_mode : return TYPE_SETTINGS.number;
        case .force_connect_with_printer :  return TYPE_SETTINGS.check_box;
        case .sales_report_filtter :   return TYPE_SETTINGS.text;
        case .STC_force_done :  return TYPE_SETTINGS.check_box;
        case .copy_right :  return TYPE_SETTINGS.check_box;
        case .qr_enable :  return TYPE_SETTINGS.check_box;
        case .receipt_copy_number :  return TYPE_SETTINGS.number;
        case .clear_log_everyDays :  return TYPE_SETTINGS.number;
        case .qr_url :  return TYPE_SETTINGS.text;
        case .category_scroll_direction_vertical :  return TYPE_SETTINGS.check_box;
        case .receipt_custom_header :  return TYPE_SETTINGS.check_box;
        case .receipt_copy_number_journal_type_bank :  return TYPE_SETTINGS.number;
        case .open_drawer_only_with_cash_payment_method :  return TYPE_SETTINGS.check_box;
        case .receipt_logo_width :  return TYPE_SETTINGS.number;
        case .enable_testMode :  return TYPE_SETTINGS.check_box;
        case .new_invocie_report :  return TYPE_SETTINGS.check_box;
        case .show_log :  return TYPE_SETTINGS.check_box;
        case .is_STC_productions :  return TYPE_SETTINGS.check_box;
        case .auto_print_zreport :  return TYPE_SETTINGS.check_box;
        case .timePaymentSuccessfullMessage :  return TYPE_SETTINGS.number;
        case .cash_time :  return TYPE_SETTINGS.number;
        case .enable_autoPrint :  return TYPE_SETTINGS.check_box;
        case .clearPenddingOrders_everyDays :  return TYPE_SETTINGS.number;
        case .show_all_products_inHome :  return TYPE_SETTINGS.check_box;
        case .enable_OrderType :  return TYPE_SETTINGS.number;
        case .        time_close_old_session_to_allow_create_new_orders : return TYPE_SETTINGS.text ;
        case .        close_old_session_to_allow_create_new_orders :  return TYPE_SETTINGS.check_box;
        case .enable_payment :  return TYPE_SETTINGS.check_box;
        case .clearOrders_everyDays :  return TYPE_SETTINGS.number
        case .show_invocie_notes: return TYPE_SETTINGS.check_box
        case .default_printer_name: return TYPE_SETTINGS.text
        case .default_printer_ip: return TYPE_SETTINGS.text
        case .link_setting_with_odoo_2: return TYPE_SETTINGS.check_box
            
        case .enable_record_all_log_multisession : return TYPE_SETTINGS.check_box
        case .enable_record_all_log : return TYPE_SETTINGS.check_box
        case .tries_non_priinted_number: return TYPE_SETTINGS.number
        case .ingenico_name:
            return TYPE_SETTINGS.text
        case .ingenico_ip:
            return TYPE_SETTINGS.text
            
        case .enable_multi_cash: return TYPE_SETTINGS.check_box
        case .enable_draft_mode: return TYPE_SETTINGS.check_box
        case .enable_UOM_kg:
            return TYPE_SETTINGS.check_box
        case .enable_customer_return_order:
            return TYPE_SETTINGS.check_box
        case .enable_email_mandatory_add_customer:
            return TYPE_SETTINGS.check_box
        case .enable_phone_mandatory_add_customer:
            return TYPE_SETTINGS.check_box
            
        case .mw_minuts_fail_report:
            return TYPE_SETTINGS.number
        case .clear_error_log:
            return TYPE_SETTINGS.number
            
            
        case .show_loyalty_details_in_invoice:
            return TYPE_SETTINGS.check_box
            
        case .show_number_of_items_in_invoice:
            return TYPE_SETTINGS.check_box
            
        case .enable_auto_accept_order_menu:
            return TYPE_SETTINGS.check_box
        case .enable_play_sound_while_auto_accept_order_menu:
            return TYPE_SETTINGS.check_box
        case .enable_play_sound_order_menu:
            
            return TYPE_SETTINGS.check_box
        case .start_session_sequence_order:
            return TYPE_SETTINGS.number
        case .end_sessiion_sequence_order:
            return TYPE_SETTINGS.number
        case .enable_enter_sessiion_sequence_order:
            return TYPE_SETTINGS.check_box
        case .enable_traing_mode:
            return TYPE_SETTINGS.check_box
        case .close_session_with_closed_orders:
            return TYPE_SETTINGS.check_box
        case .enable_qr_for_draft_bill:
            return TYPE_SETTINGS.check_box
        case .font_size_for_kitchen_invoice:
            return TYPE_SETTINGS.number
        case .enable_sequence_orders_over_wifi:
            return TYPE_SETTINGS.check_box
        case .enable_log_sync_success_orders:
            return TYPE_SETTINGS.check_box
        case.enable_simple_invoice_vat:
            return TYPE_SETTINGS.check_box
        case .enable_auto_sent_to_kitchen:
            return TYPE_SETTINGS.check_box
        case .connection_printer_time_out:
            return TYPE_SETTINGS.number
        case .enable_show_combo_details_invoice:
            return TYPE_SETTINGS.check_box
        case  .terminalID_geidea:
            return TYPE_SETTINGS.text
        case .port_geidea:
            return TYPE_SETTINGS.number
        case .enable_support_multi_printer_brands:
            return TYPE_SETTINGS.check_box
        case .enable_quantity_factor_product_reports:
            return TYPE_SETTINGS.check_box
        case .enable_add_kds_via_wifi:
            return TYPE_SETTINGS.check_box
        case .enable_cloud_kitchen :
            return TYPE_SETTINGS.number
        case .enable_force_longPolling_multisession:
            return TYPE_SETTINGS.check_box
        case .enable_show_discount_name_invoice:
            return TYPE_SETTINGS.check_box
        case .port_connection_ip :
            return TYPE_SETTINGS.number
        case .hide_sent_to_kitchen_btn:
            return TYPE_SETTINGS.check_box
        case .enable_show_unite_price_invoice:
            return TYPE_SETTINGS.check_box
        case .no_retry_sent_ip:
            return TYPE_SETTINGS.number
        case .enable_add_waiter_via_wifi:
            return TYPE_SETTINGS.check_box
        case .enable_sync_order_sequence_wifi:
             return TYPE_SETTINGS.check_box
        case .make_all_orders_defalut:
            return TYPE_SETTINGS.check_box
        case .show_print_last_session_dashboard:
            return TYPE_SETTINGS.check_box
        case .enable_chosse_account_journal_for_return_order:
            return TYPE_SETTINGS.check_box
        case .enable_give_reason_for_void_sent_line:
            return TYPE_SETTINGS.check_box
        case .enable_hide_void_before_line:
            return TYPE_SETTINGS.check_box
        case .enable_initalize_adjustment_with_zero:
            return TYPE_SETTINGS.check_box
        case .enable_new_combo:
            return TYPE_SETTINGS.check_box
            
        case .disable_idle_timer:
            return .check_box
        case .time_pass_to_go_lock_screen:
            return .number
        case .enable_show_new_render_invoice:
            return TYPE_SETTINGS.check_box
        case .enable_resent_failure_ip_kds_order_automatic:
            return TYPE_SETTINGS.check_box
        case .enable_reconnect_with_printer_automatic:
            return TYPE_SETTINGS.check_box
        case .enable_work_with_bill_uid_default:
            return TYPE_SETTINGS.check_box
        case .auto_arrange_table_default:
            return TYPE_SETTINGS.check_box
        case .enable_invoice_width:
            return TYPE_SETTINGS.check_box
        case .width_invoice_to_set_new_dimensions:
            return TYPE_SETTINGS.text
        case .time_sleep_print_queue:
            return TYPE_SETTINGS.number
        case .enable_local_qty_avaliblity:
            return TYPE_SETTINGS.check_box
        case .enable_enhance_printer_cyle:
            return TYPE_SETTINGS.check_box
        case .options_for_require_customer:
            return TYPE_SETTINGS.number
        case .enable_cloud_qr_code:
            return TYPE_SETTINGS.check_box
        case .enable_recieve_update_order_online:
            return TYPE_SETTINGS.check_box
        case .margin_invoice_left_value:
            return TYPE_SETTINGS.number
        case .margin_invoice_right_value:
            return TYPE_SETTINGS.number
        case .enable_new_product_style:
            return TYPE_SETTINGS.check_box
        case .prevent_new_order_if_empty:
            return TYPE_SETTINGS.check_box
        case .enable_phase2_Invoice_Offline_default:
            return TYPE_SETTINGS.check_box
        case .use_app_return:
            return TYPE_SETTINGS.check_box
        case .enable_sequence_at_master_only:
            return TYPE_SETTINGS.check_box
        case .enable_retry_long_poll:
            return TYPE_SETTINGS.check_box
        case .enable_zebra_scanner_barcode:
            return TYPE_SETTINGS.check_box
        case .enable_enter_reason_void:
            return TYPE_SETTINGS.check_box
        case .enable_stop_paied_intergrate_order:
            return TYPE_SETTINGS.check_box
        case .enable_enter_containous_sequence:
            return TYPE_SETTINGS.check_box
        case .start_value_containous_sequence:
            return TYPE_SETTINGS.number
        case .enable_show_price_without_tax:
            return TYPE_SETTINGS.check_box
        case .enable_check_duplicate_lines:
            return TYPE_SETTINGS.check_box



        case .enable_make_user_resposiblity_for_order:
            return TYPE_SETTINGS.check_box
        case .enable_force_update_by_owner:
            return TYPE_SETTINGS.check_box
        case .enable_move_pending_orders:
            return TYPE_SETTINGS.check_box
        case .enter_bar_code_length : return TYPE_SETTINGS.number;
        case .start_value_for_bar_code : return TYPE_SETTINGS.number;
        case .postion_start_id_for_bar_code : return TYPE_SETTINGS.number;
        case .postion_end_id_for_bar_code : return TYPE_SETTINGS.number;
        case .postion_start_qty_for_bar_code : return TYPE_SETTINGS.number;
        case .postion_end_qty_for_bar_code : return TYPE_SETTINGS.number;
        case .enable_scoket_mobile_scanner_barcode : return TYPE_SETTINGS.check_box
        case .enable_reecod_all_ip_log : return TYPE_SETTINGS.check_box;
        case .enter_time_for_auto_send_fail_ip_message : return TYPE_SETTINGS.number;
        case .enter_count_page_fail_ip_message : return TYPE_SETTINGS.number;
        case .enable_check_duplicate_message_ids : return TYPE_SETTINGS.check_box


        }
    }
    func initGeneralSetting() -> ios_settings{
        let key = self
        if let cashSetting = getCashGeneralSetting() {
            return cashSetting
        }
        let name = key.rawValue
        let type =  key.getType()
        let currentValue = key.getDefaultValue()
        let defaultValue = key.getDefaultValue()
        var option = "None"
        if key == SETTING_KEY.enable_OrderType  ||  key == SETTING_KEY.enable_cloud_kitchen ||  key == SETTING_KEY.options_for_require_customer{
            option = "0,1,2"
        }
        let scope = SCOPE_SETTINGS.setting
        let version = Bundle.main.fullVersion
        let posID = -1
        return ios_settings(name: name,
                            value: currentValue,
                            defaultValue: defaultValue,
                            option: option,
                            type: type,
                            scope: scope,
                            version: version,
                            posID: posID)
    }
    func initPosSetting() -> ios_settings{
        let key = self
        if let cashSetting = getCashPosSetting() {
            return cashSetting
        }
        let name = key.rawValue
        let type =  key.getType()
        let currentValue = key.getDefaultValue()
        let defaultValue = key.getDefaultValue()
        var option = "None"
        if key == SETTING_KEY.enable_OrderType  ||  key == SETTING_KEY.enable_cloud_kitchen{
            option = "0,1,2"
        }
        let scope = SCOPE_SETTINGS.pos
        let version = Bundle.main.fullVersion
        let posID = SharedManager.shared.posConfig().id
        return ios_settings(name: name,
                            value: currentValue,
                            defaultValue: defaultValue,
                            option: option,
                            type: type,
                            scope: scope,
                            version: version,
                            posID: posID)
    }
    private func getCashGeneralSetting() -> ios_settings?{
        let key = self
        let cash_setting = SharedManager.shared.appSetting().toDictionary()
        if cash_setting.count <= 0 || cash_setting[key.stringKey()] == nil {
            return nil
        }
        let name = key.rawValue
        let type =  key.getType()
        let defaultValue = key.getDefaultValue()
        
        var value = defaultValue
        if  let currentValue = cash_setting[key.stringKey()] {
            value = currentValue
        }
        
        var option = "None"
        if key == SETTING_KEY.enable_OrderType  ||  key == SETTING_KEY.enable_cloud_kitchen{
            option = "0,1,2"
        }
        let scope = SCOPE_SETTINGS.setting
        let version = Bundle.main.fullVersion
        let posID = -1
        return ios_settings(name: name,
                            value: value,
                            defaultValue: defaultValue,
                            option: option,
                            type: type,
                            scope: scope,
                            version: version,
                            posID: posID)
        
    }
    private func getCashPosSetting() -> ios_settings?{
        let key = self
        let cash_setting = SharedManager.shared.appSetting().toDictionary()
        if cash_setting.count <= 0 || cash_setting[key.stringKey()] == nil {
            return nil
        }
        let name = key.rawValue
        let defaultValue = key.getDefaultValue()
        
        var value = defaultValue
        if  let currentValue = cash_setting[key.stringKey()] {
            value = currentValue
        }
        var option = "None"
        if key == SETTING_KEY.enable_OrderType  ||  key == SETTING_KEY.enable_cloud_kitchen{
            option = "0,1,2"
        }
        let type =  key.getType()
        let scope = SCOPE_SETTINGS.pos
        let version = Bundle.main.fullVersion
        let posID =  SharedManager.shared.posConfig().id
        return ios_settings(name: name,
                            value: value,
                            defaultValue: defaultValue,
                            option: option,
                            type: type,
                            scope: scope,
                            version: version,
                            posID: posID)
        
    }
    
}
//MARK:- SCOPE SETTING APP ENUM
enum SCOPE_SETTINGS:String{
    case pos = "pos", setting = "setting"
}
//MARK:- TYPE FIELDS SETTING APP
enum TYPE_SETTINGS:String {
    case check_box = "check_box" ,combo = "combo",text = "text",number="number"
}
