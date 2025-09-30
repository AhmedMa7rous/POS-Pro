//
//  setting_app.swift
//  pos
//
//  Created by Khaled on 12/11/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class setting_app: UIViewController , enterBalance_delegate {
    @IBOutlet weak var sw_show_log: UISwitch!
    @IBOutlet weak var sw_STC_productions: UISwitch!
    @IBOutlet weak var sw_STC_force_done: UISwitch!

    @IBOutlet weak var sw_enable_testMode: UISwitch!

    @IBOutlet weak var sw_enable_autoPrint: UISwitch!
    @IBOutlet weak var sw_show_products_inHome: UISwitch!
    @IBOutlet weak var sw_force_connect_with_printer: UISwitch!
    @IBOutlet weak var sw_category_scroll_direction_vertical: UISwitch!
    @IBOutlet weak var sw_auto_print_zreport: UISwitch!
    @IBOutlet weak var sw_enable_payment: UISwitch!
    @IBOutlet weak var sw_copy_right: UISwitch!
    @IBOutlet weak var sw_new_invocie_report: UISwitch!
    @IBOutlet weak var sw_show_invocie_note: UISwitch!

    @IBOutlet weak var sw_receipt_custom_header: UISwitch!
    @IBOutlet weak var sw_qr: UISwitch!
    @IBOutlet weak var sw_enable_record_all_log_multisession: UISwitch!
    @IBOutlet weak var sw_enable_record_all_log: UISwitch!

    @IBOutlet weak var sw_enable_draft: UISwitch!
    @IBOutlet weak var sw_enable_multiCash: UISwitch!
    
    @IBOutlet var view_force_connect_printer: ShadowView!
    @IBOutlet weak var sw_open_drawer_only_with_cash_payment_method: UISwitch!

        @IBOutlet var scroll: UIScrollView!
    
    var self_me: UIViewController! = nil
    
    @IBOutlet weak var txt_cashTime: kTextField!
    @IBOutlet weak var txt_clear_log: kTextField!
    @IBOutlet weak var txt_clear_log_mulitsession: kTextField!

    @IBOutlet weak var txt_clearOrders: kTextField!
    @IBOutlet weak var txt_clearPenddingOrders: kTextField!
    @IBOutlet weak var txt_timePaymentSuccessfullMessage: kTextField!
    @IBOutlet weak var txt_qr_url: kTextField!

    @IBOutlet weak var btn_change_time_close_old_session_to_allow_create_new_orders: UIButton!
    @IBOutlet weak var sw_close_old_session_to_allow_create_new_orders: UISwitch!
    @IBOutlet weak var sw_show_loyalty_details_in_invoice: UISwitch!
    @IBOutlet weak var sw_show_number_of_items_in_invoice: UISwitch!
    @IBOutlet weak var sw_close_session_with_closed_orders: UISwitch!

    
    
    
        @IBOutlet weak var txt_receipt_logo_width: kTextField!
    @IBOutlet weak var txt_printer_mode: kTextField!
    @IBOutlet weak var txt_receipt_copy_number: kTextField!
    @IBOutlet weak var txt_receipt_copy_number_bank: kTextField!
    
 

    @IBOutlet var seq_enable_payment: UISegmentedControl!
    @IBOutlet weak var sw_link_setting_with_odoo_2: UISwitch!
    @IBOutlet weak var txt_tries_non_printed: kTextField!

    @IBOutlet weak var sw_UOM_kg: UISwitch!
    @IBOutlet weak var sw_customer_return_order: UISwitch!
    @IBOutlet weak var sw_email_mandatory_add_customer: UISwitch!
    @IBOutlet weak var sw_phone_mandatory_add_customer: UISwitch!

    
    @IBOutlet weak var txt_clear_error_log: kTextField!
    @IBOutlet weak var txt_minuts_fail_report: kTextField!
    @IBOutlet weak var sw_enable_auto_accept_order_menu: UISwitch!
    @IBOutlet weak var sw_enable_play_sound_order_menu: UISwitch!

    @IBOutlet weak var btn_staer_session_sequence_order: KButton!
    @IBOutlet weak var btn_end_sessiion_sequence_order: KButton!
    @IBOutlet weak var sw_enable_enter_sessiion_sequence_order: UISwitch!

    @IBOutlet weak var start_sequence_view: ShadowView!
    @IBOutlet weak var end_sequence_view: ShadowView!
    @IBOutlet weak var sw_enable_qr_for_draft_bill: UISwitch!

    
    var setting = SharedManager.shared.appSetting()
    @IBOutlet weak var txt_font_size_for_kitchen_invoice: kTextField!
    @IBOutlet weak var sw_enable_sequence_orders_over_wifi: UISwitch!
    @IBOutlet weak var sw_enable_log_sync_success_orders: UISwitch!

    @IBOutlet weak var sw_simple_invoice_vat: UISwitch!
    @IBOutlet weak var sw_enable_auto_sent_to_kitchen: UISwitch!
    @IBOutlet weak var txt_connection_printer_time_out: kTextField!
    @IBOutlet weak var sw_enable_show_combo_details_invoice: UISwitch!
    @IBOutlet weak var sw_enable_support_multi_printer_brands: UISwitch!
    @IBOutlet weak var sw_enable_quantity_factor_product_reports: UISwitch!
    @IBOutlet weak var sw_enable_add_kds_via_wifi: UISwitch!
    @IBOutlet weak var sw_enable_force_longPolling_multisession: UISwitch!
    @IBOutlet weak var sw_enable_show_discount_name_invoice: UISwitch!
    @IBOutlet weak var sw_enable_show_new_render_invoice: UISwitch!
    @IBOutlet weak var cloudKitchSegment: UISegmentedControl!
    @IBOutlet weak var txt_port_connection_ip: kTextField!
    @IBOutlet weak var sw_hide_sent_to_kitchen_btn: UISwitch!
