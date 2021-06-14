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
output application/xml
import * from dw::core::Strings
---
{
	(p('inbound.generalLedger.accountPayable.bapiType')) : {
		(payload.generalLedger map() -> {
			($.generalLedgerTransaction map (val,key)-> 
       	{
				DOCUMENTHEADER: {
					OBJ_TYPE: "IDOC",
					OBJ_KEY: val.generalLedgerTransactionId,
					OBJ_SYS: "SAPCONNECT",
					BUS_ACT: "RMRP",
					USERNAME: "BLUEYONDER",
					HEADER_TXT: val.generalLedgerTransactionId,
					COMP_CODE: if ( not isEmpty(val.organisationName) ) vars.orgCodeMap[val.organisationName as String] else "",
					DOC_DATE: $.creationDateTime  as DateTime  as String {
						format : "yyyy-MM-dd"
					},
					PSTNG_DATE: $.creationDateTime  as DateTime  as String {
						format : "yyyy-MM-dd"
					},
					FISC_YEAR: val.fiscalYear,
					FIS_PERIOD: val.accountingPeriod,
					DOC_TYPE: "KR",
					REF_DOC_NO: val.voucherDetail.referenceNumberValue,
					REF_DOC_NO_LONG: val.voucherDetail.referenceNumberValue
				},
				ACCOUNTGL: {
					item: {
						ITEMNO_ACC: "000000000" ++(2 +(key)),
						GL_ACCOUNT: val.generalLedgerAccountNumber,
						TAX_CODE: "VA",
						COSTCENTER: val.costCenter,
						PROFIT_CTR: val.profitCenter
					}
				},
				ACCOUNTPAYABLE: {
					item: {
						ITEMNO_ACC: "0000000001",
						VENDOR_NO: leftPad(val.accountParty.primaryId,10,0)
					}
				},
				ACCOUNTTAX: {
					CURRENCYAMOUNT: {
						item: {
							ITEMNO_ACC: "000000000" ++(1 +(key)),
							CURRENCY: val.amount.currencyCode,
							AMT_DOCCUR: val.amount.value
						}
					}
				}
			})
		})
	}
}