/*
* //==========================================================================
* //               Copyright 2020, Blue Yonder, Inc.
* //                         All Rights Reserved
* //
* //              THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF
* //                         BLUE YONDER, INC.
* //
* //
* //          The copyright notice above does not evidence any actual
* //               or intended publication of such source code.
* //
* //==========================================================================
*/
%dw 2.0
import * from dw::core::Strings
var csvCol = "OBJ_TYPE,OBJ_KEY,OBJ_SYS,BUS_ACT,USERNAME,HEADER_TXT,COMP_CODE,DOC_DATE,PSTNG_DATE,TRANS_DATE,FISC_YEAR,FIS_PERIOD,DOC_TYPE,REF_DOC_NO,REF_DOC_NO_LONG,ITEMNO_ACC_GL,GL_ACCOUNT_GL,COSTCENTER,PROFIT_CTR,ITEMNO_ACC_V,VENDOR_NO,ITEMNO_ACC_C,CUSTOMER,ITEMNO_ACC_CA,CURRENCY,AMT_DOCCUR" splitBy ","
fun Left_Pad(val) = leftPad(val,10,0)
fun Account(val) = "192" ++ (mod(val + 1, 2)) + 1 ++ "00"
fun debit(val) =  val ++ "-"
fun removeHypenFromDate(dateValue) = dateValue as Date {format : "yyyy-MM-dd"} as Date {format : "yyyyMMdd"}
fun transformer(voucher, voucherCharge, index, debitOrCreditVal) =
  {
    (csvCol[0]): "IDOC",
    (csvCol[1]): voucher.internalReferenceId.entityId,
    (csvCol[2]): "SAPCONNECT",
    (csvCol[3]): "RFBU",
    (csvCol[4]): "BLUEYONDER",
    (csvCol[5]): voucher.voucherId,
    (csvCol[6]): if ( not isEmpty(voucher.organisationName) ) vars.orgCodeMap[(voucher.organisationName as String)] else "1000",
    (csvCol[7]): removeHypenFromDate(substringBefore(voucher.creationDateTime, "T")),
    (csvCol[8]): removeHypenFromDate(substringBefore(voucher.creationDateTime, "T")),
    (csvCol[9]): "",
    (csvCol[10]): 
      if (not isEmpty(voucher.creationDateTime))
        substringBefore(voucher.creationDateTime, "-")
      else
        substringBefore(now(), "-"),
    (csvCol[11]): 
      if (not isEmpty(voucher.creationDateTime))
        substringBefore(substringAfter(voucher.creationDateTime, "-"), "-")
      else
        substringBefore(substringAfter(now(), "-"), "-"),
    (csvCol[12]): 
      if (voucher.voucherTypeCode == "AP")
        "SA"
      else
        "",
    (csvCol[13]): voucher.internalReferenceId.entityId,
    (csvCol[14]): voucher.internalReferenceId.entityId,
    (csvCol[15]): Left_Pad(index),
    (csvCol[16]): Left_Pad(Account(index)),
    (csvCol[17]): Left_Pad(voucher.voucherDetails.costCenter),
    (csvCol[18]): voucher.voucherDetails.profitCenter,
    (csvCol[19]): if(index == 1)"0000000001" else "",
    (csvCol[20]): Left_Pad(voucher.supplier.primaryId),
    (csvCol[21]): "",
    (csvCol[22]): "",
    (csvCol[23]): Left_Pad(index),
    (csvCol[24]): voucherCharge.chargedAmount.currencyCode,
    (csvCol[25]): debitOrCreditVal // discountAmount
  }
output application/csv  
---
payload.voucher 
reduce ((voucher, acc = []) -> (
    acc ++ 
    (voucher.voucherCharge 
        filter (($.chargedAmount.value != 0) and ($.chargedAmount.value != '0') and $.voucherChargeLevelCode != "TOTAL")
        distinctBy($.systemChargeDetailId) 
        reduce ((item, accumulator = []) -> (
            accumulator ++
            [transformer(voucher, item, 1 + sizeOf(accumulator), item.chargedAmount.value - item.discountAmount)] ++ 
            [transformer(voucher, item, 2 + sizeOf(accumulator), debit(item.chargedAmount.value - item.discountAmount))]
        )
    ))
))