//enable_show_unite_price_invoice
    @IBOutlet weak var sw_enable_show_unite_price_invoice: UISwitch!
    @IBOutlet weak var sw_enable_add_waiter_via_wifi: UISwitch!

    @IBOutlet weak var waiterViaWifiView: UIView!
    @IBOutlet weak var kdsViaWifiView: UIView!
    @IBOutlet weak var sw_enable_sync_order_sequence_wifi: UISwitch!
    
    @IBOutlet weak var sw_make_all_orders_defalut: UISwitch!
    @IBOutlet weak var sw_enable_hide_void_before_line: UISwitch!
    @IBOutlet weak var sw_show_print_last_session_dashboard: UISwitch!
    @IBOutlet weak var sw_enable_chosse_account_journal_for_return_order: UISwitch!
    @IBOutlet weak var sw_enable_initalize_adjustment_with_zero: UISwitch!
    @IBOutlet weak var sw_enable_new_combo: UISwitch!


    override func viewDidLoad() {
        super.viewDidLoad()
        if !SharedManager.shared.posConfig().isMasterTCP() {
            self.kdsViaWifiView.isHidden = true
        }
        setting = SharedManager.shared.appSetting()
        if LanguageManager.currentLang() == .ar {
            seq_enable_payment.setTitle("إيقاف", forSegmentAt: 0)
            seq_enable_payment.setTitle("الدفع", forSegmentAt: 1)
            seq_enable_payment.setTitle("طلب جديد", forSegmentAt: 2)
            cloudKitchSegment.setTitle("إيقاف", forSegmentAt: 0)
            cloudKitchSegment.setTitle("بداء الجلسة", forSegmentAt: 1)
            cloudKitchSegment.setTitle("طلب جديد", forSegmentAt: 2)
        }
//        sw_enable_new_combo.isOn = setting.enable_new_combo
        sw_enable_initalize_adjustment_with_zero.isOn = setting.enable_initalize_adjustment_with_zero

        sw_enable_chosse_account_journal_for_return_order.isOn = setting.enable_chosse_account_journal_for_return_order

        sw_enable_hide_void_before_line.isOn = setting.enable_hide_void_before_line
        sw_show_print_last_session_dashboard.isOn = setting.show_print_last_session_dashboard
        txt_minuts_fail_report.text = setting.mw_minuts_fail_report.toIntString()
        sw_make_all_orders_defalut.isOn = setting.make_all_orders_defalut
        btn_staer_session_sequence_order.setTitle(setting.start_session_sequence_order.toIntString(), for: UIControl.State.normal)
        btn_end_sessiion_sequence_order.setTitle(setting.end_sessiion_sequence_order.toIntString(), for: UIControl.State.normal)
        sw_enable_enter_sessiion_sequence_order.isOn = setting.enable_enter_sessiion_sequence_order
        self.start_sequence_view.isHidden = !sw_enable_enter_sessiion_sequence_order.isOn
        self.end_sequence_view.isHidden = !sw_enable_enter_sessiion_sequence_order.isOn
        sw_enable_autoPrint.isOn =  setting.enable_autoPrint
        sw_show_products_inHome.isOn =  setting.show_all_products_inHome
        sw_STC_productions.isOn =  setting.is_STC_productions
        sw_STC_force_done.isOn =  setting.STC_force_done

        sw_show_log.isOn = setting.show_log
        sw_link_setting_with_odoo_2.isOn = setting.link_setting_with_odoo_2
        sw_UOM_kg.isOn = setting.enable_UOM_kg
        sw_customer_return_order.isOn = setting.enable_customer_return_order
        sw_email_mandatory_add_customer.isOn = setting.enable_email_mandatory_add_customer
        sw_phone_mandatory_add_customer.isOn = setting.enable_phone_mandatory_add_customer
        sw_enable_auto_accept_order_menu.isOn = setting.enable_auto_accept_order_menu
        sw_enable_play_sound_order_menu.isOn = setting.enable_play_sound_order_menu

        sw_force_connect_with_printer.isOn = setting.force_connect_with_printer
        sw_category_scroll_direction_vertical.isOn = setting.category_scroll_direction_vertical
        sw_auto_print_zreport.isOn = setting.auto_print_zreport
        sw_enable_payment.isOn = setting.enable_payment
        sw_copy_right.isOn = setting.copy_right
        sw_new_invocie_report.isOn = setting.new_invocie_report
        sw_show_invocie_note.isOn = setting.show_invocie_notes
        sw_open_drawer_only_with_cash_payment_method.isOn = setting.open_drawer_only_with_cash_payment_method
        sw_receipt_custom_header.isOn = setting.receipt_custom_header
        sw_enable_testMode.isOn = setting.enable_testMode
        sw_qr.isOn = setting.qr_enable
        sw_enable_record_all_log_multisession.isOn = setting.enable_record_all_log_multisession
        sw_enable_record_all_log.isOn  = setting.enable_record_all_log
        
        sw_enable_multiCash.isOn =  setting.enable_multi_cash
        sw_enable_draft.isOn =  setting.enable_draft_mode

        sw_show_number_of_items_in_invoice.isOn = setting.show_number_of_items_in_invoice
        sw_show_loyalty_details_in_invoice.isOn = setting.show_loyalty_details_in_invoice
        sw_close_session_with_closed_orders.isOn = setting.close_session_with_closed_orders

 
//        sw_enable_auto_close_session.isOn = setting.enable_auto_close_session
//        btn_change_time_auto_close_session.isEnabled =  sw_enable_auto_close_session.isOn
        sw_enable_qr_for_draft_bill.isOn = setting.enable_qr_for_draft_bill
 
 
        sw_close_old_session_to_allow_create_new_orders.isOn = setting.close_old_session_to_allow_create_new_orders
        btn_change_time_close_old_session_to_allow_create_new_orders.isEnabled =  sw_close_old_session_to_allow_create_new_orders.isOn
 
        sw_enable_sequence_orders_over_wifi.isOn = setting.enable_sequence_orders_over_wifi
        sw_enable_log_sync_success_orders.isOn  = setting.enable_log_sync_success_orders
        sw_simple_invoice_vat.isOn = setting.enable_simple_invoice_vat
        sw_enable_auto_sent_to_kitchen.isOn = setting.enable_auto_sent_to_kitchen
        sw_enable_show_combo_details_invoice.isOn = setting.enable_show_combo_details_invoice
        sw_enable_support_multi_printer_brands.isOn = setting.enable_support_multi_printer_brands
        sw_enable_add_kds_via_wifi.isOn = setting.enable_add_kds_via_wifi
        sw_enable_add_waiter_via_wifi.isOn = setting.enable_add_waiter_via_wifi
        sw_hide_sent_to_kitchen_btn.isOn = setting.hide_sent_to_kitchen_btn
        seq_enable_payment.selectedSegmentIndex = setting.enable_OrderType.rawValue
        cloudKitchSegment.selectedSegmentIndex = setting.enable_cloud_kitchen.rawValue

        sw_enable_quantity_factor_product_reports.isOn = setting.enable_quantity_factor_product_reports
        sw_enable_force_longPolling_multisession.isOn = setting.enable_force_longPolling_multisession
        sw_enable_show_discount_name_invoice.isOn = setting.enable_show_discount_name_invoice
        sw_enable_show_new_render_invoice.isOn = setting.enable_show_new_render_invoice
        sw_enable_show_unite_price_invoice.isOn = setting.enable_show_unite_price_invoice
        
        sw_enable_new_combo.addTarget(self_me, action: #selector(enable_new_combo), for: UIControl.Event.valueChanged)
        sw_enable_sync_order_sequence_wifi.isOn = setting.enable_sync_order_sequence_wifi
        sw_enable_sync_order_sequence_wifi.addTarget(self_me, action: #selector(enable_sync_order_sequence_wifi), for:UIControl.Event.valueChanged)

        sw_enable_chosse_account_journal_for_return_order.addTarget(self_me, action: #selector(enable_chosse_account_journal_for_return_order), for: UIControl.Event.valueChanged)
        sw_enable_initalize_adjustment_with_zero.addTarget(self_me, action: #selector(enable_initalize_adjustment_with_zero), for:UIControl.Event.valueChanged)

        sw_enable_hide_void_before_line.addTarget(self_me, action: #selector(enable_hide_void_before_line), for: UIControl.Event.valueChanged)
        
        sw_show_print_last_session_dashboard.addTarget(self_me, action: #selector(show_print_last_session_dashboard), for:UIControl.Event.valueChanged)
        
        
        sw_make_all_orders_defalut.addTarget(self_me, action: #selector(make_all_orders_defalut), for: UIControl.Event.valueChanged)
        sw_enable_show_unite_price_invoice.addTarget(self_me, action: #selector(enable_show_unite_price_invoice), for:UIControl.Event.valueChanged)

        sw_hide_sent_to_kitchen_btn.addTarget(self_me, action: #selector(sw_hide_sent_to_kitchen_btn(_:)), for:UIControl.Event.valueChanged)
        
        sw_close_old_session_to_allow_create_new_orders.addTarget(self_me, action: #selector(close_old_session_to_allow_create_new_orders(_:)), for:UIControl.Event.valueChanged)
        sw_enable_testMode.addTarget(self_me, action: #selector(enable_testMode(_:)), for:UIControl.Event.valueChanged)
        sw_enable_autoPrint.addTarget(self_me, action: #selector(enable_autoPrint(_:)), for:UIControl.Event.valueChanged)
        sw_show_products_inHome.addTarget(self_me, action: #selector(show_products_inhome(_:)), for:UIControl.Event.valueChanged)
        
        sw_STC_productions.addTarget(self_me, action: #selector(STC_productions(_:)), for:UIControl.Event.valueChanged)
        sw_STC_force_done.addTarget(self_me, action: #selector(STC_force_done(_:)), for:UIControl.Event.valueChanged)

        sw_show_log.addTarget(self_me, action: #selector(show_log(_:)), for:UIControl.Event.valueChanged)
        sw_link_setting_with_odoo_2.addTarget(self_me, action: #selector(linkSettingWithOdoo(_:)), for:UIControl.Event.valueChanged)
        sw_UOM_kg.addTarget(self_me, action: #selector(UOM_kg(_:)), for:UIControl.Event.valueChanged)
        sw_customer_return_order.addTarget(self_me, action: #selector(customer_return_order(_:)), for:UIControl.Event.valueChanged)
        sw_email_mandatory_add_customer.addTarget(self_me, action: #selector(emai_mandatory_add_customer(_:)), for:UIControl.Event.valueChanged)
        sw_phone_mandatory_add_customer.addTarget(self_me, action: #selector(phone_mandatory_add_customer(_:)), for:UIControl.Event.valueChanged)

        sw_enable_auto_accept_order_menu.addTarget(self_me, action: #selector(enable_auto_accept_order_menu(_:)), for:UIControl.Event.valueChanged)
        sw_enable_play_sound_order_menu.addTarget(self_me, action: #selector(enable_play_sound_order_menu(_:)), for:UIControl.Event.valueChanged)

        sw_force_connect_with_printer.addTarget(self_me, action: #selector(force_connect_with_printer), for:UIControl.Event.valueChanged)
        sw_category_scroll_direction_vertical.addTarget(self_me, action: #selector(category_scroll_direction_vertical), for:UIControl.Event.valueChanged)
        sw_auto_print_zreport.addTarget(self_me, action: #selector(auto_print_zreport), for:UIControl.Event.valueChanged)
        sw_enable_payment.addTarget(self_me, action: #selector(enable_payment), for:UIControl.Event.valueChanged)
        sw_copy_right.addTarget(self_me, action: #selector(copy_right), for:UIControl.Event.valueChanged)
        sw_new_invocie_report.addTarget(self_me, action: #selector(new_invocie_report), for:UIControl.Event.valueChanged)
        sw_show_invocie_note.addTarget(self_me, action: #selector(show_invocie_notes), for:UIControl.Event.valueChanged)
        sw_open_drawer_only_with_cash_payment_method.addTarget(self_me, action: #selector(open_drawer_only_with_cash_payment_method), for:UIControl.Event.valueChanged)
        sw_receipt_custom_header.addTarget(self_me, action: #selector(receipt_custom_header), for:UIControl.Event.valueChanged)
        sw_qr.addTarget(self_me, action: #selector(qr_enable), for:UIControl.Event.valueChanged)
        sw_enable_record_all_log_multisession.addTarget(self_me, action: #selector(enable_record_all_log_multisession), for:UIControl.Event.valueChanged)
        
        sw_show_loyalty_details_in_invoice.addTarget(self_me, action: #selector(show_loyalty_details_in_invoice), for:UIControl.Event.valueChanged)
        sw_close_session_with_closed_orders.addTarget(self_me, action: #selector(close_session_with_closed_orders), for:UIControl.Event.valueChanged)

        sw_show_number_of_items_in_invoice.addTarget(self_me, action: #selector(show_number_of_items_in_invoice), for:UIControl.Event.valueChanged)
      

        sw_enable_record_all_log.addTarget(self_me, action: #selector(enable_record_all_log), for:UIControl.Event.valueChanged)
        sw_enable_multiCash.addTarget(self_me, action: #selector(enable_multiCash), for:UIControl.Event.valueChanged)
        sw_enable_draft.addTarget(self_me, action: #selector(enable_draft), for:UIControl.Event.valueChanged)
        sw_enable_qr_for_draft_bill.addTarget(self_me, action: #selector(enable_qr_for_draft_bill(_:)), for:UIControl.Event.valueChanged)
        sw_enable_sequence_orders_over_wifi.addTarget(self_me, action: #selector(enable_sequence_orders_over_wifi(_:)), for:UIControl.Event.valueChanged)
        sw_enable_log_sync_success_orders.addTarget(self_me, action: #selector(enable_log_sync_success_orders(_:)), for:UIControl.Event.valueChanged)

        sw_simple_invoice_vat.addTarget(self_me, action: #selector(enable_simple_invoice_vat(_:)), for:UIControl.Event.valueChanged)

        sw_enable_auto_sent_to_kitchen.addTarget(self_me, action: #selector(enable_auto_sent_to_kitchen(_:)), for:UIControl.Event.valueChanged)
        
        sw_enable_show_combo_details_invoice.addTarget(self_me,action: #selector(enable_show_combo_details_invoice(_:)), for:UIControl.Event.valueChanged)
        sw_enable_support_multi_printer_brands.addTarget(self_me,action: #selector(enable_support_multi_printer_brands(_:)), for:UIControl.Event.valueChanged)
        sw_enable_add_kds_via_wifi.addTarget(self_me,action: #selector(sw_enable_add_kds_via_wifi(_:)), for:UIControl.Event.valueChanged)
        sw_enable_add_waiter_via_wifi.addTarget(self_me,action: #selector(sw_enable_add_waiter_via_wifi(_:)), for:UIControl.Event.valueChanged)
        
        sw_enable_force_longPolling_multisession.addTarget(self_me,action: #selector(enable_force_longPolling_multisession(_:)), for:UIControl.Event.valueChanged)

        sw_enable_show_discount_name_invoice.addTarget(self_me,action: #selector(enable_show_discount_name_invoice(_:)), for:UIControl.Event.valueChanged)
        txt_timePaymentSuccessfullMessage.text = String( setting.timePaymentSuccessfullMessage  )
        txt_cashTime.text = String( setting.cash_time / 60)
        txt_clearOrders.text = String( setting.clearOrders_everyDays  )
        txt_clear_log.text = String( setting.clear_log_everyDays  )
  
        txt_clearPenddingOrders.text = String( setting.clearPenddingOrders_every_hour  )
 
        txt_receipt_logo_width.text = String( setting.receipt_logo_width  )
//        txt_printer_mode.text = String( setting.printer_mode  )
        txt_connection_printer_time_out.text = "\(setting.connection_printer_time_out)"
        txt_receipt_copy_number.text =  String( setting.receipt_copy_number  )
        txt_receipt_copy_number_bank.text =  String( setting.receipt_copy_number_journal_type_bank  )
        txt_qr_url.text =   setting.qr_url
 
        btn_change_time_close_old_session_to_allow_create_new_orders.setTitle(setting.time_close_old_session_to_allow_create_new_orders, for: .normal)
        scroll.delegate = self
        scroll.contentSize = CGSize.init(width: self.view.frame.width * 0.92, height: 1200)
        
        txt_tries_non_printed.text =  String( setting.tries_non_priinted_number  )


        view_force_connect_printer.isHidden = true
        txt_font_size_for_kitchen_invoice.text = String( setting.font_size_for_kitchen_invoice  )
        txt_port_connection_ip.text = String( setting.port_connection_ip  )

     }
   
    
    @IBAction func tapOnCloudKitchenSegment(_ sender: UISegmentedControl) {
        setting.enable_cloud_kitchen = enable_cloud_kitchen_option.init(rawValue: sender.selectedSegmentIndex)!
         setting.save()
    }
    //
    @IBAction func enable_sync_order_sequence_wifi(_ mySwitch: UISwitch) {
        setting.enable_sync_order_sequence_wifi = mySwitch.isOn
        setting.save()
    }
    
    @IBAction func enable_initalize_adjustment_with_zero(_ mySwitch: UISwitch) {
        setting.enable_initalize_adjustment_with_zero = mySwitch.isOn
        setting.save()
    }
    //enable_new_combo
    @IBAction func enable_new_combo(_ mySwitch: UISwitch) {
        setting.enable_new_combo = mySwitch.isOn
        setting.save()
    }
    @IBAction func show_print_last_session_dashboard(_ mySwitch: UISwitch) {
        setting.show_print_last_session_dashboard = mySwitch.isOn
        setting.save()
    }
    //enable_chosse_account_journal_for_return_order
    @IBAction func enable_chosse_account_journal_for_return_order(_ mySwitch: UISwitch) {
        setting.enable_chosse_account_journal_for_return_order = mySwitch.isOn
        setting.save()
    }
    @IBAction func enable_hide_void_before_line(_ mySwitch: UISwitch) {
        setting.enable_hide_void_before_line = mySwitch.isOn
        setting.save()
    }
    @IBAction func make_all_orders_defalut(_ mySwitch: UISwitch) {
        setting.make_all_orders_defalut = mySwitch.isOn
        setting.save()
    }
    @IBAction func enable_show_unite_price_invoice(_ mySwitch: UISwitch) {
        setting.enable_show_unite_price_invoice = mySwitch.isOn
        setting.save()
    }
    @IBAction func sw_hide_sent_to_kitchen_btn(_ mySwitch: UISwitch) {
        setting.hide_sent_to_kitchen_btn = mySwitch.isOn
        setting.save()
    }
    
    @IBAction func enable_quantity_factor_product_reports(_ mySwitch: UISwitch) {
        setting.enable_quantity_factor_product_reports = mySwitch.isOn
              
         setting.save()

    }
    @IBAction func UOM_kg(_ mySwitch: UISwitch) {
            
            setting.enable_UOM_kg = mySwitch.isOn
            
            setting.save()
        }
    @IBAction func customer_return_order(_ mySwitch: UISwitch) {
            
            setting.enable_customer_return_order = mySwitch.isOn
            
            setting.save()
        }
    @IBAction func emai_mandatory_add_customer(_ mySwitch: UISwitch) {
            
            setting.enable_email_mandatory_add_customer = mySwitch.isOn
            
            setting.save()
        }
    @IBAction func phone_mandatory_add_customer(_ mySwitch: UISwitch) {
            
            setting.enable_phone_mandatory_add_customer = mySwitch.isOn
            
            setting.save()
        }
    
    @IBAction func linkSettingWithOdoo(_ mySwitch: UISwitch) {
            
            setting.link_setting_with_odoo_2 = mySwitch.isOn
            
            setting.save()
        }
    @IBAction func show_log(_ mySwitch: UISwitch) {
            
            setting.show_log = mySwitch.isOn
            
            setting.save()
        }
    
       @IBAction func category_scroll_direction_vertical(_ mySwitch: UISwitch) {
               
         setting.category_scroll_direction_vertical = mySwitch.isOn
               
             setting.save()
    }
    
    @IBAction func auto_print_zreport(_ mySwitch: UISwitch) {
               
         setting.auto_print_zreport = mySwitch.isOn
               
          setting.save()
    }
    
       @IBAction func enable_payment(_ mySwitch: UISwitch) {
                   
             setting.enable_payment = mySwitch.isOn
                   
              setting.save()
        }
 
      @IBAction func copy_right(_ mySwitch: UISwitch) {
                      
                setting.copy_right = mySwitch.isOn
                      
                 setting.save()
           }
    //new_invocie_report
    @IBAction func new_invocie_report(_ mySwitch: UISwitch) {
                    
              setting.new_invocie_report = mySwitch.isOn
                    
               setting.save()
         }

    @IBAction func show_invocie_notes(_ mySwitch: UISwitch) {
                    
              setting.show_invocie_notes = mySwitch.isOn
                    
               setting.save()
         }
    
    @IBAction func  open_drawer_only_with_cash_payment_method(_ mySwitch: UISwitch) {
                    
              setting.open_drawer_only_with_cash_payment_method = mySwitch.isOn
                    
               setting.save()
         }
     
    @IBAction func  receipt_custom_header(_ mySwitch: UISwitch) {
                    
              setting.receipt_custom_header = mySwitch.isOn
                    
               setting.save()
         }
    
    
    
    
  
    
    
    @IBAction func  qr_enable(_ mySwitch: UISwitch) {
                    
              setting.qr_enable = mySwitch.isOn
                    
               setting.save()
         }
    
    @IBAction func force_connect_with_printer(_ mySwitch: UISwitch) {
            
      setting.force_connect_with_printer = mySwitch.isOn
            
          setting.save()
        }
    
    @IBAction func STC_productions(_ mySwitch: UISwitch) {
          
          setting.is_STC_productions = mySwitch.isOn
          
          setting.save()
      }
    
     
    
    
    @IBAction func STC_force_done(_ mySwitch: UISwitch) {
          
          setting.STC_force_done = mySwitch.isOn
          
          setting.save()
      }
    
    
    @IBAction func enable_testMode(_ mySwitch: UISwitch) {
        setting.enable_testMode = mySwitch.isOn
        setting.save()
        
    }
    
    @IBAction func enable_autoPrint(_ mySwitch: UISwitch) {
        setting.enable_autoPrint = mySwitch.isOn
        setting.save()
        
    }
    
    @IBAction func show_products_inhome(_ mySwitch: UISwitch) {
        setting.show_all_products_inHome = mySwitch.isOn
        setting.save()
        
    }
    
 
    @IBAction func  enable_draft(_ mySwitch: UISwitch) {
                    
              setting.enable_draft_mode = mySwitch.isOn
                    
               setting.save()
         }
    @IBAction func  enable_qr_for_draft_bill(_ mySwitch: UISwitch) {
                    
              setting.enable_qr_for_draft_bill = mySwitch.isOn
                    
               setting.save()
         }
    
    @IBAction func  enable_log_sync_success_orders(_ mySwitch: UISwitch) {
                    
              setting.enable_log_sync_success_orders = mySwitch.isOn
                    
               setting.save()
         }
    @IBAction func  enable_sequence_orders_over_wifi(_ mySwitch: UISwitch) {
                    
              setting.enable_sequence_orders_over_wifi = mySwitch.isOn
        
        if mySwitch.isOn
        {
            SharedManager.shared.initalMultipeerSession()
        }
        else
        {
            SharedManager.shared.disCounectMultiPeer()

        }
                    
               setting.save()
         }
    
    @IBAction func sw_enable_add_waiter_via_wifi(_ mySwitch: UISwitch) {
              setting.enable_add_waiter_via_wifi = mySwitch.isOn
               setting.save()
        MWLocalNetworking.sharedInstance.startAutoJoinOrHost()
        messages.showAlert("please restart your application to work with new feature".arabic("الرجاء إعادة تشغيل التطبيق الخاص بك للعمل مع ميزة جديدة"))
    }
    @IBAction func sw_enable_add_kds_via_wifi(_ mySwitch: UISwitch) {
              setting.enable_add_kds_via_wifi = mySwitch.isOn
               setting.save()
        MWLocalNetworking.sharedInstance.startAutoJoinOrHost()
        messages.showAlert("please restart your application to work with new feature".arabic("الرجاء إعادة تشغيل التطبيق الخاص بك للعمل مع ميزة جديدة"))
    }
    
    @IBAction func enable_auto_sent_to_kitchen(_ mySwitch: UISwitch) {
              setting.enable_auto_sent_to_kitchen = mySwitch.isOn
               setting.save()
    }
    

    
    @IBAction func  enable_simple_invoice_vat(_ mySwitch: UISwitch) {
                    
              setting.enable_simple_invoice_vat = mySwitch.isOn
                    
               setting.save()
         }
    
    
    @IBAction func  enable_multiCash(_ mySwitch: UISwitch) {
                    
              setting.enable_multi_cash = mySwitch.isOn
                    
               setting.save()
         }
    
    
    @IBAction func  enable_record_all_log(_ mySwitch: UISwitch) {
                    
              setting.enable_record_all_log = mySwitch.isOn
                    
               setting.save()
         }
    
    
    @IBAction func  enable_record_all_log_multisession(_ mySwitch: UISwitch) {
                    
              setting.enable_record_all_log_multisession = mySwitch.isOn
                    
               setting.save()
         }
    
 
    @IBAction func  show_loyalty_details_in_invoice(_ mySwitch: UISwitch) {
                    
              setting.show_loyalty_details_in_invoice = mySwitch.isOn
                    
               setting.save()
         }
    
    @IBAction func  close_session_with_closed_orders(_ mySwitch: UISwitch) {
                    
              setting.close_session_with_closed_orders = mySwitch.isOn
                    
               setting.save()
         }
    
    
    @IBAction func   show_number_of_items_in_invoice(_ mySwitch: UISwitch) {
                    
              setting.show_number_of_items_in_invoice = mySwitch.isOn
                    
               setting.save()
         }
    
    
 
 
    @IBAction func  enable_auto_accept_order_menu(_ mySwitch: UISwitch) {
                    
              setting.enable_auto_accept_order_menu = mySwitch.isOn
                    
               setting.save()
         }
    @IBAction func  enable_play_sound_order_menu(_ mySwitch: UISwitch) {
                    
              setting.enable_play_sound_order_menu = mySwitch.isOn
                    
               setting.save()
         }
 
    
    @IBAction func btnClearLog(_ sender: Any) {
        
        AppDelegate.shared.removeDataBase_data(database: "log")
        AppDelegate.shared.removeDataBase_data(database: "printer_log")

//        logDB.initDataBase()
        
        printer_message_class.show("log cleard.", vc: self)
    }
    
    @IBAction func txt_cash_end_edit(_ sender: Any) {
        let time = txt_cashTime.text ?? "0"
        var minutes = Double(time)
        
        if minutes == nil
        {
            messages.showAlert("invalid number .")
            return
        }
        
        minutes = minutes! * 60
        setting.cash_time = minutes!
         setting.save()
    }
    
    @IBAction func txt_clear_log_end_edit(_ sender: Any) {
        let time = txt_clear_log.text ?? "0"
        let days = Double(time)
        
        if days == nil
        {
            messages.showAlert("invalid number .")
            return
        }
        
 
        setting.clear_log_everyDays = days!
         setting.save()
    }
    @IBAction func txt_clear_error_log_end_edit(_ sender: Any) {
        let time = txt_clear_error_log.text ?? "0"
        let days = Double(time)
        
        if days == nil
        {
            messages.showAlert("invalid number .")
            return
        }
        
 
        setting.clear_error_log = days!
         setting.save()
    }
    @IBAction func txt_font_size_for_kitchen_invoice_end_edit(_ sender: Any) {
        let fontSizeString = txt_font_size_for_kitchen_invoice.text ?? "36"
        let fontSize = Double(fontSizeString) ?? 36
        
        if fontSize == nil || fontSize < 30 || fontSize > 70
        {
            messages.showAlert("Invalid font size as font size must be between 30 and 70  .".arabic("حجم الخط غير صالح حيث يجب أن يكون حجم الخط بين 30 و 70."))
            return
        }
        
 
        setting.font_size_for_kitchen_invoice = fontSize
         setting.save()
    }
    @IBAction func txt_port_connection_ip_edit(_ sender: Any) {
        var  portString = txt_font_size_for_kitchen_invoice.text ?? "0"
        if portString.isEmpty {
            portString = "0"
        }
        setting.port_connection_ip =  Int(portString) ?? 0
         setting.save()
    }
    
    
    @IBAction func txt_minuts_fail_report_end_edit(_ sender: Any) {
        let time = txt_minuts_fail_report.text ?? "0"
        let days = Double(time)
        
        if days == nil
        {
            messages.showAlert("invalid number .")
            return
        }
        
 
        setting.mw_minuts_fail_report = days!
         setting.save()
    }
    
    
    @IBAction func txt_timePaymentSuccessfullMessage_end_edit(_ sender: Any) {
        let time = txt_timePaymentSuccessfullMessage.text ?? "0"
        let days = Int(time)
        
        if days == nil
        {
            messages.showAlert("invalid number .")
            return
        }
        
        setting.timePaymentSuccessfullMessage = days!
       setting.save()
    }
    
    @IBAction func txt_clearOrders_end_edit(_ sender: Any) {
        let time = txt_clearOrders.text ?? "0"
        let days = Double(time)
        
        if days == nil
        {
            messages.showAlert("invalid number .")
            return
        }
        
        setting.clearOrders_everyDays = days!
       setting.save()
    }
    
    @IBAction func txt_clearPenddingOrders_end_edit(_ sender: Any) {
        let time = txt_clearPenddingOrders.text ?? "0"
        let days = Double(time)
        
        if days == nil
        {
            messages.showAlert("invalid number .")
            return
        }
        setting.clearPenddingOrders_every_hour = days!
        setting.save()
    }
    @IBAction func txt_receipt_logo_width_end_edit(_ sender: Any) {
         let time = txt_receipt_logo_width.text ?? "0"
         let days = Double(time)
        if days == nil
        {
            messages.showAlert("invalid number .")
            return
        }
        
         setting.receipt_logo_width = days!
        setting.save()
     }
    
    @IBAction func txt_connection_printer_time_out_end_edit(_ sender: Any){
        if let time_out_string = txt_connection_printer_time_out.text{
            if let mode =  Int(time_out_string){
                setting.connection_printer_time_out = mode
                setting.save()
            }else{
                messages.showAlert("invalid number .")
                return
            }
        }
    }
    @IBAction func txt_printer_mode_end_edit(_ sender: Any) {
          let mode =  Int(txt_printer_mode.text ?? "0")
        if mode == nil
        {
            messages.showAlert("invalid number .")
            return
        }
        
          setting.printer_mode = mode!
         setting.save()
      }

     @IBAction func txt_receipt_copy_number_end_edit(_ sender: Any) {
           let mode =  Int(txt_receipt_copy_number.text ?? "1")
    
        if mode == nil
        {
            messages.showAlert("invalid number .")
            return
        }
        
           setting.receipt_copy_number = mode!
          setting.save()
       }
    
    @IBAction func txt_receipt_copy_number_bank_end_edit(_ sender: Any) {
          let mode =  Int(txt_receipt_copy_number_bank.text ?? "1")
   
       if mode == nil
       {
           messages.showAlert("invalid number .")
           return
       }
       
          setting.receipt_copy_number_journal_type_bank = mode!
         setting.save()
      }
    
    @IBAction func txt_qr_url_end_edit(_ sender: Any) {
          let mode =   txt_qr_url.text
    
        setting.qr_url = mode ?? ""
         setting.save()
      }
    
    
    @IBAction func seq_changes(_ sender: Any) {
        
        
        setting.enable_OrderType = enable_OrderType_option.init(rawValue: seq_enable_payment.selectedSegmentIndex)!
         setting.save()
        
    }
    
    
    @IBAction func close_old_session_to_allow_create_new_orders(_ mySwitch: UISwitch) {
        setting.close_old_session_to_allow_create_new_orders = mySwitch.isOn
        setting.save()
        
        btn_change_time_close_old_session_to_allow_create_new_orders.isEnabled =  mySwitch.isOn
        
    }
    @IBAction func enable_show_combo_details_invoice(_ mySwitch: UISwitch) {
        setting.enable_show_combo_details_invoice = mySwitch.isOn
        setting.save()
    }
    //enable_support_multi_printer_brands
    @IBAction func enable_support_multi_printer_brands(_ mySwitch: UISwitch) {
        setting.enable_support_multi_printer_brands = mySwitch.isOn
        setting.save()
    }
    @IBAction func enable_show_discount_name_invoice(_ mySwitch: UISwitch) {
        setting.enable_show_discount_name_invoice = mySwitch.isOn
        setting.save()

    }
    @IBAction func enable_show_new_render_invoice(_ mySwitch: UISwitch) {
        setting.enable_show_new_render_invoice = mySwitch.isOn
        setting.save()
    }
    @IBAction func enable_force_longPolling_multisession(_ mySwitch: UISwitch) {
        setting.enable_force_longPolling_multisession = mySwitch.isOn
        setting.save()
        messages.showAlert("You must close app and open it again".arabic("يجب إغلاق التطبيق وفتحه مرة أخرى"))

    }
    
    @IBAction  func time_close_old_session_to_allow_create_new_orders()
    {
        let calendar = time_picker()
        calendar.minTime =  setting.time_close_old_session_to_allow_create_new_orders
        
                 calendar.modalPresentationStyle = .formSheet
                 calendar.didSelectDay = { [weak self] date in
                     
                    let time:String = String(date)
                     
                    self!.setting.time_close_old_session_to_allow_create_new_orders = time
                    self!.setting.save()
                    
                    self!.btn_change_time_close_old_session_to_allow_create_new_orders.setTitle(time, for: .normal)
 
                      calendar.dismiss(animated: true, completion: nil)
                 }
        
        
        
        self .present(calendar, animated: true, completion: nil)
    }
    
    @IBAction func tries_non_printed_number_end_edit(_ sender: Any) {
          let numer =  Int(txt_tries_non_printed.text ?? "1")
   
       if numer == nil
       {
           messages.showAlert("invalid number .")
           return
       }
       
          setting.tries_non_priinted_number = numer!
         setting.save()
      }
    @IBAction func tap_btn_staer_session_sequence_order(_ sender: KButton) {
        guard let doubleValue = sender.titleLabel?.text?.toDouble() else{return}
        show_edit_qty_popup(qty:doubleValue,key:"start_session_sequence", sender)
    }
    @IBAction func tap_btn_end_sessiion_sequence_order(_ sender: KButton) {
        guard let doubleValue = sender.titleLabel?.text?.toDouble() else{return}
        show_edit_qty_popup(qty:doubleValue,key:"end_session_sequence", sender)

    }
    @IBAction func  enable_enter_sessiion_sequence_order(_ mySwitch: UISwitch) {
                    
              setting.enable_enter_sessiion_sequence_order = mySwitch.isOn
        self.start_sequence_view.isHidden = !mySwitch.isOn
        self.end_sequence_view.isHidden = !mySwitch.isOn

               setting.save()
         }
    
    func show_edit_qty_popup(qty:Double,key:String,_ sender: UIView)
    {
        
        let storyboard = UIStoryboard(name: "dashboard", bundle: nil)
        guard let enterBalanceVC = storyboard.instantiateViewController(withIdentifier: "enterBalanceNew") as? enterBalanceNew else{return}
        enterBalanceVC.modalPresentationStyle = .popover
        
        enterBalanceVC.delegate = self
        enterBalanceVC.key = key
        if key == "start_session_sequence"{

        enterBalanceVC.title_vc =  LanguageManager.text("Enter start sequence", ar: "أدخل بدايه الترتيب ")
        }else{
            enterBalanceVC.title_vc =  LanguageManager.text("Enter end sequence", ar: "أدخل نهاية الترتيب ")
        }
        if qty != 0
        {
            enterBalanceVC.initValue  = qty.toIntString()
            
        }
        enterBalanceVC.disable = false
        
        let popover = enterBalanceVC.popoverPresentationController!
        popover.permittedArrowDirections = .up
        popover.sourceView = sender
        popover.sourceRect =  sender.bounds
        
        self.present(enterBalanceVC, animated: true, completion: nil)
    }
    func newBalance(key:String,value:String){
        guard let doubleValue = value.toDouble() else{return}
        
        if doubleValue <= 0 {
            messages.showAlert( "Sequence number must be greater than 0".arabic("يجب أن يكون رقم التسلسل أكبر من 0"))
            return
        }
       

        if key == "start_session_sequence"{
            let endValue = btn_end_sessiion_sequence_order.titleLabel?.text?.toDouble() ?? 0
            if endValue <= doubleValue {
                messages.showAlert( "Start sequence number must be less than end sequence number".arabic("يجب أن يكون رقم تسلسل البدء أقل من رقم تسلسل النهاية"))
                return
            }
//            if let max_sequence =  pos_order_class.get_max_sequence_for_active_session() {
//                if doubleValue <= Double(max_sequence) {
//                    messages.showAlert( "Start sequence number must be greater than max sequence number for session".arabic("يجب أن يكون رقم تسلسل البدء أكبر من الحد الأقصى لرقم التسلسل للجلسة"))
//                    return
//                }
//            }
            self.btn_staer_session_sequence_order.setTitle(value, for: UIControl.State.normal)
            setting.start_session_sequence_order = doubleValue
            setting.save()

        }
        
        if key == "end_session_sequence"{
            let startValue = btn_staer_session_sequence_order.titleLabel?.text?.toDouble() ?? 0
            if doubleValue <= startValue {
                messages.showAlert( "End sequence number must be greater than end sequence number".arabic("يجب أن يكون رقم تسلسل النهاية أكبر من رقم تسلسل النهاية"))
                return
            }
//            if let max_sequence =  pos_order_class.get_max_sequence_for_active_session() {
//                if doubleValue >= Double(max_sequence) {
//                    messages.showAlert( "Start sequence number must be greater than max sequence number for session".arabic("يجب أن يكون رقم تسلسل البدء أكبر من الحد الأقصى لرقم التسلسل للجلسة"))
//                    return
//                }
//            }
            self.btn_end_sessiion_sequence_order.setTitle(value, for: UIControl.State.normal)
            setting.end_sessiion_sequence_order = doubleValue
            setting.save()
        }
       

    }
    
}

extension setting_app:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scroll.contentOffset.x != 0 {
            scroll.contentOffset.x = 0
        }
    }
}
