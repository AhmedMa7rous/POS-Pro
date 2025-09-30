//
//  MWSettingAppVM.swift
//  pos
//
//  Created by M-Wageh on 09/07/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation

class MWSettingAppVM
{
    enum MWSettingAppState{
        case loading,reloadTable,show_alert(SETTING_KEY),dismissKB
    }
   private var settingSectionModel:[SettingSectionModel] = []
    private  var mwSettingConstants:MWSettingConstants?
    var updateStatusClosure: ((MWSettingAppState) -> Void)?
    var state: MWSettingAppState = .loading {
        didSet {
            self.updateStatusClosure?(state)
        }
    }
    init(){
        mwSettingConstants = MWSettingConstants()
    }
    func getAllSetting(){
        state = .loading
        DispatchQueue.global(qos: .background).async {
        let allSetting = SETTING_KEY.getSettingUI()
        SETTINGS_SECTION.getSectionsForUI().forEach { settingSection in
            var settingItems:[SettingItemModle] = allSetting.filter({$0.getSettingSection() == settingSection}).map({SettingItemModle(settingKey: $0,hintText: self.mwSettingConstants?.getSettingTitle(for: $0) ?? "")}).sorted(by: {$0.settingKey.getID() > $1.settingKey.getID()})
            self.settingSectionModel.append(SettingSectionModel(settingItems, settingSection ))
        }
            self.settingSectionModel = self.settingSectionModel.sorted(by: {$0.settingSection.getSequence() < $1.settingSection.getSequence()})
            self.state = .reloadTable

    }
        
    //        let cashSetting = SharedManager.shared.appSetting()
    //        let dbSetting = ios_settings.getAllObject()
    }
    func getSectionCount()->Int{
        return self.settingSectionModel.count
    }
    func getItemCount(at section:Int)->Int{
        return getSectionObject(for:section).settingItems.count
    }
    func getSectionObject(for section:Int) ->SettingSectionModel{
        return self.settingSectionModel[section]
    }
    func getSettingItem(at section:Int,for index:Int) -> SettingItemModle{
        return self.settingSectionModel[section].settingItems[index]
    }
    func togleSection(at section:Int){
        getSectionObject(for:section).isExpanded = !getSectionObject(for:section).isExpanded
        self.state = .reloadTable
    }
    func getIsExpanded(at section:Int) -> Bool {
        return getSectionObject(for:section).isExpanded

    }
    func togleSetting(for indexPath:IndexPath,with value:Any) -> Bool{
        let settingItem = self.getSettingItem(at: indexPath.section,for:indexPath.row)
        if !(settingItem.isValidEnableSequenceMultipeer(value as? Bool)) {
            self.state = .show_alert(.enable_sequence_orders_over_wifi)
            return false
        }
        if !(settingItem.isValidEnableSequenceMannule(value as? Bool)) {
            self.state = .show_alert(.enable_enter_sessiion_sequence_order)
            return false
        }
        if !(settingItem.isValidEnableContainousSequence(value as? Bool)) {
            self.state = .show_alert(.enable_enter_containous_sequence)
            return false
        }
        self.updateSetting(for:indexPath,with:value)
        return true
    }
    func updateSetting(for indexPath:IndexPath,with value:Any){
        let settingItem = self.getSettingItem(at: indexPath.section,for:indexPath.row)
        if settingItem.settingKey == .enable_enter_sessiion_sequence_order{
            if let value = value as? Bool{
                appenRemoveMannuleSetting(value)
            }
        }
        if settingItem.settingKey == .enable_enter_containous_sequence{
            if let value = value as? Bool{
                appenRemoveContainousSetting(value)
            }
        }
        settingItem.updateValue(with: value)
        self.state = .reloadTable
        if [SETTING_KEY.enable_add_kds_via_wifi,SETTING_KEY.force_connect_with_printer,.disable_idle_timer].contains(settingItem.settingKey){
            self.state = .show_alert(settingItem.settingKey)
        }
    }
    
    func appenRemoveMannuleSetting(_ value:Bool){
            let mannuleSeqSetting = [SETTING_KEY.end_sessiion_sequence_order,SETTING_KEY.start_session_sequence_order]
            if value {
                let mannuleSeq = mannuleSeqSetting.map({SettingItemModle(settingKey: $0,hintText: self.mwSettingConstants?.getSettingTitle(for: $0) ?? "")}).sorted(by: {$0.settingKey.getID() > $1.settingKey.getID()})
                self.settingSectionModel.first(where: {$0.settingSection == .SEQUENCE})?.settingItems.append(contentsOf:mannuleSeq )
            }else{
                self.settingSectionModel.first(where: {$0.settingSection == .SEQUENCE})?.settingItems.removeAll(where: { settingItemModle in
                   return mannuleSeqSetting.contains( settingItemModle.settingKey)
                })

            }
    }
    func appenRemoveContainousSetting(_ value:Bool){
        let mannuleSeqSetting = [SETTING_KEY.start_value_containous_sequence]
            if value {
                let mannuleSeq = mannuleSeqSetting.map({SettingItemModle(settingKey: $0,hintText: self.mwSettingConstants?.getSettingTitle(for: $0) ?? "")}).sorted(by: {$0.settingKey.getID() > $1.settingKey.getID()})
                self.settingSectionModel.first(where: {$0.settingSection == .SEQUENCE})?.settingItems.insert(contentsOf: mannuleSeq, at: 1)
                
            }else{
                self.settingSectionModel.first(where: {$0.settingSection == .SEQUENCE})?.settingItems.removeAll(where: { settingItemModle in
                   return mannuleSeqSetting.contains( settingItemModle.settingKey)
                })

            }
    }
    
}

