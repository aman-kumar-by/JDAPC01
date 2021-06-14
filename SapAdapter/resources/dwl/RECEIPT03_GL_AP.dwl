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
	(p('SAP.GL.AP_IDOCTYP_RECEIPT')) : {
		(payload.generalLedger map() -> {
			IDOC: {
				EDI_DC40: {
					IDOCTYP: p('SAP.GL.AP_IDOCTYP_RECEIPT'),
			        MESTYP: p('SAP.GL.AP_MESTYP_RECEIPT'),
					SNDPOR: p('SAP.SNDPOR'),
					SNDPRT: p('SAP.SNDPRT'),
					SNDPRN: p('SAP.SNDPRN'),
					RCVPOR: p('SAP.RCVPOR'),
					RCVPRT: p('SAP.RCVPRT'),
					RCVPRN: p('SAP.RCVPRN'),
					DIRECT: "2"
				},
				($.generalLedgerTransaction map (val,key)->{
				E1BPACHE03: {
			OBJ_TYPE : "IDOC",
			OBJ_KEY : val.voucherDetail.referenceNumberValue,
			OBJ_SYS : "SAPCONNECT",
			USERNAME : "BLUEYONDER",
			HEADER_TXT : val.generalLedgerTransactionId,
			COMP_CODE : if ( not isEmpty(val.organisationName) ) vars.orgCodeMap[val.organisationName as String] else "1000",
			AC_DOC_NO : (if (val.transactionCategory default "" contains "REVERSED") "REVERSED" else ""),
			FISC_YEAR : val.fiscalYear,
		    DOC_DATE : $.creationDateTime  as DateTime  as String {
						format : "yyyy-MM-dd"
					},
			PSTNG_DATE : $.creationDateTime  as DateTime  as String {
						format : "yyyy-MM-dd"
					},
			FIS_PERIOD : val.accountingPeriod,
			DOC_TYPE : "KR",
			REF_DOC_NO : val.voucherDetail.referenceNumberValue,
			REF_DOC_NO_LONG : val.voucherDetail.referenceNumberValue,
			},
				E1BPACAP03 : {
				ITEMNO_ACC : "0000000001",
				VENDOR_NO : leftPad(val.accountParty.primaryId,10,0)
				},
				E1BPACGL03 : {
				ITEMNO_ACC : "0000000002",
				GL_ACCOUNT : leftPad(val.generalLedgerAccountNumber,10,0),
				COSTCENTER : leftPad(val.costCenter,10,0),
				PROFIT_CTR : leftPad(val.profitCenter,10,0)
				},
				/* E1BPACTX01 : {
				ITEMNO_ACC : "003",
				GL_ACCOUNT : leftPad(val.generalLedgerAccountNumber,10,0),
				TAX_CODE : "VA",
				ACCT_KEY : "VST"
				}, */
				E1BPACCR01 : {
				ITEMNO_ACC : "0000000001",
				CURRENCY : val.amount.currencyCode,
				AMT_DOCCUR : -(val.amount.value)
				},
				E1BPACCR01 : {
				ITEMNO_ACC : "0000000002",
				CURRENCY : val.amount.currencyCode,
				AMT_DOCCUR : val.amount.value
				}
			})
			}
		})
	}
}        
