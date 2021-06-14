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
	(p('SAP.GL.AP_IDOCTYP_ACL')) : {
		(payload.generalLedger map() -> {
			IDOC: {
				EDI_DC40: {
					IDOCTYP: p('SAP.GL.AP_IDOCTYP_ACL'),
					MESTYP: p('SAP.GL.AP_MESTYP_ACL'),
					SNDPOR: p('SAP.SNDPOR'),
					SNDPRT: p('SAP.SNDPRT'),
					SNDPRN: p('SAP.SNDPRN'),
					RCVPOR: p('SAP.RCVPOR'),
					RCVPRT: p('SAP.RCVPRT'),
					RCVPRN: p('SAP.RCVPRN'),
					DIRECT: 2
				},
				($.generalLedgerTransaction map (val,key) -> {
					E1ACH3 @(SEGMENT: "00000" ++(1 +(key))): {
						AWKEY: val.voucherDetail.referenceNumberValue,
						AWSYS: "SAPCONNECT",
						BKTXT: val.generalLedgerTransactionId,
						BUKRS: if ( not isEmpty(val.organisationName) ) vars.orgCodeMap[val.organisationName as String] else "",
						BELNR: if ( val.transactionCategory != null and val.transactionCategory contains  "*REVERSED*" ) "REVERSED" else "",
						GJAHR: val.fiscalYear,
						BLDAT: $.creationDateTime  as DateTime  as String {
							format : "yyyy-MM-dd"
						},
						BUDAT: $.creationDateTime  as DateTime  as String {
							format : "yyyy-MM-dd"
						},
						MONAT: val.accountingPeriod,
						BLART: "KR",
						XBLNR: val.voucherDetail.referenceNumberValue,
						WAERS: val.amount.currencyCode
					},
					E1ACK3 @(SEGMENT: "000002"): {
						SHKZG: "H",
						LIFNR: leftPad(val.accountParty.primaryId,10,0),
						HKONT: leftPad(val.generalLedgerAccountNumber,10,0),
						E1ACK3C @(SEGMENT: "000003"): {
							WAERS: val.amount.currencyCode
							//WRBTR: Need addition logic
						}
					},
					E1ACA3 @(SEGMENT: "00000" ++ (4 +(key*2))): {
						HKONT: leftPad(val.generalLedgerAccountNumber,10,0),
						(if ( val.transactionType == "DEBIT" ) {
							SHKZG: "S"
						} else if ( val.transactionType == "CREDIT" ) {
							SHKZG: "H"
						} else ""),
						MWSKZ: "VA",
						KOSTL: val.costCenter,
						PRCTR: val.profitCenter,
						E1ACA3C @(SEGMENT: "00000" ++ (5 +(key))): {
							WAERS: val.amount.currencyCode,
							WRBTR: val.amount.value 
						}
					},
					E1ACT3 @(SEGMENT: "00000" ++(6 +(key))): {
						HKONT: val.generalLedgerAccountNumber,
						(if ( val.transactionType == "DEBIT" ) {
							SHKZG: "S"
						} else if ( val.transactionType == "CREDIT" ) {
							SHKZG: "H"
						} else ""),
						MWSKZ: "VA",
						KTOSL: "VST",
						E1ACT3C: {
							WAERS: val.amount.currencyCode,
							WRBTR: val.amount.value
						}
					}
				})
			}
		})
	}
}
    
	

