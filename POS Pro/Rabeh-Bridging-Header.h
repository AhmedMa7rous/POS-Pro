//
//  FMDB-Bridging-Header.h



 #ifndef Rabeh_Bridging_Header_h
#define Rabeh_Bridging_Header_h

#import <UIKit/UIKit.h>

#import "ePOS2.h"
//#import "ePOSEasySelect.h"
#include<ifaddrs.h>

  
 
//#import "ClassDate.h" 
 
  
//#import "JsonToDictionary.h"
//#import "AppDelegate-swift.h"
#import "SSZipArchive.h"
#import "txtToImage.h"
#import "FMDB.h"
#import "GCDAsyncSocket.h"
#import "MacFinder.h"
#import "ZebraScannerSDK/ISbtSdkApi.h"
#import "ZebraScannerSDK/FirmwareUpdateEvent.h"
#import "ZebraScannerSDK/SbtSdkFactory.h"
#import "ZebraScannerSDK/ISbtSdkApiDelegate.h"
#import "ZebraScannerSDK/RMDAttributes.h"
#import "ZebraScannerSDK/SbtScannerInfo.h"
#import "ZebraScannerSDK/SbtSdkDefs.h"
#import "ZebraScannerSDK/SbtSdkFactory.h"
#include <libxml/parser.h>
#include <libxml/tree.h>
#include <libxml/xmlmemory.h>
#include <libxml/xpath.h>

//#include <libxml/xslt.h>
//#include <libxml/xsltutils.h>
#include <libxml/c14n.h>
@class HostService;
@class JoinService;
 
#define defaultDomain "https://erp.dgtera.com"//"https://c3_ios.rabeh.io" // "http://213.52.130.74"

#define app_font_name  "HelveticaNeue" //"Cairo" // Changa
#define app_font_name_printer  "Almarai" //"cairo" // Changa

#define appdlg ((AppDelegate *)[[UIApplication sharedApplication] delegate])

#define page_count 10
 

// ==========================================
// 10 for debug
// 01 for distrubtion
#define test_mode 1// 0 == no , 1 == yes
 
#define stop_debug_code 0 // 0 = for enalble 1 = for disable

#define stop_firebase_database 1 // 0 = for enalble 1 = for disable

 
// ==========================================



#endif /* Rabeh_Bridging_Header_h*/
//#import "FMDB/FMDB.h"

/*
 {"jsonrpc": "2.0", "id": 1, "result": [{"id": 4071205, "channel": "[\"comu_test_tomtom\",\"pos.longpolling\",\"110\"]", "message": "PONG"}]}
 
 */
