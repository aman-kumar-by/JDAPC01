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
	(p('SAP.GL.AP_IDOCTYP_PORDCR')) : {
		(payload.generalLedger map() -> {
			IDOC: {
				EDI_DC40: {
					IDOCTYP: p('SAP.GL.AP_IDOCTYP_PORDCR'),
					MESTYP: p('SAP.GL.AP_MESTYP_PORDCR'),
					SNDPOR: p('SAP.SNDPOR'),
					SNDPRT: p('SAP.SNDPRT'),
					SNDPRN: p('SAP.SNDPRN'),
					RCVPOR: p('SAP.RCVPOR'),
					RCVPRT: p('SAP.RCVPRT'),
					RCVPRN: p('SAP.RCVPRN'),
					DIRECT: 2
				},
				($.generalLedgerTransaction map (val,key) -> {
					E1PORDCR1 @(SEGMENT: "00000" ++(1 +(key))): {
						E1BPMEPOHEADER @(SEGMENT: "00000" ++(2 +(key))): {
							COMP_CODE: if ( not isEmpty(val.organisationName) ) vars.orgCodeMap[val.organisationName as String] else "",
							DOC_TYPE: "NB",
							CREAT_DATE: $.creationDateTime  as DateTime  as String {
								format : "yyyy-MM-dd"
							},
							VENDOR: leftPad(val.accountParty.primaryId,10,0),
							PURCH_ORG: "1000",
							PUR_GROUP: "001",
							CURRENCY: val.amount.currencyCode,
							DOC_DATE: $.creationDateTime  as DateTime  as String {
								format : "yyyy-MM-dd"
							},
						},
						E1BPMEPOHEADERX @(SEGMENT: "00000" ++ (3 +(key))): {
							PO_NUMBER: "X",
							COMP_CODE: "X",
							DOC_TYPE: "X",
							CREAT_DATE: "X",
							VENDOR: "X",
							PURCH_ORG: "X",
							PUR_GROUP: "X",
							CURRENCY: "X",
							DOC_DATE: "X"
						},
						E1BPMEPOITEM @(SEGMENT: "00000" ++ (4 +(key))): {
							PO_ITEM: "00010",
							// SHORT_TEXT: mapping configuration needed from CanModel Team
							PLANT: "1000",
							MATL_GROUP: "001",
							QUANTITY: "1",
							PO_UNIT_ISO: "PCE",
							NET_PRICE: val.amount.value,
							PRICE_UNIT: "1",
							ACCTASSCAT: "K"
						},
						E1BPMEPOITEMX @(SEGMENT: "00000" ++ (5 +(key))): {
							PO_ITEM: "00010",
							PO_ITEMX: "X",
							SHORT_TEXT: "X",
							PLANT: "X",
							MATL_GROUP: "X",
							QUANTITY: "X",
							PO_UNIT_ISO: "X",
							NET_PRICE: "X",
							PRICE_UNIT: "X",
							ACCTASSCAT: "X"
						},
						E1BPMEPOACCOUNT @(SEGMENT: "00000" ++ (6 +(key))): {
							PO_ITEM: "00010",
							COSTCENTER: val.costCenter
						},
						E1BPMEPOACCOUNTX @(SEGMENT: "00000" ++(7 +(key))): {
							PO_ITEM: "00010",
							COSTCENTER: "X"
						}
					}
				})
			}
		})
	}
}
    
	

