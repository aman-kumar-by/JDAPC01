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
	(p('SAP.VM.AR_IDOCTYP_ACC')) : {
		(payload.voucher map (val,key)-> {
			IDOC: {
				EDI_DC40: {
					IDOCTYP: p('SAP.VM.AR_IDOCTYP_ACC'),
					MESTYP: p('SAP.VM.AR_MESTYP_ACC'),
					SNDPOR: p('SAP.SNDPOR'),
					SNDPRT: p('SAP.SNDPRT'),
					SNDPRN: p('SAP.SNDPRN'),
					RCVPOR: p('SAP.RCVPOR'),
					RCVPRT: p('SAP.RCVPRT'),
					RCVPRN: p('SAP.RCVPRN'),
					DIRECT: 2
				},
				E1BPACHE01 : {
					OBJ_TYPE: "IDOC",
					OBJ_KEY: val.internalReferenceId.entityId,
					OBJ_SYS: "SAPCONNECT",
					USERNAME: "BLUEYONDER",
					HEADER_TXT: val.voucherId,
					COMP_CODE: if ( not isEmpty(val.organisationName) ) vars.orgCodeMap[val.organisationName as String] else "1000",
					FISC_YEAR: val.creationDateTime as Date as String {
						format : "yyyy"
					},
					DOC_DATE: val.creationDateTime as DateTime  as String {
							format : "yyyy-MM-dd"
						},
					PSTNG_DATE: val.creationDateTime as DateTime  as String {
							format : "yyyy-MM-dd"
						},
					FIS_PERIOD: val.creationDateTime as Date as String {
						format : "MM"
					},
					DOC_TYPE: "DA",
					REF_DOC_NO_LONG: val.internalReferenceId.entityId
				},
				E1BPACAR01 : {
					ITEMNO_ACC: "0000000001",
					CUSTOMER: leftPad(val.buyer.primaryId,10,0),
				},
				(val.voucherCharge distinctBy($.systemChargeDetailId) filter ($.voucherChargeLevelCode != "TOTAL" and ($.chargedAmount.value != 0 and $.chargedAmount.value != "0")) map (vouCharge,index)-> {
					(E1BPACGL01 : {
						ITEMNO_ACC: "000000000" ++(2 +(index)),
						GL_ACCOUNT: "0000145030",
						TAX_CODE: "1O"
					})
				}),
				(val.voucherCharge distinctBy($.systemChargeDetailId) filter ($.voucherChargeLevelCode == "TOTAL" and ($.chargedAmount.value != 0 and $.chargedAmount.value != "0")) map (vouChar,index)-> {
					(E1BPACCR01 : {
					ITEMNO_ACC: "000000000" ++(1 +(index)),
					CURRENCY: vouChar.chargedAmount.currencyCode,
					AMT_DOCCUR: -(vouChar.chargedAmount.value),
				})
				}),
				(val.voucherCharge distinctBy($.systemChargeDetailId) filter ($.voucherChargeLevelCode != "TOTAL" and ($.chargedAmount.value != 0 and $.chargedAmount.value != "0")) map (vouChar,index)-> {
					(E1BPACCR01 : {
					ITEMNO_ACC: "000000000" ++(2 +(index)),
					CURRENCY: vouChar.chargedAmount.currencyCode,
					AMT_DOCCUR: (vouChar.chargedAmount.value)
				})
				})
			}
		})
	}
}
