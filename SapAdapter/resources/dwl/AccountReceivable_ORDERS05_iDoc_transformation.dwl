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
	(p('SAP.GL.AR_IDOCTYP_ORDERS')) : {
		(payload.generalLedger map() -> {
			IDOC @(BEGIN: "1"): {
				EDI_DC40: {
					IDOCTYP: p('SAP.GL.AR_IDOCTYP_ORDERS'),
					MESTYP: p('SAP.GL.AR_MESTYP_ORDERS'),
					SNDPOR: p('SAP.SNDPOR'),
					SNDPRT: p('SAP.SNDPRT'),
					SNDPRN: p('SAP.SNDPRN'),
					RCVPOR: p('SAP.RCVPOR'),
					RCVPRT: p('SAP.RCVPRT'),
					RCVPRN: p('SAP.RCVPRN'),
					DIRECT: 2
				},
				($.generalLedgerTransaction map (val,key)->{
					E1EDK14 @(SEGMENT: "00000" ++(1 +(key))): {
						// sapOrgElement  is "Division"
						QUALF: "006",
						ORGID: "00",
						// sapOrgElement is "Distribution Channel
						QUALF: "007",
						ORGID: "10",
						// sapOrgElement is "Sales Org"
						QUALF: "012",
						ORGID: "TA",
						QUALF: "008",
						ORGID: if ( not isEmpty(val.organisationName) ) vars.orgCodeMap[val.organisationName as String] else ""
					},
					E1EDK03 @(SEGMENT: "00000" ++ (2 +(key))): {
						IDDAT: "002",
						DATUM: now() as Date {
							format : "yyyy-MM-dd"
						},
						IDDAT: "012",
						DATUM: now() as Date {
							format : "yyyy-MM-dd"
						},
						IDDAT: "023",
						DATUM: now() as Date {
							format : "yyyy-MM-dd"
						}
					},
					E1EDKA1 @(SEGMENT: "00000" ++ (3 +(key))): {
						PARVW: "AG",
						PARTN: leftPad(val.accountParty.primaryId,10,0)
					},
					E1EDK17 @(SEGMENT: "00000" ++ (4 +(key))): {
						QUALF: "001",
						LKOND: "CIF",
						QUALF: "002",
						LKOND: "Cost Insurance Freight"
					},
					E1EDP01 @(SEGMENT: "00000" ++ (5 +(key))): {
						POSEX: "000010",
						MENGE: "1",
						MENEE: "PCE",
						NETWR: val.amount.value,
						CURCY: val.amount.currencyCode,
						WERKS: "1000",
						E1EDP03 @(SEGMENT: "00000" ++ (6 +(key))): {
							IDDAT: "023",
							DATUM: val.creationDateTime
						},
						E1EDP20 @(SEGMENT: "00000" ++ (7 +(key))): {
							WMENG: "1"
						},
						E1EDP19 @(SEGMENT: "00000" ++ (8 +(key))): {
							QUALF: "002",
							IDTNR: "AD_MAT",
							KTEXT: "GL Transaction"
						}
					}
				})
			}
		})
	}
}