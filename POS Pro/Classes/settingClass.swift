//
//  settingClass.swift
//  pos
//
//  Created by khaled on 7/26/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import Foundation

enum enable_OrderType_option:Int {
    case disable = 0 , InPayment = 1 , InAddOrder = 2
}
enum enable_cloud_kitchen_option:Int{
    case DISABLE = 0 ,START_SESSION,ADD_NEW_ORDER
}
enum options_for_require_customer_enum:Int{
    case NONE = 0 ,ASK,REQUIRE

}
//
public class settingClass
{
    var enable_make_user_resposiblity_for_order: Bool = false {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_make_user_resposiblity_for_order.rawValue, with: "\(enable_make_user_resposiblity_for_order)")
        }
    }
    
    var prevent_new_order_if_empty: Bool = false {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.prevent_new_order_if_empty.rawValue, with: "\(prevent_new_order_if_empty)")
        }
    }
    var show_log : Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.show_log.rawValue, with: "\(show_log)")
        }
    }
    var is_STC_productions : Bool = true{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.is_STC_productions.rawValue, with: "\(is_STC_productions)")
        }
    }
    var STC_force_done : Bool = true{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.STC_force_done.rawValue, with: "\(STC_force_done)")
        }
    }

 
    
    var enable_OrderType  : enable_OrderType_option = .InPayment{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_OrderType.rawValue, with: "\(enable_OrderType.rawValue)")
        }
    }
 
    var enable_autoPrint : Bool = true{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_autoPrint.rawValue, with: "\(enable_autoPrint)")
        }
    }
    var show_all_products_inHome : Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.show_all_products_inHome.rawValue, with: "\(show_all_products_inHome)")
        }
    }
    var force_connect_with_printer:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.force_connect_with_printer.rawValue, with: "\(force_connect_with_printer)")
        }
    }
    var category_scroll_direction_vertical:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.category_scroll_direction_vertical.rawValue, with: "\(category_scroll_direction_vertical)")
        }
    }
    var auto_print_zreport:Bool = true{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.auto_print_zreport.rawValue, with: "\(auto_print_zreport)")
        }
    }
    var enable_payment:Bool = true{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_payment.rawValue, with: "\(enable_payment)")
        }
    }
    var copy_right:Bool = true{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.copy_right.rawValue, with: "\(copy_right)")
        }
    }
    var new_invocie_report:Bool = true{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.new_invocie_report.rawValue, with: "\(new_invocie_report)")
        }
    }
    
    var enable_draft_mode:Bool = true{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_draft_mode.rawValue, with: "\(enable_draft_mode)")
        }
    }
    
    var show_invocie_notes:Bool = true{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.show_invocie_notes.rawValue, with: "\(show_invocie_notes)")
        }
    }
    var open_drawer_only_with_cash_payment_method:Bool = true{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.open_drawer_only_with_cash_payment_method.rawValue, with: "\(open_drawer_only_with_cash_payment_method)")
        }
    }
    var receipt_custom_header:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.receipt_custom_header.rawValue, with: "\(receipt_custom_header)")
        }
    }
    var enable_testMode:Bool = false{
        didSet {
            MaintenanceInteractor.shared.conytrolActiveMode()
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_testMode.rawValue, with: "\(enable_testMode)")
        }
    }

    var close_old_session_to_allow_create_new_orders:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.close_old_session_to_allow_create_new_orders.rawValue, with: "\(close_old_session_to_allow_create_new_orders)")
        }
    }
    var time_close_old_session_to_allow_create_new_orders:String = "12:00 AM"{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.time_close_old_session_to_allow_create_new_orders.rawValue, with: "\(time_close_old_session_to_allow_create_new_orders)")
        }
    }
    var width_invoice_to_set_new_dimensions:String = "8 MM"{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.width_invoice_to_set_new_dimensions.rawValue, with: "\(width_invoice_to_set_new_dimensions)")
        }
    }
    
    
    var show_loyalty_details_in_invoice:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.show_loyalty_details_in_invoice.rawValue, with: "\(show_loyalty_details_in_invoice)")
        }
    }
    
    var show_number_of_items_in_invoice:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.show_number_of_items_in_invoice.rawValue, with: "\(show_number_of_items_in_invoice)")
        }
    }
    
    var close_session_with_closed_orders:Bool = true{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.close_session_with_closed_orders.rawValue, with: "\(close_session_with_closed_orders)")
        }
    }
    
  

    
    
    var sales_report_filtter:String = ""{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.sales_report_filtter.rawValue, with: "\(sales_report_filtter)")
        }
    }
    
    
    var qr_url:String = "https://pos.dgtera.com/order"{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.qr_url.rawValue, with: "\(qr_url)")
        }
    }
    var qr_enable:Bool = true{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.qr_enable.rawValue, with: "\(qr_enable)")
        }
    }

    
    
    
    var cash_time : Double = 1 * 60 * 24{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.cash_time.rawValue, with: "\(cash_time)")
        }
    }
    var receipt_logo_width :Double = 60{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.receipt_logo_width.rawValue, with: "\(receipt_logo_width)")
        }
    }
    var  printer_mode :Int = 0{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.printer_mode.rawValue, with: "\(printer_mode)")
        }
    }
    var  receipt_copy_number :Int = 1 {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.receipt_copy_number.rawValue, with: "\(receipt_copy_number)")
        }
    }// journal type cash
    var  receipt_copy_number_journal_type_bank :Int = 1{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.receipt_copy_number_journal_type_bank.rawValue, with: "\(receipt_copy_number_journal_type_bank)")
        }
    }

    var  timePaymentSuccessfullMessage :Int = 3{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.timePaymentSuccessfullMessage.rawValue, with: "\(timePaymentSuccessfullMessage)")
        }
    }
    var clearOrders_everyDays :Double = 60{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.clearOrders_everyDays.rawValue, with: "\(clearOrders_everyDays)")
        }
    }
    var clear_log_everyDays :Double = 2{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.clear_log_everyDays.rawValue, with: "\(clear_log_everyDays)")
        }
    }

     
    
    var enable_record_all_log:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_record_all_log.rawValue, with: "\(enable_record_all_log)")
        }
    }
    
    
    var enable_record_all_log_multisession:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_record_all_log_multisession.rawValue, with: "\(enable_record_all_log_multisession)")
        }
    }
    
    
    
    
    var clearPenddingOrders_every_hour :Double = 10{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.clearPenddingOrders_everyDays.rawValue, with: "\(clearPenddingOrders_every_hour)")
        }
    }  // 0 to disable

    var link_setting_with_odoo_2:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.link_setting_with_odoo_2.rawValue, with: "\(link_setting_with_odoo_2)")
        }
    }
    
    var  tries_non_priinted_number :Int = 0 {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.tries_non_priinted_number.rawValue, with: "\(tries_non_priinted_number)")
        }
    }// journal type cash
 
    var ingenico_name:String = ""{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.ingenico_name.rawValue, with: ingenico_name)
        }
    }
    var ingenico_ip:String = ""{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.ingenico_ip.rawValue, with: ingenico_ip)
        }
    }
    
    
    
    var enable_multi_cash : Bool = false {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_multi_cash.rawValue, with: "\(enable_multi_cash)")
        }
    }
    
    let multisession_get_last_create_order_days:Double = 1
    
    var enable_UOM_kg : Bool = true {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_UOM_kg.rawValue, with: "\(enable_UOM_kg)")
        }
    }
    var enable_customer_return_order : Bool = false {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_customer_return_order.rawValue, with: "\(enable_customer_return_order)")
        }
    }
    var enable_email_mandatory_add_customer : Bool = false {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_email_mandatory_add_customer.rawValue, with: "\(enable_email_mandatory_add_customer)")
        }
    }
    var enable_phone_mandatory_add_customer : Bool = false {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_phone_mandatory_add_customer.rawValue, with: "\(enable_phone_mandatory_add_customer)")
        }
    }
    
    
    var mw_minuts_fail_report :Double = 5{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.mw_minuts_fail_report.rawValue, with: "\(mw_minuts_fail_report)")
        }
    }
    var clear_error_log :Double = 2{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.clear_error_log.rawValue, with: "\(clear_error_log)")
        }
    }
    var enable_auto_accept_order_menu : Bool = false {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_auto_accept_order_menu.rawValue, with: "\(enable_auto_accept_order_menu)")
        }
    }
    var enable_play_sound_while_auto_accept_order_menu : Bool = false {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_play_sound_while_auto_accept_order_menu.rawValue, with: "\(enable_play_sound_while_auto_accept_order_menu)")
        }
    }
    var enable_play_sound_order_menu : Bool = true {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_play_sound_order_menu.rawValue, with: "\(enable_play_sound_order_menu)")
        }
    }
   
    var start_session_sequence_order :Double = 1{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.start_session_sequence_order.rawValue, with: "\(start_session_sequence_order)")
        }
    }
    var end_sessiion_sequence_order :Double = 500{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.end_sessiion_sequence_order.rawValue, with: "\(end_sessiion_sequence_order)")
        }
    }
   
    var enable_enter_sessiion_sequence_order : Bool = false {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_enter_sessiion_sequence_order.rawValue, with: "\(enable_enter_sessiion_sequence_order)")
        }
    }
    var enable_traing_mode:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_traing_mode.rawValue, with: "\(enable_traing_mode)")
        }
    }
    var enable_qr_for_draft_bill:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_qr_for_draft_bill.rawValue, with: "\(enable_qr_for_draft_bill)")
        }
    }
    var font_size_for_kitchen_invoice :Double = 50{
        didSet {
            HTMLTemplateGlobal.shared.intialTemplate()
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.font_size_for_kitchen_invoice.rawValue, with: "\(receipt_logo_width)")
        }
    }
    var enable_sequence_orders_over_wifi:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_sequence_orders_over_wifi.rawValue, with: "\(enable_sequence_orders_over_wifi)")
        }
    }
    var enable_log_sync_success_orders : Bool = false {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_log_sync_success_orders.rawValue, with: "\(enable_log_sync_success_orders)")
        }
    }
    
    var enable_simple_invoice_vat:Bool = true{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_simple_invoice_vat.rawValue, with: "\(enable_simple_invoice_vat)")
        }
    }
        
    
    var enable_auto_sent_to_kitchen:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_auto_sent_to_kitchen.rawValue, with: "\(enable_auto_sent_to_kitchen)")
        }
    }
    var connection_printer_time_out :Int = 15{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.connection_printer_time_out.rawValue, with: "\(connection_printer_time_out)")
        }
    }
    var enable_show_combo_details_invoice:Bool = true{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_show_combo_details_invoice.rawValue, with: "\(enable_show_combo_details_invoice)")
        }
    }
    var port_geidea :Int = 6100{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.port_geidea.rawValue, with: "\(port_geidea)")
        }
    }
    var terminalID_geidea :String = ""{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.terminalID_geidea.rawValue, with: "\(terminalID_geidea)")
        }
    }
    var enable_support_multi_printer_brands:Bool = true
    /*{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_support_multi_printer_brands.rawValue, with: "\(enable_support_multi_printer_brands)")
            if enable_support_multi_printer_brands {
                MWPrinterMigration.shared.migrationOldPOS()
            }else{
                MWPrinterMigration.shared.migrationNewPOS()
            }
        }
        }
     */
    var enable_quantity_factor_product_reports:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_quantity_factor_product_reports.rawValue, with: "\(enable_quantity_factor_product_reports)")
        }
    }
    var enable_add_kds_via_wifi:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_add_kds_via_wifi.rawValue, with: "\(enable_add_kds_via_wifi)")
        }}
    var enable_cloud_kitchen  : enable_cloud_kitchen_option = .DISABLE{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_cloud_kitchen.rawValue, with: "\(enable_cloud_kitchen.rawValue)")
        }
        }
    //enable_force_longPolling_multisession
    var enable_force_longPolling_multisession:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_force_longPolling_multisession.rawValue, with: "\(enable_force_longPolling_multisession)")
        }
    }
    var enable_show_discount_name_invoice:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_show_discount_name_invoice.rawValue, with: "\(enable_show_discount_name_invoice)")
        }
    }
    var enable_show_new_render_invoice:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_show_new_render_invoice.rawValue, with: "\(enable_show_new_render_invoice)")
        }
    }
    var port_connection_ip :Int = 9090{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.port_connection_ip.rawValue, with: "\(port_connection_ip)")
        }
    }
    
    var hide_sent_to_kitchen_btn:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.hide_sent_to_kitchen_btn.rawValue, with: "\(hide_sent_to_kitchen_btn)")
        }
    }
    var enable_show_unite_price_invoice:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_show_unite_price_invoice.rawValue, with: "\(enable_show_unite_price_invoice)")
        }
    }
    var no_retry_sent_ip :Int = 3{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.no_retry_sent_ip.rawValue, with: "\(no_retry_sent_ip)")
        }
    }
    var enable_add_waiter_via_wifi:Bool = false{
        didSet {
            socket_device_class.saveMasterSockectDevice(status: enable_add_waiter_via_wifi)
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_add_waiter_via_wifi.rawValue, with: "\(enable_add_waiter_via_wifi)")
        }}
    var enable_sync_order_sequence_wifi:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_sync_order_sequence_wifi.rawValue, with: "\(enable_sync_order_sequence_wifi)")
        }}
    var make_all_orders_defalut:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.make_all_orders_defalut.rawValue, with: "\(make_all_orders_defalut)")
        }
    }
    var show_print_last_session_dashboard : Bool = true {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.show_print_last_session_dashboard.rawValue, with: "\(show_print_last_session_dashboard)")
        }
    }
    var enable_chosse_account_journal_for_return_order : Bool = false {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_chosse_account_journal_for_return_order.rawValue, with: "\(enable_chosse_account_journal_for_return_order)")
        }
    }
    var enable_give_reason_for_void_sent_line : Bool = false {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_give_reason_for_void_sent_line.rawValue, with: "\(enable_give_reason_for_void_sent_line)")
        }
    }
    var enable_hide_void_before_line : Bool = false {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_hide_void_before_line.rawValue, with: "\(enable_hide_void_before_line)")
        }
    }
    var enable_initalize_adjustment_with_zero : Bool = false {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_initalize_adjustment_with_zero.rawValue, with: "\(enable_initalize_adjustment_with_zero)")
        }
    }
    var enable_new_combo : Bool = false {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_new_combo.rawValue, with: "\(enable_new_combo)")
        }
        }
    var disable_idle_timer : Bool = true {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.disable_idle_timer.rawValue, with: "\(disable_idle_timer)")
        }
    }
    var time_pass_to_go_lock_screen : Int = 0 {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.time_pass_to_go_lock_screen.rawValue, with: "\(time_pass_to_go_lock_screen)")
        }
    }
    var enable_resent_failure_ip_kds_order_automatic : Bool = false {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_resent_failure_ip_kds_order_automatic.rawValue, with: "\(enable_resent_failure_ip_kds_order_automatic)")
        }
    }
    var enable_reconnect_with_printer_automatic: Bool = false {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_reconnect_with_printer_automatic.rawValue, with: "\(enable_reconnect_with_printer_automatic)")
        }
    }
    var enable_work_with_bill_uid_default: Bool = true {
        didSet {
//            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_work_with_bill_uid_default.rawValue, with: "\(enable_work_with_bill_uid_default)")
        }
    }
    var auto_arrange_table_default: Bool = true {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.auto_arrange_table_default.rawValue, with: "\(auto_arrange_table_default)")
             }
   }
   
    var enable_invoice_width:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_invoice_width.rawValue, with: "\(enable_invoice_width)")
        }
        }
    var time_sleep_print_queue:Double = 0.0 {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.time_sleep_print_queue.rawValue, with: "\(time_sleep_print_queue)")
        }
    }
    var enable_local_qty_avaliblity: Bool = false {
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_local_qty_avaliblity.rawValue, with: "\(enable_local_qty_avaliblity)")
        }}
    var enable_enhance_printer_cyle:Bool = false{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_enhance_printer_cyle.rawValue, with: "\(enable_enhance_printer_cyle)")
        }
    }
    var options_for_require_customer  : options_for_require_customer_enum = .REQUIRE{
        didSet {
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.options_for_require_customer.rawValue, with: "\(options_for_require_customer.rawValue)")
        }
        }
    var enable_cloud_qr_code:Bool = false {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_cloud_qr_code.rawValue, with: "\(enable_cloud_qr_code)")

        }
    }
    var enable_recieve_update_order_online:Bool = false {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_recieve_update_order_online.rawValue, with: "\(enable_recieve_update_order_online)")
        }
        }
    //TYPE_SETTINGS.number
    var margin_invoice_left_value:Double = 35 {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.margin_invoice_left_value.rawValue, with: "\(margin_invoice_left_value)")

        }
    }
    var margin_invoice_right_value:Double = 25 {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.margin_invoice_right_value.rawValue, with: "\(margin_invoice_right_value)")

        }
    }
    var enable_new_product_style:Bool = false {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_new_product_style.rawValue, with: "\(enable_new_product_style)")
             }
        }
    var enable_phase2_Invoice_Offline_default:Bool = true {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_phase2_Invoice_Offline_default.rawValue, with: "\(enable_phase2_Invoice_Offline_default)")
        }
        }
    var use_app_return:Bool = false {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.use_app_return.rawValue, with: "\(use_app_return)")

        }
    }
    var enable_sequence_at_master_only:Bool = false {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_sequence_at_master_only.rawValue, with: "\(enable_sequence_at_master_only)")
            }
    }
    var enable_zebra_scanner_barcode:Bool = false {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_zebra_scanner_barcode.rawValue, with: "\(enable_zebra_scanner_barcode)")

        }
    }
    
    
    var enable_retry_long_poll:Bool = false {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_retry_long_poll.rawValue, with: "\(enable_retry_long_poll)")

        }
    }
    var enable_force_update_by_owner:Bool = false {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_force_update_by_owner.rawValue, with: "\(enable_force_update_by_owner)")

        }
    }
    var enable_move_pending_orders:Bool = false {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_move_pending_orders.rawValue, with: "\(enable_move_pending_orders)")

        }
    }
    
    //enable_move_pending_orders
    var enter_bar_code_length:Int = 14 {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enter_bar_code_length.rawValue, with: "\(enter_bar_code_length)")

        }
    } 
    var start_value_for_bar_code:Int = 9 {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.start_value_for_bar_code.rawValue, with: "\(start_value_for_bar_code)")

        }
    } 
    var postion_start_id_for_bar_code:Int = 3 {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.postion_start_id_for_bar_code.rawValue, with: "\(postion_start_id_for_bar_code)")

        }
    }
    var postion_end_id_for_bar_code:Int = 7 {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.postion_end_id_for_bar_code.rawValue, with: "\(postion_end_id_for_bar_code)")

        }
    } 
    var postion_start_qty_for_bar_code:Int = 8 {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.postion_start_qty_for_bar_code.rawValue, with: "\(postion_start_qty_for_bar_code)")

        }
    }
    var postion_end_qty_for_bar_code:Int = 14 {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.postion_end_qty_for_bar_code.rawValue, with: "\(postion_end_qty_for_bar_code)")

        }
    }
    var enable_scoket_mobile_scanner_barcode:Bool = false {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_scoket_mobile_scanner_barcode.rawValue, with: "\(enable_scoket_mobile_scanner_barcode)")

        }
    }
    var enable_reecod_all_ip_log:Bool = false {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_reecod_all_ip_log.rawValue, with: "\(enable_reecod_all_ip_log)")

        }
    }
    var enter_time_for_auto_send_fail_ip_message:Double = 5 {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enter_time_for_auto_send_fail_ip_message.rawValue, with: "\(enter_time_for_auto_send_fail_ip_message)")

        }
    }
    var enter_count_page_fail_ip_message:Int = 5 {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enter_count_page_fail_ip_message.rawValue, with: "\(enter_count_page_fail_ip_message)")

        }
    }
    var enable_check_duplicate_message_ids:Bool = true {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_check_duplicate_message_ids.rawValue, with: "\(enable_check_duplicate_message_ids)")

        }
    }
  
    //enable_enter_reason_void
    var enable_enter_reason_void:Bool = false {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_enter_reason_void.rawValue, with: "\(enable_enter_reason_void)")

        }
    }
    //enable_stop_paied_intergrate_order
    var enable_stop_paied_intergrate_order:Bool = false {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_stop_paied_intergrate_order.rawValue, with: "\(enable_stop_paied_intergrate_order)")

        }
    }
    var enable_enter_containous_sequence:Bool = false {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_enter_containous_sequence.rawValue, with: "\(enable_enter_containous_sequence)")

        }
    }
    var start_value_containous_sequence:Int = 0 {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.start_value_containous_sequence.rawValue, with: "\(start_value_containous_sequence)")

        }
    }
    var enable_show_price_without_tax:Bool = false  {
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_show_price_without_tax.rawValue, with: "\(enable_show_price_without_tax)")

        }
    }
    var enable_check_duplicate_lines:Bool = false {
        
        didSet{
            SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.enable_check_duplicate_lines.rawValue, with: "\(enable_check_duplicate_lines)")

        }
    }
    init() {
        
    }
     
    
    init(fromDictionary dictionary: [String:Any]){
        enable_cloud_kitchen = enable_cloud_kitchen_option.init(rawValue:  dictionary["enable_cloud_kitchen"] as? Int ?? enable_cloud_kitchen.rawValue)!

        enable_OrderType = enable_OrderType_option.init(rawValue:  dictionary["enable_OrderType"] as? Int ?? enable_OrderType.rawValue)!

        enable_testMode = dictionary["enable_testMode"] as? Bool ?? enable_testMode

        enable_autoPrint = dictionary["enable_autoPrint"] as? Bool ?? enable_autoPrint
        show_all_products_inHome = dictionary["show_all_products_inHome"] as? Bool ?? show_all_products_inHome
        is_STC_productions = dictionary["is_STC_productions"] as? Bool ?? is_STC_productions
        STC_force_done = dictionary["STC_force_done"] as? Bool ?? STC_force_done
        
        show_log = dictionary["show_log"] as? Bool ?? show_log
        force_connect_with_printer = dictionary["force_connect_with_printer"] as? Bool ?? force_connect_with_printer
        category_scroll_direction_vertical = dictionary["category_scroll_direction_vertical"] as? Bool ?? category_scroll_direction_vertical
        auto_print_zreport = dictionary["auto_print_zreport"] as? Bool ?? auto_print_zreport
        enable_payment = dictionary["enable_payment"] as? Bool ?? enable_payment
        receipt_custom_header = dictionary["receipt_custom_header"] as? Bool ?? receipt_custom_header
        
        cash_time = dictionary["cash_time"] as? Double ?? cash_time
       clearOrders_everyDays = dictionary["clearOrders_everyDays"] as? Double ?? clearOrders_everyDays
        clear_log_everyDays = dictionary["clear_log_everyDays"] as? Double ?? clear_log_everyDays
 
        
        timePaymentSuccessfullMessage = dictionary["timePaymentSuccessfullMessage"] as? Int ?? timePaymentSuccessfullMessage
        clearPenddingOrders_every_hour = dictionary["clearPenddingOrders_everyDays"] as? Double ?? clearPenddingOrders_every_hour
        receipt_logo_width = dictionary["receipt_logo_width"] as? Double ?? receipt_logo_width
        printer_mode = dictionary["printer_mode"] as? Int ?? printer_mode
        
        receipt_copy_number = dictionary["receipt_copy_number"] as? Int ?? receipt_copy_number
        receipt_copy_number_journal_type_bank = dictionary["receipt_copy_number_journal_type_bank"] as? Int ?? receipt_copy_number_journal_type_bank

        copy_right = dictionary["copy_right"] as? Bool ?? copy_right
        new_invocie_report = dictionary["new_invocie_report"] as? Bool ?? new_invocie_report

        sales_report_filtter = dictionary["sales_report_filtter"] as? String ?? sales_report_filtter
        open_drawer_only_with_cash_payment_method = dictionary["open_drawer_only_with_cash_payment_method"] as? Bool ?? open_drawer_only_with_cash_payment_method

        time_close_old_session_to_allow_create_new_orders = dictionary["time_close_old_session_to_allow_create_new_orders"] as? String ?? time_close_old_session_to_allow_create_new_orders
        width_invoice_to_set_new_dimensions = dictionary["width_invoice_to_set_new_dimensions"] as? String ?? width_invoice_to_set_new_dimensions
        close_old_session_to_allow_create_new_orders = dictionary["close_old_session_to_allow_create_new_orders"] as? Bool ?? close_old_session_to_allow_create_new_orders

        qr_enable = dictionary["qr_enable"] as? Bool ?? qr_enable
        qr_url = dictionary["qr_url"] as? String ?? qr_url
        link_setting_with_odoo_2 = dictionary["link_setting_with_odoo_2"] as? Bool ?? link_setting_with_odoo_2
        ingenico_name = dictionary["ingenico_name"] as? String ?? ingenico_name
        ingenico_ip = dictionary["ingenico_ip"] as? String ?? ingenico_ip

        enable_record_all_log_multisession = dictionary["enable_record_all_log_multisession"] as? Bool ?? enable_record_all_log_multisession
        enable_record_all_log = dictionary["enable_record_all_log"] as? Bool ?? enable_record_all_log
        tries_non_priinted_number = dictionary["tries_non_priinted_number_zero"] as? Int ?? tries_non_priinted_number
        enable_multi_cash = dictionary["enable_multi_cash"] as? Bool ?? enable_multi_cash
        enable_draft_mode = dictionary["enable_draft_mode"] as? Bool ?? enable_draft_mode
        enable_UOM_kg = dictionary["enable_UOM_kg"] as? Bool ?? enable_UOM_kg
        enable_customer_return_order = dictionary["enable_customer_return_order"] as? Bool ?? enable_customer_return_order
        enable_email_mandatory_add_customer = dictionary["enable_email_mandatory_add_customer"] as? Bool ?? enable_email_mandatory_add_customer
        enable_phone_mandatory_add_customer = dictionary["enable_phone_mandatory_add_customer"] as? Bool ?? enable_phone_mandatory_add_customer
        mw_minuts_fail_report = dictionary["mw_minuts_fail_report"] as? Double ?? mw_minuts_fail_report
        clear_error_log = dictionary["clear_error_log"] as? Double ?? clear_error_log
        show_loyalty_details_in_invoice = dictionary["show_loyalty_details_in_invoice"] as? Bool ?? show_loyalty_details_in_invoice
        show_number_of_items_in_invoice = dictionary["show_number_of_items_in_invoice"] as? Bool ?? show_number_of_items_in_invoice

        enable_auto_accept_order_menu = dictionary["enable_auto_accept_order_menu"] as? Bool ?? enable_auto_accept_order_menu
        enable_play_sound_while_auto_accept_order_menu = dictionary["enable_play_sound_while_auto_accept_order_menu"] as? Bool ?? enable_play_sound_while_auto_accept_order_menu
        enable_play_sound_order_menu = dictionary["enable_play_sound_order_menu_nd"] as? Bool ?? enable_play_sound_order_menu
        
        start_session_sequence_order = dictionary["start_session_sequence_order"] as? Double ?? start_session_sequence_order
        end_sessiion_sequence_order = dictionary["end_sessiion_sequence_order"] as? Double ?? end_sessiion_sequence_order
        enable_enter_sessiion_sequence_order = dictionary["enable_enter_sessiion_sequence_order"] as? Bool ?? enable_enter_sessiion_sequence_order
        enable_traing_mode = dictionary["enable_traing_mode"] as? Bool ?? enable_traing_mode
        close_session_with_closed_orders = dictionary["close_session_with_closed_orders"] as? Bool ?? close_session_with_closed_orders
        enable_qr_for_draft_bill = dictionary["enable_qr_for_draft_bill"] as? Bool ?? enable_qr_for_draft_bill
        font_size_for_kitchen_invoice  = dictionary["font_size_for_kitchen_invoice_50"] as? Double ?? font_size_for_kitchen_invoice
        enable_sequence_orders_over_wifi = dictionary["enable_sequence_orders_over_wifi"] as? Bool ?? enable_sequence_orders_over_wifi
        enable_log_sync_success_orders = dictionary["enable_log_sync_success_orders"] as? Bool ?? enable_log_sync_success_orders
        
        enable_simple_invoice_vat = dictionary["enable_simple_invoice_vat_new"] as? Bool ?? enable_simple_invoice_vat
        enable_auto_sent_to_kitchen = dictionary["enable_auto_sent_to_kitchen"] as? Bool ?? enable_auto_sent_to_kitchen
        enable_show_combo_details_invoice = dictionary["enable_show_combo_details_invoice"] as? Bool ?? enable_show_combo_details_invoice
        port_geidea = dictionary["port_geidea"] as? Int ?? port_geidea
        terminalID_geidea = dictionary["terminalID_geidea"] as? String ?? terminalID_geidea
        enable_support_multi_printer_brands = true //dictionary["enable_support_multi_printer_brands"] as? Bool ?? enable_support_multi_printer_brands
        enable_add_kds_via_wifi = dictionary["enable_add_kds_via_wifi"] as? Bool ?? enable_add_kds_via_wifi
        enable_force_longPolling_multisession = dictionary["enable_force_longPolling_multisession"] as? Bool ?? enable_force_longPolling_multisession
        enable_show_discount_name_invoice = dictionary["enable_show_discount_name_invoice"] as? Bool ?? enable_show_discount_name_invoice
        enable_show_new_render_invoice = dictionary["enable_show_new_render_invoice"] as? Bool ?? enable_show_new_render_invoice
        port_connection_ip = dictionary["port_connection_ip"] as? Int ?? port_connection_ip
        hide_sent_to_kitchen_btn = dictionary["hide_sent_to_kitchen_btn"] as? Bool ?? hide_sent_to_kitchen_btn
        enable_show_unite_price_invoice = dictionary["enable_show_unite_price_invoice"] as? Bool ?? enable_show_unite_price_invoice
        show_invocie_notes = dictionary["show_invocie_notes"] as? Bool ?? show_invocie_notes
        no_retry_sent_ip = dictionary["no_retry_sent_ip"] as? Int ?? no_retry_sent_ip
        enable_add_waiter_via_wifi = dictionary["enable_add_waiter_via_wifi"] as? Bool ?? enable_add_waiter_via_wifi
        enable_sync_order_sequence_wifi = dictionary["enable_sync_order_sequence_wifi"] as? Bool ?? enable_sync_order_sequence_wifi

        make_all_orders_defalut = dictionary["make_all_orders_defalut"] as? Bool ?? make_all_orders_defalut
        show_print_last_session_dashboard = dictionary["show_print_last_session_dashboard"] as? Bool ?? show_print_last_session_dashboard
        enable_chosse_account_journal_for_return_order = dictionary["enable_chosse_account_journal_for_return_order"] as? Bool ?? enable_chosse_account_journal_for_return_order
        enable_give_reason_for_void_sent_line = dictionary["enable_give_reason_for_void_sent_line"] as? Bool ?? enable_give_reason_for_void_sent_line
        enable_hide_void_before_line = dictionary["enable_hide_void_before_line"] as? Bool ?? enable_hide_void_before_line
        enable_initalize_adjustment_with_zero =  dictionary["enable_initalize_adjustment_with_zero"] as? Bool ?? enable_initalize_adjustment_with_zero
        enable_new_combo =  dictionary["enable_new_combo"] as? Bool ?? enable_new_combo
        disable_idle_timer =  dictionary["disable_idle_timer"] as? Bool ?? disable_idle_timer
        time_pass_to_go_lock_screen =  dictionary["time_pass_to_go_lock_screen"] as? Int ?? time_pass_to_go_lock_screen
        enable_resent_failure_ip_kds_order_automatic = dictionary["enable_resent_failure_ip_kds_order_automatic"] as? Bool ?? enable_resent_failure_ip_kds_order_automatic
        enable_reconnect_with_printer_automatic = dictionary["enable_reconnect_with_printer_automatic"] as? Bool ?? false
        enable_work_with_bill_uid_default = true //dictionary["enable_work_with_bill_uid_default"] as? Bool ?? false
        auto_arrange_table_default = dictionary["auto_arrange_table_default"] as? Bool ?? false
        enable_invoice_width = dictionary["enable_invoice_width"] as? Bool ?? enable_invoice_width
        time_sleep_print_queue = dictionary["time_sleep_print_queue"] as? Double ?? time_sleep_print_queue
        enable_local_qty_avaliblity = dictionary["enable_local_qty_avaliblity"] as? Bool ?? false
        enable_enhance_printer_cyle = dictionary["enable_enhance_printer_cyle"] as? Bool ?? enable_enhance_printer_cyle
        options_for_require_customer = options_for_require_customer_enum.init(rawValue:  dictionary["options_for_require_customer"] as? Int ?? options_for_require_customer.rawValue)!
        enable_cloud_qr_code = dictionary["enable_cloud_qr_code"] as? Bool ?? enable_cloud_qr_code
        enable_recieve_update_order_online = dictionary["enable_recieve_update_order_online"] as? Bool ?? enable_recieve_update_order_online
        margin_invoice_left_value = dictionary["margin_invoice_left_value"] as? Double ?? margin_invoice_left_value
        margin_invoice_right_value = dictionary["margin_invoice_right_value"] as? Double ?? margin_invoice_right_value
        enable_new_product_style = dictionary["enable_new_product_style"] as? Bool ?? enable_new_product_style
        prevent_new_order_if_empty = dictionary["prevent_new_order_if_empty"] as? Bool ?? prevent_new_order_if_empty
        enable_phase2_Invoice_Offline_default = dictionary["enable_phase2_Invoice_Offline_default"] as? Bool ?? enable_phase2_Invoice_Offline_default

//use_app_return
        use_app_return = dictionary["use_app_return"] as? Bool ?? use_app_return
        enable_sequence_at_master_only =  dictionary["enable_sequence_at_master_only"] as? Bool ?? enable_sequence_at_master_only
        enable_retry_long_poll = dictionary["enable_retry_long_poll"] as? Bool ?? enable_retry_long_poll
        enable_zebra_scanner_barcode = dictionary["enable_zebra_scanner_barcode"] as? Bool ?? enable_zebra_scanner_barcode
        //enable_enter_reason_void
        enable_enter_reason_void = dictionary["enable_enter_reason_void"] as? Bool ?? enable_enter_reason_void

        enable_make_user_resposiblity_for_order = dictionary["enable_make_user_resposiblity_for_order"] as? Bool ?? enable_make_user_resposiblity_for_order
        enable_force_update_by_owner =  dictionary["enable_force_update_by_owner"] as? Bool ?? enable_force_update_by_owner
        enable_move_pending_orders = dictionary["enable_move_pending_orders"] as? Bool ?? enable_move_pending_orders
        
       
        enter_bar_code_length =  dictionary["enter_bar_code_length"] as? Int ?? enter_bar_code_length
        start_value_for_bar_code =  dictionary["start_value_for_bar_code"] as? Int ?? start_value_for_bar_code
        postion_start_id_for_bar_code =  dictionary["postion_start_id_for_bar_code"] as? Int ?? postion_start_id_for_bar_code
        postion_end_id_for_bar_code =  dictionary["postion_end_id_for_bar_code"] as? Int ?? postion_end_id_for_bar_code
        postion_start_qty_for_bar_code =  dictionary["postion_start_qty_for_bar_code"] as? Int ?? postion_start_qty_for_bar_code
        postion_end_qty_for_bar_code =  dictionary["postion_end_qty_for_bar_code"] as? Int ?? postion_end_qty_for_bar_code
        enable_scoket_mobile_scanner_barcode = dictionary["enable_scoket_mobile_scanner_barcode"] as? Bool ?? enable_scoket_mobile_scanner_barcode
        enable_reecod_all_ip_log = dictionary["enable_reecod_all_ip_log"] as? Bool ?? enable_reecod_all_ip_log
        enter_time_for_auto_send_fail_ip_message = dictionary["enter_time_for_auto_send_fail_ip_message"] as? Double ?? enter_time_for_auto_send_fail_ip_message
        enter_count_page_fail_ip_message = dictionary["enter_count_page_fail_ip_message"] as? Int ?? enter_count_page_fail_ip_message
        enable_check_duplicate_message_ids = dictionary["enable_check_duplicate_message_ids"] as? Bool ?? enable_check_duplicate_message_ids
        enable_stop_paied_intergrate_order = dictionary["enable_stop_paied_intergrate_order"] as? Bool ?? enable_stop_paied_intergrate_order

        enable_enter_containous_sequence = dictionary["enable_enter_containous_sequence"] as? Bool ?? enable_enter_containous_sequence
        start_value_containous_sequence = dictionary["start_value_containous_sequence"] as? Int ?? start_value_containous_sequence

        enable_show_price_without_tax = dictionary["enable_show_price_without_tax"] as? Bool ?? enable_show_price_without_tax
        enable_check_duplicate_lines = dictionary["enable_check_duplicate_lines"] as? Bool ?? enable_check_duplicate_lines

    }
    
    
    
    func toDictionary() -> [String:Any]
    {
      var dictionary:[String:Any] = [:]
        dictionary["prevent_new_order_if_empty"] = prevent_new_order_if_empty
        dictionary["enable_OrderType"] = enable_OrderType.rawValue
        dictionary["enable_autoPrint"] = enable_autoPrint
        dictionary["cash_time"] = cash_time
        dictionary["show_all_products_inHome"] = show_all_products_inHome
        dictionary["is_STC_productions"] = is_STC_productions
        dictionary["STC_force_done"] = STC_force_done

        dictionary["show_log"] = show_log
        dictionary["clearOrders_everyDays"] = clearOrders_everyDays
        dictionary["force_connect_with_printer"] = force_connect_with_printer
        dictionary["clearPenddingOrders_everyDays"] = clearPenddingOrders_every_hour
        dictionary["receipt_logo_width"] = receipt_logo_width
        dictionary["category_scroll_direction_vertical"] = category_scroll_direction_vertical
        dictionary["auto_print_zreport"] = auto_print_zreport
        dictionary["enable_payment"] = enable_payment
        dictionary["printer_mode"] = printer_mode
        dictionary["receipt_copy_number"] = receipt_copy_number
        dictionary["receipt_copy_number_journal_type_bank"] = receipt_copy_number_journal_type_bank

        
        dictionary["copy_right"] = copy_right
        dictionary["new_invocie_report"] = new_invocie_report

        dictionary["sales_report_filtter"] = sales_report_filtter
        dictionary["open_drawer_only_with_cash_payment_method"] = open_drawer_only_with_cash_payment_method
        dictionary["receipt_custom_header"] = receipt_custom_header
        dictionary["enable_testMode"] = enable_testMode
        dictionary["timePaymentSuccessfullMessage"] = timePaymentSuccessfullMessage

        dictionary["time_close_old_session_to_allow_create_new_orders"] = time_close_old_session_to_allow_create_new_orders
        dictionary["width_invoice_to_set_new_dimensions"] = width_invoice_to_set_new_dimensions
        dictionary["close_old_session_to_allow_create_new_orders"] = close_old_session_to_allow_create_new_orders
        dictionary["clear_log_everyDays"] = clear_log_everyDays
 
        dictionary["qr_url"] = qr_url
        dictionary["qr_enable"] = qr_enable
        dictionary["link_setting_with_odoo_2"] = link_setting_with_odoo_2
        dictionary["enable_record_all_log_multisession"] = enable_record_all_log_multisession
        dictionary["enable_record_all_log"] = enable_record_all_log
        dictionary["tries_non_priinted_number_zero"] = tries_non_priinted_number
        dictionary["ingenico_name"] = ingenico_name
        dictionary["ingenico_ip"] = ingenico_ip
        dictionary["enable_multi_cash"] = enable_multi_cash
        dictionary["enable_draft_mode"] = enable_draft_mode
        dictionary["enable_UOM_kg"] = enable_UOM_kg
        dictionary["enable_customer_return_order"] = enable_customer_return_order
        dictionary["enable_email_mandatory_add_customer"] = enable_email_mandatory_add_customer
        dictionary["enable_phone_mandatory_add_customer"] = enable_phone_mandatory_add_customer
        dictionary["clear_error_log"] = clear_error_log
        dictionary["mw_minuts_fail_report"] = mw_minuts_fail_report
        dictionary["show_loyalty_details_in_invoice"] = show_loyalty_details_in_invoice

        dictionary["enable_auto_accept_order_menu"] = enable_auto_accept_order_menu
        dictionary["enable_play_sound_while_auto_accept_order_menu"] = enable_play_sound_while_auto_accept_order_menu
        dictionary["enable_play_sound_order_menu_nd"] = enable_play_sound_order_menu
        
        dictionary["end_sessiion_sequence_order"] = end_sessiion_sequence_order
        dictionary["start_session_sequence_order"] = start_session_sequence_order
        
        dictionary["enable_enter_sessiion_sequence_order"] = enable_enter_sessiion_sequence_order
        dictionary["enable_traing_mode"] = enable_traing_mode
        dictionary["show_number_of_items_in_invoice"] = show_number_of_items_in_invoice

        dictionary["close_session_with_closed_orders"] = close_session_with_closed_orders
        dictionary["enable_qr_for_draft_bill"] = enable_qr_for_draft_bill
        dictionary["font_size_for_kitchen_invoice_50"] = font_size_for_kitchen_invoice
        
        dictionary["enable_sequence_orders_over_wifi"] = enable_sequence_orders_over_wifi
        dictionary["enable_log_sync_success_orders"] = enable_log_sync_success_orders
        dictionary["enable_simple_invoice_vat_new"] = enable_simple_invoice_vat
        dictionary["enable_auto_sent_to_kitchen"]  = enable_auto_sent_to_kitchen
        dictionary["enable_show_combo_details_invoice"] = enable_show_combo_details_invoice
        dictionary["port_geidea"]  = port_geidea
        dictionary["terminalID_geidea"]  = terminalID_geidea
        dictionary["enable_cloud_kitchen"]  = enable_cloud_kitchen.rawValue

        dictionary["enable_support_multi_printer_brands"]  = enable_support_multi_printer_brands
        dictionary["enable_add_kds_via_wifi"] = enable_add_kds_via_wifi
        dictionary["enable_force_longPolling_multisession"]  = enable_force_longPolling_multisession
        dictionary["enable_show_discount_name_invoice"]  = enable_show_discount_name_invoice
        dictionary["enable_show_new_render_invoice"] = enable_show_new_render_invoice
        dictionary["port_connection_ip"]  = port_connection_ip
        dictionary["hide_sent_to_kitchen_btn"] = hide_sent_to_kitchen_btn
        dictionary["enable_show_unite_price_invoice"] = enable_show_unite_price_invoice
        dictionary["show_invocie_notes"] = show_invocie_notes
        dictionary["no_retry_sent_ip"] = no_retry_sent_ip
        dictionary["enable_add_waiter_via_wifi"] = enable_add_waiter_via_wifi
        dictionary["enable_sync_order_sequence_wifi"] = enable_sync_order_sequence_wifi
        dictionary["make_all_orders_defalut"] = make_all_orders_defalut
        dictionary["show_print_last_session_dashboard"] = show_print_last_session_dashboard
        dictionary["enable_chosse_account_journal_for_return_order"] = enable_chosse_account_journal_for_return_order
        dictionary["enable_give_reason_for_void_sent_line"] = enable_give_reason_for_void_sent_line
        dictionary["enable_hide_void_before_line"] = enable_hide_void_before_line
        dictionary["enable_initalize_adjustment_with_zero"] = enable_initalize_adjustment_with_zero
        dictionary["enable_new_combo"] = enable_new_combo
        dictionary["disable_idle_timer"] = disable_idle_timer
        dictionary["time_pass_to_go_lock_screen"] = time_pass_to_go_lock_screen
        dictionary["enable_resent_failure_ip_kds_order_automatic"] = enable_resent_failure_ip_kds_order_automatic
        dictionary["enable_reconnect_with_printer_automatic"] = enable_reconnect_with_printer_automatic
        dictionary["enable_work_with_bill_uid_default"] = true // enable_work_with_bill_uid_default
        dictionary["auto_arrange_table_default"] = auto_arrange_table_default
        dictionary["enable_invoice_width"] = enable_invoice_width

        dictionary["time_sleep_print_queue"] = time_sleep_print_queue
        dictionary["enable_local_qty_avaliblity"] = enable_local_qty_avaliblity
        dictionary["enable_enhance_printer_cyle"] = enable_enhance_printer_cyle
        dictionary["options_for_require_customer"] = options_for_require_customer.rawValue

        dictionary["enable_cloud_qr_code"] = enable_cloud_qr_code
        dictionary["enable_recieve_update_order_online"] = enable_recieve_update_order_online
        dictionary["margin_invoice_left_value"] = margin_invoice_left_value
        dictionary["margin_invoice_right_value"] = margin_invoice_right_value
        dictionary["enable_new_product_style"] = enable_new_product_style
//use_app_return
        dictionary["enable_phase2_Invoice_Offline_default"] = enable_phase2_Invoice_Offline_default
        dictionary["use_app_return"] = use_app_return
        dictionary["enable_sequence_at_master_only"] = enable_sequence_at_master_only
        dictionary["enable_retry_long_poll"] = enable_retry_long_poll
        dictionary["enable_zebra_scanner_barcode"] = enable_zebra_scanner_barcode
        dictionary["enable_phase2_Invoice_Offline_default"] = enable_phase2_Invoice_Offline_default
        dictionary["use_app_return"] = use_app_return
        dictionary["enable_enter_reason_void"] = enable_enter_reason_void
        dictionary["enable_stop_paied_intergrate_order"] = enable_stop_paied_intergrate_order

        dictionary["enable_make_user_resposiblity_for_order"] = enable_make_user_resposiblity_for_order
        dictionary["enable_force_update_by_owner"] = enable_force_update_by_owner
        dictionary["enable_move_pending_orders"] = enable_move_pending_orders
        
        dictionary["enter_bar_code_length"] = enter_bar_code_length
        dictionary["start_value_for_bar_code"] = start_value_for_bar_code
        dictionary["postion_start_id_for_bar_code"] = postion_start_id_for_bar_code
        dictionary["postion_end_id_for_bar_code"] = postion_end_id_for_bar_code
        dictionary["postion_start_qty_for_bar_code"] = postion_start_qty_for_bar_code
        dictionary["postion_end_qty_for_bar_code"] = postion_end_qty_for_bar_code
       dictionary["enable_scoket_mobile_scanner_barcode"] = enable_scoket_mobile_scanner_barcode
        dictionary["enable_reecod_all_ip_log"] = enable_reecod_all_ip_log
        dictionary["enter_time_for_auto_send_fail_ip_message"] = enter_time_for_auto_send_fail_ip_message
dictionary["enter_count_page_fail_ip_message"] = enter_count_page_fail_ip_message
        dictionary["enable_check_duplicate_message_ids"] = enable_check_duplicate_message_ids
        dictionary["enable_enter_containous_sequence"] = enable_enter_containous_sequence
        dictionary["start_value_containous_sequence"] = start_value_containous_sequence
        dictionary["enable_show_price_without_tax"] = enable_show_price_without_tax
        dictionary["enable_check_duplicate_lines"] = enable_check_duplicate_lines

        return dictionary
    }
    
    public static func getSettingClass() -> settingClass
    {
        let json = cash_data_class.get(key: "settingClass_setting")
        var setting:[String : Any] = [:]
        setting = setting.toDictionary(json: json)
 
        return settingClass(fromDictionary: setting )
    }
    
    func save()
    {
        cash_data_class.set(key: "settingClass_setting", value: toDictionary().jsonString() ?? "")
        SharedManager.shared.setsAppSettings()
//        myuserdefaults.setitems("setting", setValue: toDictionary(), prefix: "settingClass")
    }
    
    
    func isTimeToClearOrders() -> Bool
    {
          let days = SharedManager.shared.appSetting().clearOrders_everyDays * 60 * 24
        
        let temp = cash_data_class( days )
        temp.enableCash = true
        
        // check the start date
        let start_date = temp.getTimelastupdate("startDatabase")
        if start_date == nil
        {
            set_time_startDatabase()
            
            return false
        }
        else
        {
            return temp.isTimeTopdate("startDatabase")

        }
        
        
    }
    
    func set_time_startDatabase()
    {
        let days = SharedManager.shared.appSetting().clearOrders_everyDays * 60 * 24

         let temp =  cash_data_class(  days )
        temp.setTimelastupdate("startDatabase")
    }
    
    // ================================================
    // Printer
    public static func getSetting() -> (url: String?, name: String?, ip: String )
    {
//        let   setting =  "setting"
        
          var url   = cash_data_class.get(key: "url")
          var name   = cash_data_class.get(key: "setting_name")
          var ip  = cash_data_class.get(key: "setting_ip")
        
//        var url   = myuserdefaults.getitem("url", prefix: setting)  as? String
//        var name   = myuserdefaults.getitem("name", prefix: setting)  as? String
//        var ip  = myuserdefaults.getitem("ip", prefix: setting)  as? String

        if (url!.isEmpty)  {
            url = "https://tomtom_test.rabeh.io" //"https://tomtom_test.rabeh.io/web"
            // "http://gofekra.com/pos/web/"
        }
        
        if (name!.isEmpty)   {
            name = "Epson"
        }
        
        if (ip!.isEmpty)  {
//            ip = "192.168.192.168"
            ip = ""
        }
        
        
        return (url,name,ip!)
        
        
    }
    
    public static func savePrinter(name: String?, ip: String?)
    {
        
        cash_data_class.set(key: "setting_name", value: name!)
        cash_data_class.set(key: "setting_ip", value: (ip?.replacingOccurrences(of: "TCP:", with: "") ?? ""))
        SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.default_printer_name.rawValue, with: name ?? "")
        SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.default_printer_ip.rawValue, with: ip ?? "")
//        let   setting =  "setting"
//
//        myuserdefaults .setitems("name", setValue: name!, prefix: setting)
//        myuserdefaults .setitems("ip", setValue: ip!, prefix: setting)
 
        
        setIsSetPrinter()
        
    }
    
    public static func setIsSetPrinter()
    {
//        let   setting =  "setting"
    
        cash_data_class.set(key: "setting_saved", value: "true")

        
//        myuserdefaults .setitems("saved", setValue: "true", prefix: setting)
        
        
    }
    public static func isSetPrinter() -> Bool
    {
//         let  setting =  "setting"
//        let saved  = myuserdefaults.getitem("saved", prefix: setting)  as? String
 
        let saved  = cash_data_class.get(key: "setting_saved") ?? ""
        if saved == ""
        {
               return false
        }
     
      
        return true
    }
    
 
    
}
