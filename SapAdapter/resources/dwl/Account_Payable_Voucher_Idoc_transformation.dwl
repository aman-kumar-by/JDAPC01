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
---
{
	(p('SAP.VM.AP_IDOCTYP_ACL')) : {
		(payload.voucher map(val,key) -> {
			IDOC: {
				EDI_DC40: {
					IDOCTYP: p('SAP.VM.AP_IDOCTYP_ACL'),
					MESTYP: p('SAP.VM.AP_MESTYP_ACL'),
					SNDPOR: p('SAP.SNDPOR'),
					SNDPRT: p('SAP.SNDPRT'),
					SNDPRN: p('SAP.SNDPRN'),
					RCVPOR: p('SAP.RCVPOR'),
					RCVPRT: p('SAP.RCVPRT'),
					RCVPRN: p('SAP.RCVPRN'),
					DIRECT: 2
				},
				E1ACH3 @(SEGMENT: "00000" ++(1 +(key))): {
					AWKEY: val.internalReferenceId.entityId,
					AWSYS: "SAPCONNECT",
					BKTXT: val.voucherId,
					BUKRS: if ( not isEmpty(val.organisationName) ) vars.orgCodeMap[val.organisationName as String] else "1000",
					GJAHR: val.creationDateTime  as Date  as String {
						format : "yyyy"
					},
					BLDAT: val.creationDateTime  as DateTime  as String {
						format : "yyyy-MM-dd"
					},
					BUDAT: val.creationDateTime  as DateTime  as String {
						format : "yyyy-MM-dd"
					},
					MONAT: val.creationDateTime  as Date  as String {
						format : "MM"
					},
					BLART: "SA",
					XBLNR: val.internalReferenceId.entityId,
					WAERS: val.voucherCharge.chargedAmount.currencyCode
				},
				E1ACK3 @(SEGMENT: "00000" ++(2 +(key))): {
					SHKZG: "H",
					LIFNR: val.supplier.primaryId,
					ZUONR: if ( not isEmpty(val.voucherDetails.originalVoucherId) ) val.voucherDetails.originalVoucherId else "",
					E1ACK3C @(SEGMENT: "00000" ++(3 +(key))): {
						WAERS: val.voucherCharge.chargedAmount.currencyCode
					}
				},
				(val.voucherCharge distinctBy($.systemChargeDetailId) map (vouCharge,index)->  {
					(E1ACA3 @(SEGMENT: "00000" ++(4 +(index))): {
						HKONT: "192100",
						SHKZG: "H",
						KOSTL: val.voucherDetails.costCenter,
						PRCTR: val.voucherDetails.profitCenter,
						E1ACA3C @(SEGMENT: "00000" ++(5 +(index))): {
							WAERS: (vouCharge.chargedAmount.currencyCode),
							WRBTR: -((vouCharge.chargedAmount.value) - (vouCharge.discountAmount.value default 0))
						}
					}) if (vouCharge.voucherChargeLevelCode != "TOTAL" and vouCharge.chargedAmount.value != 0),
					(E1ACA3 @(SEGMENT: "00000" ++(6 +(index))): {
						HKONT: "192200",
						SHKZG: "S",
						KOSTL: val.voucherDetails.costCenter,
						PRCTR: val.voucherDetails.profitCenter,
						E1ACA3C @(SEGMENT: "00000" ++(7 +(index))): {
							WAERS: (vouCharge.chargedAmount.currencyCode),
							WRBTR: ((vouCharge.chargedAmount.value) - (vouCharge.discountAmount.value default 0))
						}
					}) if (vouCharge.voucherChargeLevelCode != "TOTAL" and vouCharge.chargedAmount.value != 0)
				})
			}
		})
	}
}