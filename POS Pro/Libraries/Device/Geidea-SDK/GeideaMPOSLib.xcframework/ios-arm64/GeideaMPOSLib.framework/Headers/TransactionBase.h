//
//  TransactionBase.h
//  SP530 Hulk
//
//  Created by spectra on 29/7/15.
//  Copyright (c) 2015 Spectra Technologies Holdings Company Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransactionBase : NSObject
{
}

//**** General Class Type Commands (0x0X) ****//
#define	S3INS_ECHO          0x00
#define	S3INS_PP300         0x04
#define S3INS_FULL_EMV      0x23

//**** Response Code ****//
#define CLACT_SIGNATURE 0x01
#define CLACT_DEFCVM    0x08
#define CLACT_ONLINE    0x10
#define CLACT_REFERRAL  0x20
#define CLACT_HOSTAPP   0x40
#define CLACT_APPROVED  0x80

//**** Setup Class Type Commands (0x1X) ****//
#define	S3INS_GEN_KEY	0x10
#define	S3INS_ESETUP	0x11
#define	S3INS_PARA_PUT	0x12
#define	S3INS_PARA_GET	0x13
#define	S3INS_ETAG_PUT	0x14
#define	S3INS_ETAG_GET	0x15
#define	S3INS_EMVSETUP	0x16
#define	S3INS_EMVCALL	0x17
#define	S3INS_ICCCMD	0x18
#define	S3INS_TAGCARD	0x19
#define	S3INS_SYS_FUNC	0x1A

//**** Transaction Class Type Commands (0x2X) ****//
#define	S3INS_TRANS     0x20
#define	S3INS_RESET     0x21
#define	S3INS_SHOW_STAT	0x22
#define	S3INS_FULL_EMV	0x23


 #ifndef S3RC_OK
//**** Transaction Resposne Code ****
#define S3RC_OK         0x00
#define S3RC_CANCEL     0x40
#define S3RC_TIMEOUT	0x41
#define S3RC_MORE_CARDS	0x42
#define S3RC_ERR        0x80
#define S3RC_ERR_CSUM	0x81
#define S3RC_ERR_DATA	0x82
#define S3RC_ERR_FMT	0x83
#define S3RC_ERR_MEM	0x84
#define S3RC_ERR_KEY	0x85
#define S3RC_ERR_INS	0x86
#define S3RC_ERR_KVC	0x87
#define S3RC_ERR_SEQ	0x88
#define S3RC_ERR_PREL	0x89
#endif

#define TX_APPROVED   {0x30, 0x30}
#define TX_DECLINED   {0x35, 0x32} 


#define TAG_TX_STATUS {0x8a, 0x02}
#define TAG_TX_DATE {0x00, 0x9A}



enum trans_type_t
{
    sales_trans =0,
    void_trans = 1,
    refund = 2,
    adjust = 3,
    service_sale=4,
    cash_withdraw=5,
    offline_sales=6,
    auth=8,
    settlement=9
};

enum trans_status_t
{
    tx_approved = 0x80,
    host_approved = 0x40,
    referral_required=0x20,
    online_authorization=0x10,
    signature_required=0x01
}; // online authorization result

typedef struct sp530_app_header
{
    unsigned char stx;
    unsigned char format_id[4];
    unsigned char src_addr;
    unsigned char dest_addr;
    unsigned char seq_num[2];
    unsigned char cmd_code;
    unsigned char data_format;
    unsigned char data_length[2];
}sp530_app_header;

typedef struct sp530_app_sales_header
{
    unsigned char response_code;
    unsigned char m_eid[4];
    unsigned char data_length[2];
    unsigned char sts[2];
}sp530_app_sales_header;

typedef struct sp530_app_tail
{
    unsigned char crc16[4];
    unsigned char etx;
}sp530_app_tail;

-(id)init;

@property(assign, nonatomic)double BaseAmount;
@property(assign, nonatomic)double Tips;
@property(assign, nonatomic)double TotalAmount;
@property(assign, nonatomic)enum trans_type_t TransType;

@end
