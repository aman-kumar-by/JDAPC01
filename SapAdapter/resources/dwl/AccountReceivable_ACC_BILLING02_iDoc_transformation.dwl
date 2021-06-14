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
	(p('SAP.GL.AR_IDOCTYP_ACC')) : {
		(payload.generalLedger map() -> {
			IDOC: {
				EDI_DC40: {
					IDOCTYP: p('SAP.GL.AR_IDOCTYP_ACC'),
					MESTYP: p('SAP.GL.AR_MESTYP_ACC'),
					SNDPOR: p('SAP.SNDPOR'),
					SNDPRT: p('SAP.SNDPRT'),
					SNDPRN: p('SAP.SNDPRN'),
					RCVPOR: p('SAP.RCVPOR'),
					RCVPRT: p('SAP.RCVPRT'),
					RCVPRN: p('SAP.RCVPRN'),
					DIRECT: 2
				},
				($.generalLedgerTransaction map (val,key)->{
					E1BPACHE01 @(SEGMENT: "000001"): {
						OBJ_TYPE: "IDOC",
						OBJ_KEY: val.generalLedgerTransactionId,
						OBJ_SYS: "SAPCONNECT",
						USERNAME: "BLUEYONDER",
						HEADER_TXT: val.generalLedgerTransactionId,
						COMP_CODE: if ( not isEmpty(val.organisationName) ) vars.orgCodeMap[val.organisationName as String] else "",
						AC_DOC_NO: if ( val.transactionCategory != null and val.transactionCategory contains  "*REVERSED*" ) "REVERSED" else "",
						FISC_YEAR: val.fiscalYear,
						DOC_DATE: $.creationDateTime  as DateTime  as String {
							format : "yyyy-MM-dd"
						},
						PSTNG_DATE: $.creationDateTime  as DateTime  as String {
							format : "yyyy-MM-dd"
						},
						FIS_PERIOD: val.accountingPeriod,
						DOC_TYPE: "DR",
						REF_DOC_NO: val.voucherDetail.referenceNumberValue,
						REF_DOC_NO_LONG: val.voucherDetail.referenceNumberValue
					},
					E1BPACAR01 @(SEGMENT: "000002"): {
						ITEMNO_ACC: "0000000001",
						CUSTOMER: leftPad(val.accountParty.primaryId,10,0)
					},
					E1BPACGL01 @(SEGMENT: "00000" ++ (3 +(key))): {
						ITEMNO_ACC: "000000000" ++(2 +(key)),
						GL_ACCOUNT: val.generalLedgerAccountNumber,
						TAX_CODE: "1O",
						COSTCENTER: val.costCenter,
						PROFIT_CTR: val.profitCenter
					},
					E1BPACTX01 @(SEGMENT: "00000" ++ (4 +(key))): {
						ITEMNO_ACC: "000000000" ++(3 +(key)),
						GL_ACCOUNT: "170010",
						TAX_CODE: "1O",
						ACCT_KEY: "MWS",
						COND_KEY: "MWAS",
					},
					E1BPACCR01 @(SEGMENT: "00000" ++ (5 +(key))): {
						ITEMNO_ACC: "000000000" ++(4 +(key)),
						CURRENCY: val.amount.currencyCode,
						AMT_DOCCUR: val.amount.value
					}
				})
			}
		})
	}
}