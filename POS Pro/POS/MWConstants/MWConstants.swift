//
//  MWConstants.swift
//  pos
//
//  Created by M-Wageh on 12/09/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
class MWConstants {
    static var cancel_products_title: String{
        get{
            return "Void before".arabic("حذفت قبل")
        }
    }  //"Void Products before sent to kitchen".arabic("المنتجات المحذوفة قبل ارسالها للمطبخ")//" Void products "
    static var void_products_title  : String{
        get{
            return  "Void after".arabic("حذفت بعد")  }
    }//"Void Products after sent to kitchen".arabic("المنتجات المحذوفة بعد ارسالها للمطبخ")//"Cancelled products"
    static var cancel_products_dec : String{
        get{
            return "Void Products before sent to kitchen".arabic("المنتجات المحذوفة قبل ارسالها للمطبخ")
        }
    }//" Void products "
    static var void_products_desc : String{
        get{
            return "Void Products after sent to kitchen".arabic("المنتجات المحذوفة بعد ارسالها للمطبخ")
        }
    }//"Cancelled products"
    static var scrap_product_title : String{
        get{
            return "Products Waste".arabic("التوالف")
        }
    }
    static var scrap_title: String{
        get{
            return "Waste".arabic("فاقد")
        }
    }
    static var service_charge: String{
        get{
            return "Service Charge w/o".arabic("تكلفة الخدمة بدون ضريبة")
        }
    }
    static var delivery_w_o_tax: String{
        get{
            return "Delivery w/o".arabic("التوصيل بدون ضريبة")
        }
    }
    static var discount_w_o_tax: String{
        get{
            return "Discount w/o".arabic("الخصم بدون ضريبة")
        }
    }
    static var return_products_title: String{
        get{
            return "Return products".arabic("مرتجعات المنتجات")
        }
    }
    static var return_insurance_title: String{
        get{
            return "Return insurances".arabic("مرتجعات التأمينات")
        }
    }
    static var generate_qr_phase_1: String{
        get{
            return "GENERATE_QR_BY_PHASE_1"
        }
    }
    static var alert_close_time: String{
        get{
            let time = SharedManager.shared.appSetting().time_close_old_session_to_allow_create_new_orders
            return "Please close the current session because according to the settings it must be closed after \(time). Please close the session and open a new session".arabic("بجب اغلاق جلسه نقطه البيع الحاليه لان بناءا علي اعدادات النظام يجب اغلاق بعد الساعه \(time) برجاء اغلاق الجلسه و تسجيل جلسه جديده")
        }
    }
    static func alert_pending_order(_ pendingOrders:[Int]) -> String{
        let orderNumbers = "[" + pendingOrders.map({"\($0)"}).joined(separator: ", ")+"]"
            return "All pending orders must be closed before the current session is closed according to the system settings. Pending orders number \(orderNumbers)".arabic("يجب اغلاق كل الطلبات المعلقه قبل اغلاق الجلسه الحاليه بناءا علي الاعدادات النطام وهي \(orderNumbers)   ")
    }
    /**
     
     ( sum( pos_order_account_journal.due) - sum( pos_order_account_journal.rest) ) as total
     */
    static let selectTotalStatmentQry:String = """
        ((SUM(pos_order_account_journal.due)) - (SUM(CASE
            WHEN pos_order_account_journal.due < 0 THEN (pos_order_account_journal.rest * -1)
            ELSE pos_order_account_journal.rest
        END))
        ) AS total
"""

}
class MWSettingConstants {
    private var  settingDic:[String:Any] = [
        "enable_add_kds_via_wifi": [
          "txt_lbl_en": "Enable add KDS via WIFI",
          "txt_lbl_ar": "تفعيل إضافة KDS عبر WIFI"
        ],
        "enable_sequence_orders_over_wifi": [
          "txt_lbl_en": "Enable sequence orders over wifi",
          "txt_lbl_ar": "تفعيل  ترقيم الطلبات عبر wifi"
        ],
        "enable_enter_sessiion_sequence_order": [
          "txt_lbl_en": " Enable enter session Sequence Orders numbers",
          "txt_lbl_ar": " تفعيل إدخال أرقام طلبات تسلسل الجلسة"
        ],
        "start_session_sequence_order": [
          "txt_lbl_en": "Start orders sequence from",
          "txt_lbl_ar": "بدء تسلسل الطالبات من"
        ],
        "end_sessiion_sequence_order": [
          "txt_lbl_en": "End orders sequence with",
          "txt_lbl_ar": "إنهاء تسلسل الطالبات بـ"
        ],
        "Optional": [ "txt_lbl_en": "Optional", "txt_lbl_ar": "" ],
        "enable_OrderType": [
          "txt_lbl_en": "Enable order type with",
          "txt_lbl_ar": "تفعيل انواع الطلب مع"
        ],
        "enable_payment": [
          "txt_lbl_en": "Enable payment",
          "txt_lbl_ar": "تفعيل الدفع"
        ],
        "show_all_products_inHome": [
          "txt_lbl_en": "Show products in home",
          "txt_lbl_ar": "إظهار المنتجات في الصفحة الرئيسية"
        ],
        "STC_force_done": [ "txt_lbl_en": "STC products", "txt_lbl_ar": "STC منتجات" ],
        "is_STC_productions": [
          "txt_lbl_en": "STC force done",
          "txt_lbl_ar": "STC force done"
        ],
        "category_scroll_direction_vertical": [
          "txt_lbl_en": "Category scroll direction vertical",
          "txt_lbl_ar": "عرض الفئات بطريقة افقية"
        ],
        "auto_arrange_table_default": [
          "txt_lbl_en": "Auto arrange tables",
          "txt_lbl_ar": "ترتيب الطاولات تلقائيا"
        ],
        "close_old_session_to_allow_create_new_orders": [
          "txt_lbl_en": "close old session to allow create New orders",
          "txt_lbl_ar": "تفعيل وتحديد وقت لإغلاق الجلسه"
        ],
        "Powered by DGTERA": [ "txt_lbl_en": "Powered by DGTERA", "txt_lbl_ar": "Powered by DGTERA" ],
        "new_invocie_report": [ "txt_lbl_en": "New Invoice Report", "txt_lbl_ar": "New Invoice Report" ],
        "show_invocie_notes": [
          "txt_lbl_en": "Show invoice Note",
          "txt_lbl_ar": "اظهار الملاحظات في الفاتورة"
        ],
        "link_setting_with_odoo_2": [
          "txt_lbl_en": "Link setting with odoo",
          "txt_lbl_ar": "ربط الاعدادات مع الاودو"
        ],
        "enable_multi_cash": [
          "txt_lbl_en": "Enable multi Cash",
          "txt_lbl_ar": "تفعيل الدفع كاش مرات عديده"
        ],
        "enable_draft_mode": [
          "txt_lbl_en": "Enable Draft invoice",
          "txt_lbl_ar": "تفعيل الدرافت للفاتوره"
        ],
        "enable_UOM_kg": [
          "txt_lbl_en": "Enable unit of measure of quantity by Kg",
          "txt_lbl_ar": "تفعيل وحدة قياس الكمية بالكيلو جرام"
        ],
        "enable_customer_return_order": [
          "txt_lbl_en": "Enable choose customer for returned order",
          "txt_lbl_ar": "تفعيل اختيار العميل للطلب المرتجع"
        ],
        "show_loyalty_details_in_invoice": [
          "txt_lbl_en": "Show loyalty details in invoice",
          "txt_lbl_ar": "إظهار تفاصيل النقاط في الفاتورة"
        ],
        "show_number_of_items_in_invoice": [
          "txt_lbl_en": "show number of items in invoice",
          "txt_lbl_ar": "إظهار عدد الاصناف في الفاتورة"
        ],
        "close_session_with_closed_orders": [
          "txt_lbl_en": "close session with closed orders",
          "txt_lbl_ar": "اغلاق الجلسه مع اغلاق الطلبات"
        ],
        "enable_cloud_kitchen": [
          "txt_lbl_en": "Enable cloud kitchen with",
          "txt_lbl_ar": "تفعيل المطبخ السحابي مع"
        ],
        "enable_force_longPolling_multisession": [
          "txt_lbl_en": "Enable Force Long Polling for Multisession",
          "txt_lbl_ar": "تفعيل فرض الاقتراع الطويل للجلسات المتعددة"
        ],
        "port_connection_ip": [
          "txt_lbl_en": "Port ip connection",
          "txt_lbl_ar": "Port ip connection"
        ],
        "enable_auto_sent_to_kitchen": [
          "txt_lbl_en": "Enable auto sent to kitchen",
          "txt_lbl_ar": "تفعيل الإرسال التلقائي إلى المطبخ"
        ],
        "hide_sent_to_kitchen_btn": [
          "txt_lbl_en": "Hide sent to kitchen button",
          "txt_lbl_ar": "اخفاء الارسال للمطبخ"
        ],
        "make_all_orders_defalut": [
          "txt_lbl_en": "Make all orders tab selected by default",
          "txt_lbl_ar": "اجعل علامة تبويب جميع الطلبات محددة بشكل افتراضي"
        ],
        "enable_hide_void_before_line": [
          "txt_lbl_en": "Enable hide deleted product before sent to kitchen",
          "txt_lbl_ar": "تفعيل إخفاء المنتج المحذوف قبل إرساله إلى المطبخ"
        ],
        "show_print_last_session_dashboard": [
          "txt_lbl_en": "show print last session button at dashboard",
          "txt_lbl_ar": "إظهار زر طباعة آخر جلسة في لوحة القيادة"
        ],
        "enable_chosse_account_journal_for_return_order": [
          "txt_lbl_en": "enable choose payment method for returned order",
          "txt_lbl_ar": "قم بتمكين اختيار طريقة الدفع للطلب المرتجع"
        ],
        "enable_initalize_adjustment_with_zero": [
          "txt_lbl_en": "Enable Initialize Adjustment Quantity with Zero",
          "txt_lbl_ar": "تفعيل تهيئة كميه جرد المخزون بصفر"
        ],
        "Customer": [
          "txt_lbl_en": "Criteria for add customer",
          "txt_lbl_ar": "معايير إضافة العميل"
        ],
        "enable_email_mandatory_add_customer": [
          "txt_lbl_en": "Enable Make Email is mandatory",
          "txt_lbl_ar": "تفعيل جعل البريد الإلكتروني إلزامي"
        ],
        "enable_phone_mandatory_add_customer": [
          "txt_lbl_en": "Enable Make Phone is mandatory",
          "txt_lbl_ar": "تفعيل جعل رقم الهاتف إلزامي"
        ],
        "Menu_settings": [
          "txt_lbl_en": "Menu settings",
          "txt_lbl_ar": "إعدادات المنيو"
        ],
        "enable_auto_accept_order_menu": [
          "txt_lbl_en": "Enable auto accept menu  orders",
          "txt_lbl_ar": "تفعيل القبول التلقائي للطلبات"
        ],
        "enable_play_sound_while_auto_accept_order_menu": [
          "txt_lbl_en": "Enable play sound while auto accept menu orders",
          "txt_lbl_ar": "تفعيل تشغيل نغمة عند القبول التلقائي للطلبات"
        ],
        "enable_play_sound_order_menu": [
          "txt_lbl_en": "Enable play ringtone fo coming menu orders",
          "txt_lbl_ar": "تفعيل تشغيل نغمة لطلبات المنيو القادمة"
        ],
        "Printer": [ "txt_lbl_en": "Printer", "txt_lbl_ar": "" ],
        "tries_non_priinted_number": [
          "txt_lbl_en": "Number of tries to print non-printed reports ",
          "txt_lbl_ar": "عدد محاولات طباعة التقارير غير المطبوعة"
        ],
        "enable_autoPrint": [ "txt_lbl_en": "Auto Print", "txt_lbl_ar": "طباعة آليه" ],
        "mw_minuts_fail_report": [
          "txt_lbl_en": "The number of minutes should  pass at error reports to try reprint ",
          "txt_lbl_ar": "عدد الدقائق  التي يجب أن يمر علي تقارير الأخطاء لمحاولة إعادة الطباعة"
        ],
        "force_connect_with_printer": [
          "txt_lbl_en": "Force connect with printer",
          "txt_lbl_ar": ""
        ],
        "auto_print_zreport": [
          "txt_lbl_en": "Auto Print  z-report",
          "txt_lbl_ar": "طباعة تقرير المبيعات آليا"
        ],
        "open_drawer_only_with_cash_payment_method": [
          "txt_lbl_en": "Open drawer only with cash payment method",
          "txt_lbl_ar": "فتح الصندوق مع الدفع النقدي فقط"
        ],
        "font_size_for_kitchen_invoice": [
          "txt_lbl_en": "Enter font size for kitchen invoice",
          "txt_lbl_ar": "أدخل حجم الخط لفاتورة المطبخ"
        ],
        "enable_simple_invoice_vat": [
          "txt_lbl_en": "Simple invoice vat",
          "txt_lbl_ar": "فاتورة ضريبية مبسطه"
        ],
        "connection_printer_time_out": [
          "txt_lbl_en": "Enter Timeout for printer connection",
          "txt_lbl_ar": "أدخل مهلة اتصال الطابعة"
        ],
        "enable_show_new_render_invoice": [
          "txt_lbl_en": "Enable new render invoice",
          "txt_lbl_ar": "تمكين تقديم فاتورة جديدة"
        ],
        "enable_invoice_width": [
          "txt_lbl_en": "Enable invoice width",
          "txt_lbl_ar": "تمكين عرض الفاتورة"
        ],
        "enable_show_combo_details_invoice": [
          "txt_lbl_en": "Show Combo items details in invoice",
          "txt_lbl_ar": "إظهار تفاصيل عناصر الكمبو في الفاتورة"
        ],
        "enable_show_discount_name_invoice": [
          "txt_lbl_en": "Enable show discount name at invoice",
          "txt_lbl_ar": "تفعيل إظهار اسم الخصم في الفاتورة"
        ],
        "enable_support_multi_printer_brands": [
          "txt_lbl_en": "Enable use multi brand printers",
          "txt_lbl_ar": "تفعيل استخدام طابعات متعددة العلامات التجارية"
        ],
        "enable_show_unite_price_invoice": [
          "txt_lbl_en": "Enable show unit price at invoice",
          "txt_lbl_ar": "تفعيل إظهار سعر الوحدة في الفاتورة"
        ],
        "QR_URL": [ "txt_lbl_en": "QR URL", "txt_lbl_ar": "QR URL" ],
        "qr_enable": [
          "txt_lbl_en": "Enable print invoice QR code",
          "txt_lbl_ar": "تفعيل طباعة رمز QR للفاتورة"
        ],
        "enable_qr_for_draft_bill": [
          "txt_lbl_en": "Enable print QR code for draft bill",
          "txt_lbl_ar": "تفعيل طباعة رمز الاستجابة السريعة لمسودة الفاتورة"
        ],
        "Receipt": [ "txt_lbl_en": "Receipt", "txt_lbl_ar": "الإيصال" ],
        "receipt_logo_width": [
          "txt_lbl_en": "Receipt logo width ( % )",
          "txt_lbl_ar": "مقاس عرض الشعار"
        ],
        "receipt_custom_header": [
          "txt_lbl_en": "Custom header",
          "txt_lbl_ar": "تخصيص الهيدر"
        ],
        "enable_quantity_factor_product_reports": [
          "txt_lbl_en": "Enable quantity factor in product reports",
          "txt_lbl_ar": "تفعيل عامل الكمية في تقرير المنتجات"
        ],
        "receipt_copy_number": [
          "txt_lbl_en": "Count number of Receipt copy",
          "txt_lbl_ar": "عدد نسخ الإيصال"
        ],
        "receipt_copy_number_journal_type_bank": [
          "txt_lbl_en": "Receipt copy number journal type bank",
          "txt_lbl_ar": "طباعة الفاتورة طريقه الدفع بنك"
        ],
        "Log": [ "txt_lbl_en": "Log", "txt_lbl_ar": "السجل" ],
        "show_log": [ "txt_lbl_en": "Show log", "txt_lbl_ar": "اظهر السجل" ],
        "enable_record_all_log": [
          "txt_lbl_en": "Enable Record all requests",
          "txt_lbl_ar": "تفعيل تسجيل كل المعاملات"
        ],
        "enable_log_sync_success_orders": [
          "txt_lbl_en": "Enable Log sucess sync order",
          "txt_lbl_ar": "تفعيل تسجيل مزامنه الطلبات النجاحه"
        ],
        "enable_record_all_log_multisession": [
          "txt_lbl_en": "Enable Record all requests in (Mulitsession)",
          "txt_lbl_ar": "تفعيل تسجيل كل معاملات الجلسه المتعدده"
        ],
        "clear_log_everyDays": [
          "txt_lbl_en": "Clear log every days",
          "txt_lbl_ar": "مسح السجلات كل يوم"
        ],
        "clear_error_log": [
          "txt_lbl_en": "Clear log for error printer every days",
          "txt_lbl_ar": "مسح سجلات اخطاء الطابعة كل يوم"
        ],
        "Time": [ "txt_lbl_en": "Time", "txt_lbl_ar": "الوقت" ],
        "cash_time": [
          "txt_lbl_en": "Cash download Time / h",
          "txt_lbl_ar": "وقت التحميل الافتراضي / ساعة"
        ],
        "clearOrders_everyDays": [
          "txt_lbl_en": "Clear order every days",
          "txt_lbl_ar": "مسح الطلبات كل يوم"
        ],
        "clearPenddingOrders_everyDays": [
          "txt_lbl_en": "Clear pendding order every hour",
          "txt_lbl_ar": "مسح الطلبات المعلقة كل ساعة"
        ],
        "timePaymentSuccessfullMessage": [
          "txt_lbl_en": "Payment success message / Second",
          "txt_lbl_ar": "مده عرض رسالة اتمام الدفع بنجاح بالثانيه "
        ],
        "enable_testMode": [ "txt_lbl_en": "Test mode", "txt_lbl_ar": "وضع التجربة" ],
        "disable_idle_timer": [
          "txt_lbl_en": "Enable stop going to sleep mode",
          "txt_lbl_ar": "تمكين التوقف عن الذهاب إلى وضع السكون"
        ],
        "time_pass_to_go_lock_screen": [
          "txt_lbl_en": "Enter duration with seconds required to go to lock screen ",
          "txt_lbl_ar": "أدخل المدة بالثواني المطلوبة للانتقال إلى شاشة القفل"
        ],
        "enable_new_combo": [
            "txt_lbl_en": "Enable new combo",
            "txt_lbl_ar": "تفعيل العمل بالكمبو الجديد"
          ],
        "enable_resent_failure_ip_kds_order_automatic": [
            "txt_lbl_en": "Enable automatic re-sent failure kds orders",
            "txt_lbl_ar": "تفعيل اعاده ارسال الطلبات لمطبخ بشكل تلقائي"
          ],
        "enable_reconnect_with_printer_automatic": [
            "txt_lbl_en": "Enable re-connect witth printer automatic",
            "txt_lbl_ar": "تفعيل اعاده الاتصال بالطابعه بشكل تلقائي"
          ],
        "enable_work_with_bill_uid_default": [
            "txt_lbl_en": "Enable work with bill uid sequence",
            "txt_lbl_ar": "تفعيل العمل بترقيم الفاتوره"
          ],
        "enable_add_waiter_via_wifi": [
          "txt_lbl_en": "Enable add waiter via WIFI",
          "txt_lbl_ar": "تمكين اضافه جهاز الويتر عن طريق الشبكه"
        ],
        "enable_sync_order_sequence_wifi": [
          "txt_lbl_en": "Enable Sync order sequence via IP",
          "txt_lbl_ar": "تمكين  مزامنه ترقيم الطلبات عبر الشبكه"
        ],
        "time_sleep_print_queue": [
            "txt_lbl_en": "Enter seconds for handling print KDS receipt at same printer",
            "txt_lbl_ar": "أدخل الثواني لمعالجة إيصال طباعة KDS في نفس الطابعة"
          ],
        "enable_local_qty_avaliblity": [
            "txt_lbl_en": "Enable show avliable quantity badge for product",
            "txt_lbl_ar": "تمكين إظهار شارة الكمية المتاحة للمنتج"
          ],
        "enable_enhance_printer_cyle":[
            "txt_lbl_en": "Enable enhance printer cyle",
            "txt_lbl_ar": "تمكين تحسين دورة الطابعة"
        ],
        "options_for_require_customer": [
          "txt_lbl_en": "Option for handle require customer at order type",
          "txt_lbl_ar": "اختيار العميل مع نوع الطلب"
        ],
        "enable_cloud_qr_code":[
            "txt_lbl_en": "Enable get cloud invoice QR code  ",
            "txt_lbl_ar": "تمكين الحصول علي QR code السحابي  "
        ],
        "enable_recieve_update_order_online":[
            "txt_lbl_en": "Enable recieve update for order from online menu",
            "txt_lbl_ar": "تمكين تلقي التعديلات للطلب من المنيو"
        ],
        
        
        "margin_invoice_left_value":[
            "txt_lbl_en": "Enter left invoice margin value ",
            "txt_lbl_ar": "أدخل قيمة هامش الفاتورة الأيسر"
        ],
        "margin_invoice_right_value":[
            "txt_lbl_en": "Enter right invoice margin value ",
            "txt_lbl_ar": "أدخل قيمة هامش الفاتورة الايمن"
        ],
        "enable_new_product_style":[
            "txt_lbl_en": "Enable new style for product",
            "txt_lbl_ar": "تفعيل الشكل الجديد للمنتج"
        ],
        "prevent_new_order_if_empty": [
            "txt_lbl_en": "Stop Create Order when cart is empty",
            "txt_lbl_ar": "إيقاف إضافه طلب جديد في حاله السله الفارغه"
        ],
        "enable_sequence_at_master_only": [
            "txt_lbl_en": "Enable sequence at master device only",
            "txt_lbl_ar": "تفعيل الترقيم علي جهاز الماستر فقط"
        ],
        "enable_make_user_resposiblity_for_order": [
            "txt_lbl_en": "Enable make user resposiblity for order's table",
            "txt_lbl_ar": "تمكين جعل المستخدم مسؤولاً عن طاوله الطلب"
        ],
        "enable_zebra_scanner_barcode":[
            "txt_lbl_en": "Enable working with zebra scanner barcode",
            "txt_lbl_ar": "تمكين العمل مع الباركود الماسح الضوئي zebra"
        ],
        "enable_move_pending_orders":[
            "txt_lbl_en": "Enable grap pending orders to new session",
            "txt_lbl_ar": "تفعيل جلب الطلبات المعلقه الي الجلسه الجديده"
        ],
        "enter_bar_code_length":[
            "txt_lbl_en": "Enter Barcode length",
            "txt_lbl_ar": "ادخل طول الباركود"
        ],
        "start_value_for_bar_code":[
            "txt_lbl_en": "Enter start value for Barcode",
            "txt_lbl_ar": "ادخل بدايه الباركود"
        ],
        "postion_start_id_for_bar_code":[
            "txt_lbl_en": "Enter start postion for product at Barcode",
            "txt_lbl_ar": "ادخل بدايه موضع الصنف "
        ],
        "postion_end_id_for_bar_code":[
            "txt_lbl_en": "Enter end postion for product at Barcode",
            "txt_lbl_ar": "ادخل نهايه موضع الصنف "
        ],
        "postion_start_qty_for_bar_code":[
            "txt_lbl_en": "Enter start quantity at Barcode",
            "txt_lbl_ar": "ادخل بدايه موضع الوزن "
        ],
        "postion_end_qty_for_bar_code":[
            "txt_lbl_en": "Enter end postion for quantity at Barcode",
            "txt_lbl_ar": "ادخل نهايه موضع الكميه "
        ],
       
        
        "enable_enter_reason_void":[
            "txt_lbl_en": "Enable enter reason for void",
            "txt_lbl_ar": "تفعيل إدخال سبب لحذف"
        ],
        "enable_stop_paied_intergrate_order":[
            "txt_lbl_en": "Enable make paied deliveract order to be pending",
            "txt_lbl_ar": "تفعيل جعل الطلبات المدفوع بواسطه دليفراكت معلقه"
        ],
        "enable_enter_containous_sequence":[
            "txt_lbl_en": "Enable Work with continuous sequence",
            "txt_lbl_ar": "تمكين العمل بالتسلسل المستمر"
        ]
        ,
        "start_value_containous_sequence":[
            "txt_lbl_en": "Start sequence for continuous sequence",
            "txt_lbl_ar": "تسلسل البدء للتسلسل المستمر"
        ],
        "enable_show_price_without_tax":[
            "txt_lbl_en": "Enable Show items in the invoice and cart without tax",
            "txt_lbl_ar": "عرض الاصناف في الفاتوره والسله بدون ضريبة"
        ],
        "enable_check_duplicate_lines":[
            "txt_lbl_en": "Enable Check duplicate lines",
            "txt_lbl_ar": "تفعيل التحقق من تكرار اللاين"
        ]
        
        //       enable_enter_reason_void

        
    ]
    func getSettingTitle(for settingKey:SETTING_KEY) -> String{
        if let value = self.settingDic["\(settingKey)"] as? [String:Any]{
            let enTitle = (value["txt_lbl_en"] as? String) ?? ""
            let arTitle = (value["txt_lbl_ar"] as? String) ?? ""
            return enTitle.arabic(arTitle)
        }
        return ""
    }
}
