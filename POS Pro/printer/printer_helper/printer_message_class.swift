import UIKit

class printer_message_class {
    
//    class func showErrorEpos(_ resultCode:Int32, method:String) {
//
//
//                let msg =   NSLocalizedString(getEposErrorText(resultCode),comment:"")
//
//
//
//        show(msg)
//    }
    

    
    class func showResult(_ code: Int32, errMessage:String) {
        var msg: String = ""
        
        if errMessage.isEmpty {
            msg = String(format:"%@\n%@\n",
                NSLocalizedString("statusmsg_result", comment: ""),
                getEposResultText(code))
        }
        else {
            msg = String(format:"%@\n%@\n\n%@\n%@\n",
                NSLocalizedString("statusmsg_result", comment: ""),
                getEposResultText(code),
                NSLocalizedString("statusmsg_description", comment: ""),
                errMessage)
        }
        
        show(msg)
    }
    
    class func show_in_view(_ message:String , view:UIView) {
        
           view.makeToast(message: message)
       
    }
    
    class func show(_ message:String ,  vc:UIViewController) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)

          let cancelAction = UIAlertAction(title: "OK", style: .cancel)
          alert.addAction(cancelAction)
 
         vc.present(alert, animated: true, completion: nil)
    }
    
    class func show(title:String = "Printer", _ message:String,image:String = "ic_printer.png" ,_ success:Bool = false) {
 
        let msg = message.replacingOccurrences(of: "\n", with: " ")
//        AppDelegate.shared.alert(msg:msg,success: success)
        DispatchQueue.main.async {
        AppDelegate.shared.alert(tile: title,
                                 msg: msg, date: Date().toString(dateFormat: baseClass.date_time_fromate_short, UTC: false) , icon_name: image,success: success)
        }

    }

    
    class func makeErrorMessage(_ status: Epos2PrinterStatusInfo?) -> String {
        let errMsg = NSMutableString()
        if status == nil {
            return ""
        }
        
        if status!.online == EPOS2_FALSE {
            errMsg.append(NSLocalizedString("err_offline", comment:""))
        }
        if status!.connection == EPOS2_FALSE {
            errMsg.append(NSLocalizedString("err_no_response", comment:""))
        }
        if status!.coverOpen == EPOS2_TRUE {
            errMsg.append(NSLocalizedString("err_cover_open", comment:""))
        }
        if status!.paper == EPOS2_PAPER_EMPTY.rawValue {
            errMsg.append(NSLocalizedString("err_receipt_end", comment:""))
        }
        if status!.paperFeed == EPOS2_TRUE || status!.panelSwitch == EPOS2_SWITCH_ON.rawValue {
            errMsg.append(NSLocalizedString("err_paper_feed", comment:""))
        }
        if status!.errorStatus == EPOS2_MECHANICAL_ERR.rawValue || status!.errorStatus == EPOS2_AUTOCUTTER_ERR.rawValue {
            errMsg.append(NSLocalizedString("err_autocutter", comment:""))
            errMsg.append(NSLocalizedString("err_need_recover", comment:""))
        }
        if status!.errorStatus == EPOS2_UNRECOVER_ERR.rawValue {
            errMsg.append(NSLocalizedString("err_unrecover", comment:""))
        }
        
        if status!.errorStatus == EPOS2_AUTORECOVER_ERR.rawValue {
            if status!.autoRecoverError == EPOS2_HEAD_OVERHEAT.rawValue {
                errMsg.append(NSLocalizedString("err_overheat", comment:""))
                errMsg.append(NSLocalizedString("err_head", comment:""))
            }
            if status!.autoRecoverError == EPOS2_MOTOR_OVERHEAT.rawValue {
                errMsg.append(NSLocalizedString("err_overheat", comment:""))
                errMsg.append(NSLocalizedString("err_motor", comment:""))
            }
            if status!.autoRecoverError == EPOS2_BATTERY_OVERHEAT.rawValue {
                errMsg.append(NSLocalizedString("err_overheat", comment:""))
                errMsg.append(NSLocalizedString("err_battery", comment:""))
            }
            if status!.autoRecoverError == EPOS2_WRONG_PAPER.rawValue {
                errMsg.append(NSLocalizedString("err_wrong_paper", comment:""))
            }
        }
        if status!.batteryLevel == EPOS2_BATTERY_LEVEL_0.rawValue {
            errMsg.append(NSLocalizedString("err_battery_real_end", comment:""))
        }
        
        return errMsg as String
    }
    class  func getEposErrorText(_ error : Int32) -> String {
        var errText = ""
        switch (error) {
        case EPOS2_SUCCESS.rawValue:
            errText = "SUCCESS"
            break
        case EPOS2_ERR_PARAM.rawValue:
            errText = "ERR_PARAM"
            break
        case EPOS2_ERR_CONNECT.rawValue:
            errText = "ERR_CONNECT"
            break
        case EPOS2_ERR_TIMEOUT.rawValue:
            errText = "ERR_TIMEOUT"
            break
        case EPOS2_ERR_MEMORY.rawValue:
            errText = "ERR_MEMORY"
            break
        case EPOS2_ERR_ILLEGAL.rawValue:
            errText = "ERR_ILLEGAL"
            break
        case EPOS2_ERR_PROCESSING.rawValue:
            errText = "ERR_PROCESSING"
            break
        case EPOS2_ERR_NOT_FOUND.rawValue:
            errText = "ERR_NOT_FOUND"
            break
        case EPOS2_ERR_IN_USE.rawValue:
            errText = "ERR_IN_USE"
            break
        case EPOS2_ERR_TYPE_INVALID.rawValue:
            errText = "ERR_TYPE_INVALID"
            break
        case EPOS2_ERR_DISCONNECT.rawValue:
            errText = "ERR_DISCONNECT"
            break
        case EPOS2_ERR_ALREADY_OPENED.rawValue:
            errText = "ERR_ALREADY_OPENED"
            break
        case EPOS2_ERR_ALREADY_USED.rawValue:
            errText = "ERR_ALREADY_USED"
            break
        case EPOS2_ERR_BOX_COUNT_OVER.rawValue:
            errText = "ERR_BOX_COUNT_OVER"
            break
        case EPOS2_ERR_BOX_CLIENT_OVER.rawValue:
            errText = "ERR_BOXT_CLIENT_OVER"
            break
        case EPOS2_ERR_UNSUPPORTED.rawValue:
            errText = "ERR_UNSUPPORTED"
            break
        case EPOS2_ERR_FAILURE.rawValue:
            errText = "ERR_FAILURE"
            break
        default:
            errText = String(format:"%d", error)
            break
        }
        return errText
    }
    
    class fileprivate func getEposBtErrorText(_ error : Int32) -> String {
        var errText = ""
        switch (error) {
        case EPOS2_BT_SUCCESS.rawValue:
            errText = "SUCCESS"
            break
        case EPOS2_BT_ERR_PARAM.rawValue:
            errText = "ERR_PARAM"
            break
        case EPOS2_BT_ERR_UNSUPPORTED.rawValue:
            errText = "ERR_UNSUPPORTED"
            break
        case EPOS2_BT_ERR_CANCEL.rawValue:
            errText = "ERR_CANCEL"
            break
        case EPOS2_BT_ERR_ALREADY_CONNECT.rawValue:
            errText = "ERR_ALREADY_CONNECT"
            break;
        case EPOS2_BT_ERR_ILLEGAL_DEVICE.rawValue:
            errText = "ERR_ILLEGAL_DEVICE"
            break
        case EPOS2_BT_ERR_FAILURE.rawValue:
            errText = "ERR_FAILURE"
            break
        default:
            errText = String(format:"%d", error)
            break
        }
        return errText
    }
    
    class fileprivate func getEposResultText(_ resultCode : Int32) -> String {
        var result = ""
        switch (resultCode) {
        case EPOS2_CODE_SUCCESS.rawValue:
            result = "PRINT_SUCCESS"
            break
        case EPOS2_CODE_PRINTING.rawValue:
            result = "PRINTING"
            break
        case EPOS2_CODE_ERR_AUTORECOVER.rawValue:
            result = "ERR_AUTORECOVER"
            break
        case EPOS2_CODE_ERR_COVER_OPEN.rawValue:
            result = "ERR_COVER_OPEN"
            break
        case EPOS2_CODE_ERR_CUTTER.rawValue:
            result = "ERR_CUTTER"
            break
        case EPOS2_CODE_ERR_MECHANICAL.rawValue:
            result = "ERR_MECHANICAL"
            break
        case EPOS2_CODE_ERR_EMPTY.rawValue:
            result = "ERR_EMPTY"
            break
        case EPOS2_CODE_ERR_UNRECOVERABLE.rawValue:
            result = "ERR_UNRECOVERABLE"
            break
        case EPOS2_CODE_ERR_FAILURE.rawValue:
            result = "ERR_FAILURE"
            break
        case EPOS2_CODE_ERR_NOT_FOUND.rawValue:
            result = "ERR_NOT_FOUND"
            break
        case EPOS2_CODE_ERR_SYSTEM.rawValue:
            result = "ERR_SYSTEM"
            break
        case EPOS2_CODE_ERR_PORT.rawValue:
            result = "ERR_PORT"
            break
        case EPOS2_CODE_ERR_TIMEOUT.rawValue:
            result = "ERR_TIMEOUT"
            break
        case EPOS2_CODE_ERR_JOB_NOT_FOUND.rawValue:
            result = "ERR_JOB_NOT_FOUND"
            break
        case EPOS2_CODE_ERR_SPOOLER.rawValue:
            result = "ERR_SPOOLER"
            break
        case EPOS2_CODE_ERR_BATTERY_LOW.rawValue:
            result = "ERR_BATTERY_LOW"
            break
        case EPOS2_CODE_ERR_TOO_MANY_REQUESTS.rawValue:
            result = "ERR_TOO_MANY_REQUESTS"
            break
        case EPOS2_CODE_ERR_REQUEST_ENTITY_TOO_LARGE.rawValue:
            result = "ERR_REQUEST_ENTITY_TOO_LARGE"
            break
        default:
            result = String(format:"%d", resultCode)
            break
        }
        
        return result;
    }
}