class SettingItemModle{
    var settingKey:SETTING_KEY
    var value:Any?
    var hintText:String
    init(settingKey: SETTING_KEY,hintText:String) {
        self.settingKey = settingKey
        self.value = settingKey.getValueFromCash()
        self.hintText = hintText
    }
    func updateValue(with value:Any){
        self.value = value
       
        DispatchQueue.global(qos: .background).async {
            self.settingKey.setValueFromCash(with: value)
            SettingAppInteractor.shared.setSettingApp(for: self.settingKey.rawValue, with: "\(value)")
        }
    }
    func isValidEnableSequenceMultipeer(_ value:Bool?) -> Bool{
        if settingKey == .enable_sequence_orders_over_wifi{
            if let value = value {
                if SharedManager.shared.appSetting().enable_enter_sessiion_sequence_order{
                    return false
                }
                
                if SharedManager.shared.appSetting().enable_enter_containous_sequence{
                    return false
                }
            }
        }
        return true
    }
    func isValidEnableSequenceMannule(_ value:Bool?) -> Bool{
        if settingKey == .enable_enter_sessiion_sequence_order{
            if let value = value {
                if SharedManager.shared.appSetting().enable_sequence_orders_over_wifi{
                    return false
                }
            }
        }
        return true
    }
    func isValidEnableContainousSequence(_ value:Bool?) -> Bool{
        if settingKey == .enable_enter_containous_sequence{
            if let value = value {
                if SharedManager.shared.appSetting().enable_sequence_orders_over_wifi{
                    return false
                }
            }
        }
        return true
    }
    private func isValidFontSize(_ fontSize:Double?) -> Bool{
        if settingKey == .font_size_for_kitchen_invoice{
            if fontSize == nil || (fontSize ?? 0)  < 30 || (fontSize ?? 0) > 70
            {
                return false
            }
        }
        return true
    }
    private func isValidDuration(_ duration:Int?) -> Bool{
        if settingKey == .time_pass_to_go_lock_screen{
            if (duration == nil || (duration ?? 0)  < 30)
            {
                if let duration = duration, duration == 0{
                    return true
                }
                return false
            }
        }
        return true
    }
    private func isValidCopyNumbers(_ duration:Int?) -> Bool{
        if settingKey == .receipt_copy_number{
            if (duration ?? 0) <= 0 {
                return false
            }
        }
        return true
    }
    private func isValidSleepTime(_ duration:Double?) -> Bool{
        if settingKey == .time_sleep_print_queue{
            if (duration == nil || (duration ?? 0)  > 5)
            {
                if let duration = duration{
                    return  duration >= 0 && duration <= 5
                }
                return false
            }
        }
        return true
    }
    private func isValidStartSequence(_ sequence:Double?) -> Bool{
        if settingKey == .start_session_sequence_order{
            if sequence == nil || (sequence ?? 0)  <= 0
            {
                return false
            }
            let endSequence = SharedManager.shared.appSetting().end_sessiion_sequence_order
            if endSequence < (sequence ?? 0) {
                return false
            }
        }
        return true
    }
    private func isValidEndSequence(_ sequence:Double?) -> Bool{
        if settingKey == .end_sessiion_sequence_order{
            if sequence == nil || (sequence ?? 0)  <= 0
            {
                return false
            }
            let startSequence = SharedManager.shared.appSetting().start_session_sequence_order
            if startSequence > (sequence ?? 0) {
                return false
            }
        }
        return true
    }
    func validateValue(_ stringValue:String) -> (valid:Bool,casteValue:Any?){
        if let doubleSetting = value as? Double{
            if let doubleValue = Double(stringValue){
                if  isValidSleepTime(doubleValue) && isValidFontSize(doubleValue) && isValidStartSequence(doubleValue) && isValidEndSequence(doubleValue){
                    return (true,doubleValue)
                }
                return (false,nil)
            }else{
                return (false,nil)
            }
        }
        if let intSetting = value as? Int{
            if let intValue = Int(stringValue){
                if isValidCopyNumbers(intValue) && isValidDuration(intValue){
                    return (true,intValue)
                }
                return (false,nil)
            }else{
                return (false,nil)
            }
        }
            

            return (true,stringValue)
    }
    
}
class SettingSectionModel{
    var settingItems:[SettingItemModle]
    var settingSection:SETTINGS_SECTION
    var isExpanded:Bool = false
    init(_ settingItems: [SettingItemModle], _ settingSection: SETTINGS_SECTION) {
        self.settingItems = settingItems
        self.settingSection = settingSection
    }
    
}
enum SETTINGS_SECTION:Int,CaseIterable{
    case SEQUENCE = 0,IP_DEVICE,OPTION,CUSTOMER,MENU,BAR_CODE,PRINTER,RECEIPT,LOG,TIME
    func getSettingName()->String{
        switch self {
        case .SEQUENCE:
            return "Orders Sequence Settings".arabic("إعدادات تسلسل الطلبات")
        case .IP_DEVICE:
            return "Network connection Configration".arabic("اعدادات الاتصال بالشبكه")
        case .OPTION:
            return "General settings".arabic("إعدادات عامة")
        case .CUSTOMER:
            return "Customer settings".arabic("إعدادات العميل")
        case .MENU:
            return "Integration orders settings".arabic("إعدادات أوامر التكامل")
        case .PRINTER:
            return "Printer settings".arabic("إعدادات الطابعه")
        case .RECEIPT:
            return "Receipt settings".arabic("إعدادات الإيصال")
        case .LOG:
            return "Log settings".arabic("إعدادات السجل")
        case .TIME:
            return "Time settings".arabic("إعدادات الوقت")
        case .BAR_CODE:
            return "Barcode settings".arabic("إعدادات الباركود")

        }
        return "\(self)"
    }
    func getBKColor()->UIColor{
        if getSequence() % 2 == 0 {
            return #colorLiteral(red: 0.3254901961, green: 0.1529411765, blue: 0.5019607843, alpha: 1)
        }
        return #colorLiteral(red: 0.3254901961, green: 0.1529411765, blue: 0.5019607843, alpha: 0.8082482993)
    }
    func getTextColor()->UIColor{
//        if getSequence() % 2 == 0 {
//            return #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1) //UIColor.init(hexString: "#6A6A6A")
//        }
        return #colorLiteral(red: 0.9755851626, green: 0.9805570245, blue: 0.9890771508, alpha: 1)
        


    }
    func getSequence()->Int{
        return self.rawValue
    }
    static func getSectionsForUI() -> [SETTINGS_SECTION]{
        return [.SEQUENCE ,.OPTION,.CUSTOMER,.MENU,.BAR_CODE,.PRINTER,.RECEIPT,.LOG,.TIME]
    }
}
extension SETTING_KEY{
    static func getSettingUI()->[SETTING_KEY]{
        var filterArray = [SETTING_KEY.printer_mode,SETTING_KEY.no_retry_sent_ip,
                           SETTING_KEY.port_geidea,SETTING_KEY.terminalID_geidea,.ingenico_name
                           ,.ingenico_ip,.default_printer_name,.default_printer_ip,
                           .is_STC_productions,.STC_force_done,.new_invocie_report,
                           .enable_multi_cash,.enable_draft_mode,.enable_UOM_kg,.force_connect_with_printer,
                           .qr_enable,.enable_qr_for_draft_bill,.sales_report_filtter,.copy_right,.time_close_old_session_to_allow_create_new_orders,.enable_give_reason_for_void_sent_line,
                           .qr_url,.enable_traing_mode,.receipt_copy_number_journal_type_bank,
                           .width_invoice_to_set_new_dimensions,.enable_cloud_qr_code,.margin_invoice_left_value,
                           .use_app_return,.enable_support_multi_printer_brands,.link_setting_with_odoo_2,
                           .enable_retry_long_poll,.enable_phase2_Invoice_Offline_default,.enable_force_update_by_owner,.enable_scoket_mobile_scanner_barcode,.enable_reecod_all_ip_log,.enter_time_for_auto_send_fail_ip_message,.enter_count_page_fail_ip_message,.enable_check_duplicate_message_ids, .enable_add_kds_via_wifi,.enable_add_waiter_via_wifi,.enable_sync_order_sequence_wifi,.enable_sequence_at_master_only, .enable_resent_failure_ip_kds_order_automatic,.enable_work_with_bill_uid_default]
        if SharedManager.shared.posConfig().isMasterTCP(){
            filterArray.append(contentsOf: [SETTING_KEY.enable_sequence_at_master_only])
        }
        if SharedManager.shared.appSetting().enable_support_multi_printer_brands{
            filterArray.append(contentsOf: [SETTING_KEY.enable_support_multi_printer_brands])
        }

        if !SharedManager.shared.appSetting().enable_enter_sessiion_sequence_order{
            filterArray.append(contentsOf: [SETTING_KEY.start_session_sequence_order,SETTING_KEY.end_sessiion_sequence_order])
        }
        if !SharedManager.shared.appSetting().enable_enter_containous_sequence{
            filterArray.append(contentsOf: [SETTING_KEY.start_value_containous_sequence])
        }

        if MaintenanceInteractor.shared.activeMode() == .CAN_NOT_ACTIVE{
            filterArray.append(contentsOf: [SETTING_KEY.enable_testMode])
        }
        return SETTING_KEY.allCases.filter({ !filterArray.contains($0) })
    }
    func getSettingSection()->SETTINGS_SECTION{
        switch self {
        case .enable_check_duplicate_message_ids: return .LOG
            
        case .enter_time_for_auto_send_fail_ip_message : return .LOG;
        case .enter_count_page_fail_ip_message : return .LOG;

        case .enable_reecod_all_ip_log : return .LOG;
        case .enter_bar_code_length : return .BAR_CODE;
        case .start_value_for_bar_code : return .BAR_CODE;
        case .postion_start_id_for_bar_code : return .BAR_CODE;
        case .postion_end_id_for_bar_code : return .BAR_CODE;
        case .postion_start_qty_for_bar_code : return .BAR_CODE;
        case .postion_end_qty_for_bar_code : return .BAR_CODE;
        case .enable_move_pending_orders:
            return .OPTION
        case .enable_force_update_by_owner:
            return .OPTION
        case .enable_retry_long_poll:
            return .OPTION
        case .enable_sequence_at_master_only:
            return .IP_DEVICE
        case .enable_new_product_style:
            return .OPTION
        case .enable_local_qty_avaliblity:
            return .OPTION
        case .options_for_require_customer:
            return .OPTION
        case .enable_recieve_update_order_online:
            return .OPTION
        case .enable_zebra_scanner_barcode:
                    return .OPTION
        case .enable_check_duplicate_lines:
            return .OPTION

        case .enable_show_price_without_tax:
            return .OPTION
        case .enable_enter_containous_sequence:
            return .SEQUENCE
        case .start_value_containous_sequence:
            return .SEQUENCE
        case .enable_stop_paied_intergrate_order:
            return .MENU
        case .enable_enter_reason_void:
            return .OPTION
        case .enable_phase2_Invoice_Offline_default:
            return .RECEIPT
        case .use_app_return:
            return .OPTION
            
        case.margin_invoice_right_value:
            return .PRINTER
        case.margin_invoice_left_value:
            return .PRINTER
        case.enable_cloud_qr_code:
            return .OPTION
        case .enable_enhance_printer_cyle:
            return .PRINTER
        case .time_sleep_print_queue:
            return .PRINTER
        case .enable_work_with_bill_uid_default:
            return .SEQUENCE
        case .enable_resent_failure_ip_kds_order_automatic:
            return .IP_DEVICE
        case .enable_new_combo:
            return .OPTION
        case .printer_mode:
            return .OPTION

        case .force_connect_with_printer:
            return .PRINTER

        case .sales_report_filtter:
            return .OPTION

        case .STC_force_done:
            return .OPTION

        case .copy_right:
            return .OPTION

        case .qr_enable:
            return .OPTION

        case .receipt_copy_number:
            return .RECEIPT

        case .clear_log_everyDays:
            return .TIME

        case .qr_url:
            return .RECEIPT

        case .category_scroll_direction_vertical:
            return .OPTION

        case .receipt_custom_header:
            return .RECEIPT

        case .receipt_copy_number_journal_type_bank:
            return .RECEIPT

        case .open_drawer_only_with_cash_payment_method:
            return .OPTION

        case .receipt_logo_width:
            return .PRINTER

        case .enable_testMode:
            return .TIME

        case .new_invocie_report:
            return .RECEIPT

        case .show_log:
            return .LOG

        case .is_STC_productions:
            return .OPTION

        case .auto_print_zreport:
            return .OPTION

        case .timePaymentSuccessfullMessage:
            return .TIME

        case .cash_time:
            return .TIME

        case .enable_autoPrint:
            return .PRINTER

        case .clearPenddingOrders_everyDays:
            return .TIME

        case .show_all_products_inHome:
            return .OPTION

        case .enable_OrderType:
            return .OPTION

        case .time_close_old_session_to_allow_create_new_orders:
            return .OPTION

        case .close_old_session_to_allow_create_new_orders:
            return .OPTION

        case .enable_payment:
            return .OPTION

        case .clearOrders_everyDays:
            return .TIME

        case .show_invocie_notes:
            return .RECEIPT

        case .default_printer_name:
            return .OPTION

        case .default_printer_ip:
            return .OPTION

        case .link_setting_with_odoo_2:
            return .OPTION

        case .enable_record_all_log_multisession:
            return .LOG

        case .enable_record_all_log:
            return .LOG

        case .tries_non_priinted_number:
            return .PRINTER

        case .ingenico_name:
            return .OPTION

        case .ingenico_ip:
            return .OPTION

        case .enable_multi_cash:
            return .OPTION

        case .enable_draft_mode:
            return .OPTION

        case .enable_UOM_kg:
            return .OPTION

        case .enable_customer_return_order:
            return .CUSTOMER

        case .enable_email_mandatory_add_customer:
            return .CUSTOMER

        case .enable_phone_mandatory_add_customer:
            return .CUSTOMER

        case .mw_minuts_fail_report:
            return .PRINTER

        case .clear_error_log:
            return .LOG

        case .show_loyalty_details_in_invoice:
            return .RECEIPT

        case .show_number_of_items_in_invoice:
            return .RECEIPT

        case .close_session_with_closed_orders:
            return .OPTION

        case .enable_auto_accept_order_menu:
            return .MENU
        case .enable_play_sound_while_auto_accept_order_menu:
            return.MENU
        case .enable_play_sound_order_menu:
            return .MENU

        case .start_session_sequence_order:
            return .SEQUENCE

        case .end_sessiion_sequence_order:
            return .SEQUENCE

        case .enable_enter_sessiion_sequence_order:
            return .SEQUENCE

        case .enable_traing_mode:
            return .TIME

        case .enable_qr_for_draft_bill:
            return .RECEIPT

        case .font_size_for_kitchen_invoice:
            return .RECEIPT

        case .enable_sequence_orders_over_wifi:
            return .SEQUENCE

        case .enable_log_sync_success_orders:
            return .LOG

        case .enable_simple_invoice_vat:
            return .RECEIPT

        case .enable_auto_sent_to_kitchen:
            return .OPTION

        case .connection_printer_time_out:
            return .PRINTER

        case .enable_show_combo_details_invoice:
            return .RECEIPT

        case .terminalID_geidea:
            return .OPTION

        case .port_geidea:
            return .OPTION

        case .enable_quantity_factor_product_reports:
            return .RECEIPT

        case .enable_support_multi_printer_brands:
            return .PRINTER

        case .enable_add_kds_via_wifi:
            return .IP_DEVICE

        case .enable_cloud_kitchen:
            return .OPTION

        case .enable_force_longPolling_multisession:
            return .OPTION

        case .enable_show_discount_name_invoice:
            return .RECEIPT

        case .port_connection_ip:
            return .IP_DEVICE

        case .hide_sent_to_kitchen_btn:
            return .OPTION

        case .enable_show_unite_price_invoice:
            return .RECEIPT

        case .no_retry_sent_ip:
            return .OPTION

        case .make_all_orders_defalut:
            return .OPTION

        case .show_print_last_session_dashboard:
            return .OPTION

        case .enable_chosse_account_journal_for_return_order:
            return .OPTION

        case .enable_give_reason_for_void_sent_line:
            return .OPTION

        case .enable_hide_void_before_line:
            return .OPTION

        case .enable_initalize_adjustment_with_zero:
            return .OPTION
        case .disable_idle_timer:
            return .OPTION
        case .time_pass_to_go_lock_screen:
            return .OPTION
        case .enable_show_new_render_invoice:
            return .PRINTER
        case .enable_reconnect_with_printer_automatic:
            return .PRINTER
        case .auto_arrange_table_default:
            return .OPTION
            
        case .enable_add_waiter_via_wifi:
            return .IP_DEVICE
        case .enable_sync_order_sequence_wifi:
            return .IP_DEVICE
        case .enable_invoice_width:
            return .PRINTER
        case .width_invoice_to_set_new_dimensions:
            return .PRINTER
        case .prevent_new_order_if_empty:
            return .OPTION
            
        case .enable_make_user_resposiblity_for_order:
            return .OPTION
        case .enable_scoket_mobile_scanner_barcode : return  .OPTION
        }
        
    }
    func getValueFromCash()->Any{
        let settingCashApp = SharedManager.shared.appSetting()
        switch self{
        case .enable_check_duplicate_message_ids: return settingCashApp.enable_check_duplicate_message_ids;

        case .enter_time_for_auto_send_fail_ip_message : return settingCashApp.enter_time_for_auto_send_fail_ip_message;
        case .enter_count_page_fail_ip_message : return settingCashApp.enter_count_page_fail_ip_message;
        case .enable_reecod_all_ip_log :return settingCashApp.enable_reecod_all_ip_log

        case .enable_scoket_mobile_scanner_barcode : return settingCashApp.enable_scoket_mobile_scanner_barcode
        case .enter_bar_code_length :
            return settingCashApp.enter_bar_code_length

        case .start_value_for_bar_code :
            return settingCashApp.start_value_for_bar_code

        case .postion_start_id_for_bar_code : 
            return settingCashApp.postion_start_id_for_bar_code

        case .postion_end_id_for_bar_code : 
            return settingCashApp.postion_end_id_for_bar_code

        case .postion_start_qty_for_bar_code :
            return settingCashApp.postion_start_qty_for_bar_code

        case .postion_end_qty_for_bar_code : 
            return settingCashApp.postion_end_qty_for_bar_code

        case .enable_move_pending_orders:
            return settingCashApp.enable_move_pending_orders
        case .enable_force_update_by_owner:
            return settingCashApp.enable_force_update_by_owner
        case .enable_retry_long_poll:
            return settingCashApp.enable_retry_long_poll
        case .enable_sequence_at_master_only:
            return settingCashApp.enable_sequence_at_master_only
        case .enable_new_product_style:
            return settingCashApp.enable_new_product_style

        case .enable_local_qty_avaliblity:
            return settingCashApp.enable_local_qty_avaliblity
        case .options_for_require_customer:
            return settingCashApp.options_for_require_customer.rawValue

        case .enable_recieve_update_order_online:
            return settingCashApp.enable_recieve_update_order_online
        case .enable_zebra_scanner_barcode:
            return settingCashApp.enable_zebra_scanner_barcode
        case .enable_check_duplicate_lines:
            return settingCashApp.enable_check_duplicate_lines

        case .enable_show_price_without_tax:
            return settingCashApp.enable_show_price_without_tax

        case .enable_enter_containous_sequence:
            return settingCashApp.enable_enter_containous_sequence
        case .start_value_containous_sequence:
            return settingCashApp.start_value_containous_sequence
        case .enable_stop_paied_intergrate_order:
            return settingCashApp.enable_stop_paied_intergrate_order

        case .enable_enter_reason_void:
            return settingCashApp.enable_enter_reason_void
        case .enable_phase2_Invoice_Offline_default:
            return settingCashApp.enable_phase2_Invoice_Offline_default
        case .use_app_return:
            return settingCashApp.use_app_return

        case.margin_invoice_right_value:
            return settingCashApp.margin_invoice_right_value
        case.margin_invoice_left_value:
            return settingCashApp.margin_invoice_left_value
        case .enable_cloud_qr_code:
            return settingCashApp.enable_cloud_qr_code
        case .enable_enhance_printer_cyle:
            return settingCashApp.enable_enhance_printer_cyle
        case .time_sleep_print_queue:
            return settingCashApp.time_sleep_print_queue
        case .enable_work_with_bill_uid_default:
            return settingCashApp.enable_work_with_bill_uid_default
        case .enable_reconnect_with_printer_automatic:
            return settingCashApp.enable_reconnect_with_printer_automatic

        case .enable_resent_failure_ip_kds_order_automatic:
            return settingCashApp.enable_resent_failure_ip_kds_order_automatic
        case .enable_new_combo:
            return settingCashApp.enable_new_combo
        case .printer_mode:
            return settingCashApp.printer_mode
        case .sales_report_filtter:
            return settingCashApp.sales_report_filtter

        case .force_connect_with_printer:
            return settingCashApp.force_connect_with_printer

        case .STC_force_done:
            return settingCashApp.STC_force_done

        case .copy_right:
            return settingCashApp.copy_right

        case .qr_enable:
            return settingCashApp.qr_enable

        case .receipt_copy_number:
            return settingCashApp.receipt_copy_number
        case .clear_log_everyDays:
            return settingCashApp.clear_log_everyDays
        case .qr_url:
            return settingCashApp.qr_url
        case .category_scroll_direction_vertical:
            return settingCashApp.category_scroll_direction_vertical
        case .receipt_custom_header:
            return settingCashApp.receipt_custom_header
        case .receipt_copy_number_journal_type_bank:
            return settingCashApp.receipt_copy_number_journal_type_bank
        case .open_drawer_only_with_cash_payment_method:
            return settingCashApp.open_drawer_only_with_cash_payment_method
        case .receipt_logo_width:
            return settingCashApp.receipt_logo_width
        case .enable_testMode:
            return settingCashApp.enable_testMode
        case .new_invocie_report:
            return settingCashApp.new_invocie_report
        case .show_log:
            return settingCashApp.show_log
        case .is_STC_productions:
            return settingCashApp.is_STC_productions
        case .auto_print_zreport:
            return settingCashApp.auto_print_zreport
        case .timePaymentSuccessfullMessage:
            return settingCashApp.timePaymentSuccessfullMessage
        case .cash_time:
            return settingCashApp.cash_time
        case .enable_autoPrint:
            return settingCashApp.enable_autoPrint
        case .clearPenddingOrders_everyDays:
            return settingCashApp.clearPenddingOrders_every_hour
        case .show_all_products_inHome:
            return settingCashApp.show_all_products_inHome
        case .enable_OrderType:
            return settingCashApp.enable_OrderType.rawValue
        case .time_close_old_session_to_allow_create_new_orders:
            return settingCashApp.time_close_old_session_to_allow_create_new_orders
        case .close_old_session_to_allow_create_new_orders:
            return settingCashApp.close_old_session_to_allow_create_new_orders
        case .enable_payment:
            return settingCashApp.enable_payment
        case .clearOrders_everyDays:
            return settingCashApp.clearOrders_everyDays
        case .show_invocie_notes:
            return settingCashApp.show_invocie_notes
        case .default_printer_name:
            return ""
        case .default_printer_ip:
            return ""
        case .link_setting_with_odoo_2:
            return settingCashApp.link_setting_with_odoo_2
        case .enable_record_all_log_multisession:
            return settingCashApp.enable_record_all_log_multisession
        case .enable_record_all_log:
            return settingCashApp.enable_record_all_log
        case .tries_non_priinted_number:
            return settingCashApp.tries_non_priinted_number
        case .ingenico_name:
            return settingCashApp.ingenico_name
        case .ingenico_ip:
            return settingCashApp.ingenico_ip
        case .enable_multi_cash:
            return settingCashApp.enable_multi_cash
        case .enable_draft_mode:
            return settingCashApp.enable_draft_mode
        case .enable_UOM_kg:
            return settingCashApp.enable_UOM_kg
        case .enable_customer_return_order:
            return settingCashApp.enable_customer_return_order
        case .enable_email_mandatory_add_customer:
            return settingCashApp.enable_email_mandatory_add_customer
        case .enable_phone_mandatory_add_customer:
            return settingCashApp.enable_phone_mandatory_add_customer
        case .mw_minuts_fail_report:
            return settingCashApp.mw_minuts_fail_report
        case .clear_error_log:
            return settingCashApp.clear_error_log
        case .show_loyalty_details_in_invoice:
            return settingCashApp.show_loyalty_details_in_invoice
        case .show_number_of_items_in_invoice:
            return settingCashApp.show_number_of_items_in_invoice
        case .close_session_with_closed_orders:
            return settingCashApp.close_session_with_closed_orders
        case .enable_auto_accept_order_menu:
            return settingCashApp.enable_auto_accept_order_menu
        case .enable_play_sound_while_auto_accept_order_menu:
            return settingCashApp.enable_play_sound_while_auto_accept_order_menu
        case .enable_play_sound_order_menu:
            return settingCashApp.enable_play_sound_order_menu
        case .start_session_sequence_order:
            return settingCashApp.start_session_sequence_order
        case .end_sessiion_sequence_order:
            return settingCashApp.end_sessiion_sequence_order
        case .enable_enter_sessiion_sequence_order:
            return settingCashApp.enable_enter_sessiion_sequence_order
        case .enable_traing_mode:
            return settingCashApp.enable_traing_mode
        case .enable_qr_for_draft_bill:
            return settingCashApp.enable_qr_for_draft_bill
        case .font_size_for_kitchen_invoice:
            return settingCashApp.font_size_for_kitchen_invoice
        case .enable_sequence_orders_over_wifi:
            return settingCashApp.enable_sequence_orders_over_wifi
        case .enable_log_sync_success_orders:
            return settingCashApp.enable_log_sync_success_orders
        case .enable_simple_invoice_vat:
            return settingCashApp.enable_simple_invoice_vat
        case .enable_auto_sent_to_kitchen:
            return settingCashApp.enable_auto_sent_to_kitchen
        case .connection_printer_time_out:
            return settingCashApp.connection_printer_time_out
        case .enable_show_combo_details_invoice:
            return settingCashApp.enable_show_combo_details_invoice
        case .terminalID_geidea:
            return settingCashApp.terminalID_geidea
        case .port_geidea:
            return settingCashApp.port_geidea
        case .enable_quantity_factor_product_reports:
            return settingCashApp.enable_quantity_factor_product_reports
        case .enable_support_multi_printer_brands:
            return settingCashApp.enable_support_multi_printer_brands
        case .enable_add_kds_via_wifi:
            return settingCashApp.enable_add_kds_via_wifi
        case .enable_cloud_kitchen:
            return settingCashApp.enable_cloud_kitchen.rawValue
        case .enable_force_longPolling_multisession:
            return settingCashApp.enable_force_longPolling_multisession
        case .enable_show_discount_name_invoice:
            return settingCashApp.enable_show_discount_name_invoice
        case .port_connection_ip:
            return settingCashApp.port_connection_ip
        case .hide_sent_to_kitchen_btn:
            return settingCashApp.hide_sent_to_kitchen_btn
        case .enable_show_unite_price_invoice:
            return settingCashApp.enable_show_unite_price_invoice
        case .no_retry_sent_ip:
            return settingCashApp.no_retry_sent_ip
        case .make_all_orders_defalut:
            return settingCashApp.make_all_orders_defalut
        case .show_print_last_session_dashboard:
            return settingCashApp.show_print_last_session_dashboard
        case .enable_chosse_account_journal_for_return_order:
            return settingCashApp.enable_chosse_account_journal_for_return_order
        case .enable_give_reason_for_void_sent_line:
            return settingCashApp.enable_give_reason_for_void_sent_line
        case .enable_hide_void_before_line:
            return settingCashApp.enable_hide_void_before_line
        case .enable_initalize_adjustment_with_zero:
            return settingCashApp.enable_initalize_adjustment_with_zero
        case .disable_idle_timer:
            return settingCashApp.disable_idle_timer
        case .time_pass_to_go_lock_screen:
            return settingCashApp.time_pass_to_go_lock_screen
        case .enable_show_new_render_invoice:
            return settingCashApp.enable_show_new_render_invoice
        case .enable_add_waiter_via_wifi:
            return settingCashApp.enable_add_waiter_via_wifi
        case .enable_sync_order_sequence_wifi:
            return settingCashApp.enable_sync_order_sequence_wifi
        case .auto_arrange_table_default:
            return settingCashApp.auto_arrange_table_default
        case .enable_invoice_width:
            return settingCashApp.enable_invoice_width
        case .width_invoice_to_set_new_dimensions:
            return settingCashApp.width_invoice_to_set_new_dimensions
        case .prevent_new_order_if_empty:
            return settingCashApp.prevent_new_order_if_empty
            
        case .enable_make_user_resposiblity_for_order:
            return settingCashApp.enable_make_user_resposiblity_for_order
        }
    }
    func setValueFromCash(with value:Any){
        let settingCashApp = SharedManager.shared.appSetting()
        switch self{
        case .enable_check_duplicate_message_ids :
            settingCashApp.enable_check_duplicate_message_ids = value as? Bool ?? true

        case .enter_time_for_auto_send_fail_ip_message :
            settingCashApp.enter_time_for_auto_send_fail_ip_message = value as? Double ?? 5.0
        case .enter_count_page_fail_ip_message :
            settingCashApp.enter_count_page_fail_ip_message = value as? Int ?? 5
        case .enable_reecod_all_ip_log :
            settingCashApp.enable_reecod_all_ip_log = value as? Bool ?? false

        case .enable_scoket_mobile_scanner_barcode :
            settingCashApp.enable_scoket_mobile_scanner_barcode = value as? Bool ?? false
        case .enter_bar_code_length :
            settingCashApp.enter_bar_code_length = value as? Int ?? 13

        case .start_value_for_bar_code : 
            settingCashApp.start_value_for_bar_code = value as? Int ?? 9

        case .postion_start_id_for_bar_code : 
            settingCashApp.postion_start_id_for_bar_code = value as? Int ?? 3

        case .postion_end_id_for_bar_code : 
            settingCashApp.postion_end_id_for_bar_code = value as? Int ?? 7

        case .postion_start_qty_for_bar_code : 
            settingCashApp.postion_start_qty_for_bar_code = value as? Int ?? 8

        case .postion_end_qty_for_bar_code : 
            settingCashApp.postion_end_qty_for_bar_code = value as? Int ?? 14

            
        case .enable_move_pending_orders:
            settingCashApp.enable_move_pending_orders = value as? Bool ?? false
        case .enable_force_update_by_owner:
            settingCashApp.enable_force_update_by_owner = value as? Bool ?? false
        case .enable_retry_long_poll:
            settingCashApp.enable_retry_long_poll = value as? Bool ?? false
        case .enable_sequence_at_master_only:
            settingCashApp.enable_sequence_at_master_only = value as? Bool ?? false
        case .enable_new_product_style:
            settingCashApp.enable_new_product_style = value as? Bool ?? false
        case .enable_local_qty_avaliblity:
            settingCashApp.enable_local_qty_avaliblity = value as? Bool ?? false
        case .options_for_require_customer:
             settingCashApp.options_for_require_customer  = options_for_require_customer_enum(rawValue: value as? Int ?? 0) ?? .REQUIRE

        case .enable_recieve_update_order_online:
            return settingCashApp.enable_recieve_update_order_online = value as? Bool ?? false
        case .enable_zebra_scanner_barcode:
            settingCashApp.enable_zebra_scanner_barcode = value as? Bool ?? false
            
        case .enable_check_duplicate_lines:
            settingCashApp.enable_check_duplicate_lines = value as? Bool ?? false
        case .enable_show_price_without_tax:
            settingCashApp.enable_show_price_without_tax = value as? Bool ?? false

        case .enable_enter_containous_sequence:
            settingCashApp.enable_enter_containous_sequence = value as? Bool ?? false
        case .start_value_containous_sequence:
            settingCashApp.start_value_containous_sequence = value as? Int ?? 0
        case .enable_stop_paied_intergrate_order:
            settingCashApp.enable_stop_paied_intergrate_order = value as? Bool ?? false

        case .enable_enter_reason_void:
            settingCashApp.enable_enter_reason_void = value as? Bool ?? false
        case.enable_phase2_Invoice_Offline_default:
            settingCashApp.enable_phase2_Invoice_Offline_default = value as? Bool ?? false
        case .use_app_return:
            settingCashApp.use_app_return = value as? Bool ?? false
        case.margin_invoice_right_value:
             settingCashApp.margin_invoice_right_value  = value as? Double ?? 0.0
        case.margin_invoice_left_value:
             settingCashApp.margin_invoice_left_value  = value as? Double ?? 0.0
        case .enable_cloud_qr_code:
            settingCashApp.enable_cloud_qr_code = value as? Bool ?? false
        case .enable_enhance_printer_cyle:
            settingCashApp.enable_enhance_printer_cyle = value as? Bool ?? false
        case .time_sleep_print_queue:
            settingCashApp.time_sleep_print_queue = value as? Double ?? 0.0
        case .enable_work_with_bill_uid_default:
            settingCashApp.enable_work_with_bill_uid_default = value as? Bool ?? false
        case .enable_reconnect_with_printer_automatic:
            settingCashApp.enable_reconnect_with_printer_automatic = value as? Bool ?? false
        case .enable_resent_failure_ip_kds_order_automatic:
            settingCashApp.enable_resent_failure_ip_kds_order_automatic = value as? Bool ?? false
        case .enable_new_combo:
            settingCashApp.enable_new_combo = value as? Bool ?? false
        case .printer_mode:
             settingCashApp.printer_mode = value as? Int ?? 0
        case .sales_report_filtter:
            settingCashApp.sales_report_filtter = value as? String ?? ""
        case .force_connect_with_printer:
             settingCashApp.force_connect_with_printer = value as? Bool ?? false
        case .STC_force_done:
             settingCashApp.STC_force_done = value as?  Bool ?? false
        case .copy_right:
             settingCashApp.copy_right = value as?  Bool ?? false

        case .qr_enable:
             settingCashApp.qr_enable = value as? Bool ?? false

        case .receipt_copy_number:
             settingCashApp.receipt_copy_number = value as? Int ?? 1
        case .clear_log_everyDays:
             settingCashApp.clear_log_everyDays = value as? Double ?? 0
        case .qr_url:
             settingCashApp.qr_url = value as? String ?? ""
        case .category_scroll_direction_vertical:
             settingCashApp.category_scroll_direction_vertical = value as?  Bool ?? false
        case .receipt_custom_header:
             settingCashApp.receipt_custom_header = value as? Bool ?? false
        case .receipt_copy_number_journal_type_bank:
             settingCashApp.receipt_copy_number_journal_type_bank = value as? Int ?? 0
        case .open_drawer_only_with_cash_payment_method:
             settingCashApp.open_drawer_only_with_cash_payment_method = value as?  Bool ?? false
        case .receipt_logo_width:
             settingCashApp.receipt_logo_width = value as? Double ?? 0
        case .enable_testMode:
             settingCashApp.enable_testMode = value as?  Bool ?? false
        case .new_invocie_report:
             settingCashApp.new_invocie_report = value as?  Bool ?? false
        case .show_log:
             settingCashApp.show_log = value as?  Bool ?? false
        case .is_STC_productions:
             settingCashApp.is_STC_productions = value as? Bool ?? false
        case .auto_print_zreport:
             settingCashApp.auto_print_zreport = value as? Bool ?? false
        case .timePaymentSuccessfullMessage:
             settingCashApp.timePaymentSuccessfullMessage = value as? Int ?? 0
        case .cash_time:
             settingCashApp.cash_time = value as? Double ?? 0
        case .enable_autoPrint:
             settingCashApp.enable_autoPrint = value as? Bool ?? false
        case .clearPenddingOrders_everyDays:
             settingCashApp.clearPenddingOrders_every_hour = value as? Double ?? 0
        case .show_all_products_inHome:
             settingCashApp.show_all_products_inHome = value as? Bool ?? false
        case .enable_OrderType:
             settingCashApp.enable_OrderType  = enable_OrderType_option(rawValue: value as? Int ?? 0) ?? .InPayment
        case .time_close_old_session_to_allow_create_new_orders:
             settingCashApp.time_close_old_session_to_allow_create_new_orders = value as? String ?? ""
        case .close_old_session_to_allow_create_new_orders:
             settingCashApp.close_old_session_to_allow_create_new_orders = value as? Bool ?? false
        case .enable_payment:
             settingCashApp.enable_payment = value as? Bool ?? false
        case .clearOrders_everyDays:
             settingCashApp.clearOrders_everyDays = value as? Double ?? 0
        case .show_invocie_notes:
             settingCashApp.show_invocie_notes = value as? Bool ?? false
        case .default_printer_name:
            cash_data_class.set(key: "setting_name", value: value as? String ?? "")

        case .default_printer_ip:
            cash_data_class.set(key: "setting_ip", value: ((value as? String ?? "").replacingOccurrences(of: "TCP:", with: "") ?? ""))
        case .link_setting_with_odoo_2:
             settingCashApp.link_setting_with_odoo_2 = value as? Bool ?? false
        case .enable_record_all_log_multisession:
             settingCashApp.enable_record_all_log_multisession = value as? Bool ?? false
        case .enable_record_all_log:
             settingCashApp.enable_record_all_log = value as? Bool ?? false
        case .tries_non_priinted_number:
             settingCashApp.tries_non_priinted_number = value as? Int ?? 0
        case .ingenico_name:
             settingCashApp.ingenico_name = value as? String ?? ""
        case .ingenico_ip:
             settingCashApp.ingenico_ip = value as? String ?? ""
        case .enable_multi_cash:
             settingCashApp.enable_multi_cash = value as? Bool ?? false
        case .enable_draft_mode:
             settingCashApp.enable_draft_mode = value as? Bool ?? false
        case .enable_UOM_kg:
            settingCashApp.enable_UOM_kg = value as? Bool ?? false
        case .enable_customer_return_order:
            settingCashApp.enable_customer_return_order = value as? Bool ?? false
        case .enable_email_mandatory_add_customer:
            settingCashApp.enable_email_mandatory_add_customer = value as? Bool ?? false
        case .enable_phone_mandatory_add_customer:
            settingCashApp.enable_phone_mandatory_add_customer = value as? Bool ?? false
        case .mw_minuts_fail_report:
            settingCashApp.mw_minuts_fail_report = value as? Double ?? 0
        case .clear_error_log:
            settingCashApp.clear_error_log = value as? Double ?? 0
        case .show_loyalty_details_in_invoice:
            settingCashApp.show_loyalty_details_in_invoice = value as? Bool ?? false
        case .show_number_of_items_in_invoice:
            settingCashApp.show_number_of_items_in_invoice = value as? Bool ?? false
        case .close_session_with_closed_orders:
            settingCashApp.close_session_with_closed_orders = value as? Bool ?? false
        case .enable_auto_accept_order_menu:
             settingCashApp.enable_auto_accept_order_menu = value as? Bool ?? false
        case .enable_play_sound_while_auto_accept_order_menu:
             settingCashApp.enable_play_sound_while_auto_accept_order_menu = value as? Bool ?? false
        case .enable_play_sound_order_menu:
             settingCashApp.enable_play_sound_order_menu = value as? Bool ?? false
        case .start_session_sequence_order:
             settingCashApp.start_session_sequence_order = value as? Double ?? 0
        case .end_sessiion_sequence_order:
             settingCashApp.end_sessiion_sequence_order = value as? Double ?? 0
        case .enable_enter_sessiion_sequence_order:
             settingCashApp.enable_enter_sessiion_sequence_order = value as? Bool ?? false
        case .enable_traing_mode:
             settingCashApp.enable_traing_mode = value as? Bool ?? false
        case .enable_qr_for_draft_bill:
             settingCashApp.enable_qr_for_draft_bill = value as? Bool ?? false
        case .font_size_for_kitchen_invoice:
             settingCashApp.font_size_for_kitchen_invoice = value as? Double ?? 0
        case .enable_sequence_orders_over_wifi:
             settingCashApp.enable_sequence_orders_over_wifi = value as? Bool ?? false
        case .enable_log_sync_success_orders:
             settingCashApp.enable_log_sync_success_orders = value as? Bool ?? false
        case .enable_simple_invoice_vat:
             settingCashApp.enable_simple_invoice_vat = value as? Bool ?? false
        case .enable_auto_sent_to_kitchen:
             settingCashApp.enable_auto_sent_to_kitchen = value as? Bool ?? false
        case .connection_printer_time_out:
             settingCashApp.connection_printer_time_out = value as? Int ?? 0
        case .enable_show_combo_details_invoice:
             settingCashApp.enable_show_combo_details_invoice = value as? Bool ?? false
        case .terminalID_geidea:
             settingCashApp.terminalID_geidea = value as? String ?? ""
        case .port_geidea:
             settingCashApp.port_geidea = value as? Int ?? 9090
        case .enable_quantity_factor_product_reports:
            settingCashApp.enable_quantity_factor_product_reports = value as? Bool ?? false
        case .enable_support_multi_printer_brands:
            settingCashApp.enable_support_multi_printer_brands = value as? Bool ?? false
        case .enable_add_kds_via_wifi:
            settingCashApp.enable_add_kds_via_wifi = value as? Bool ?? false
        case .enable_cloud_kitchen:
            settingCashApp.enable_cloud_kitchen = enable_cloud_kitchen_option(rawValue:  value as? Int ?? 0) ?? .DISABLE
        case .enable_force_longPolling_multisession:
            settingCashApp.enable_force_longPolling_multisession = value as? Bool ?? false
        case .enable_show_discount_name_invoice:
            settingCashApp.enable_show_discount_name_invoice = value as? Bool ?? false
        case .port_connection_ip:
            settingCashApp.port_connection_ip = value as? Int ?? 9090
        case .hide_sent_to_kitchen_btn:
            settingCashApp.hide_sent_to_kitchen_btn = value as? Bool ?? false
        case .enable_show_unite_price_invoice:
            settingCashApp.enable_show_unite_price_invoice = value as? Bool ?? false
        case .no_retry_sent_ip:
            settingCashApp.no_retry_sent_ip = value as? Int ?? 0
        case .make_all_orders_defalut:
            settingCashApp.make_all_orders_defalut = value as? Bool ?? false
        case .show_print_last_session_dashboard:
            settingCashApp.show_print_last_session_dashboard = value as? Bool ?? false
        case .enable_chosse_account_journal_for_return_order:
             settingCashApp.enable_chosse_account_journal_for_return_order = value as? Bool ?? false
        case .enable_give_reason_for_void_sent_line:
            settingCashApp.enable_give_reason_for_void_sent_line = value as? Bool ?? false
        case .enable_hide_void_before_line:
             settingCashApp.enable_hide_void_before_line = value as? Bool ?? false
        case .enable_initalize_adjustment_with_zero:
             settingCashApp.enable_initalize_adjustment_with_zero = value as? Bool ?? false
        case .disable_idle_timer:
            settingCashApp.disable_idle_timer = value as? Bool ?? false
        case .time_pass_to_go_lock_screen:
            settingCashApp.time_pass_to_go_lock_screen = value as? Int ?? 0
        case .enable_show_new_render_invoice:
            settingCashApp.enable_show_new_render_invoice = value as? Bool ?? false
        case .enable_add_waiter_via_wifi:
             settingCashApp.enable_add_waiter_via_wifi = value as? Bool ?? false
        case .enable_sync_order_sequence_wifi:
            settingCashApp.enable_sync_order_sequence_wifi = value as? Bool ?? false
        case .auto_arrange_table_default:
            settingCashApp.auto_arrange_table_default = value as? Bool ?? false
        case .enable_invoice_width:
            settingCashApp.enable_invoice_width = value as? Bool ?? false
        case .width_invoice_to_set_new_dimensions:
            settingCashApp.width_invoice_to_set_new_dimensions = value as? String ?? ""
        case .prevent_new_order_if_empty:
            settingCashApp.prevent_new_order_if_empty = value as? Bool ?? false
            
        case .enable_make_user_resposiblity_for_order:
            settingCashApp.enable_make_user_resposiblity_for_order = value as? Bool ?? false
        }
        settingCashApp.save()
    }
//    func getSettingTitle()->String{
//        return "\(self)"
//    }
    func getBKColor()->UIColor{
        if getID() % 2 == 0 {
            return #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        }
        return #colorLiteral(red: 0.8431373239, green: 0.8431373239, blue: 0.8431373239, alpha: 1)
    }
    func getTextColor()->UIColor{
        if getID() % 2 == 0 {
            return #colorLiteral(red: 0.9755851626, green: 0.9805570245, blue: 0.9890771508, alpha: 1)
        }
        return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
}


