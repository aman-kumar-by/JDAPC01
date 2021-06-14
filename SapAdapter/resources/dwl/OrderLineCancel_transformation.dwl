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
var rootElement = if(payload.orderRelease == null) payload.transferOrder else payload.orderRelease
---
{
	(p('inbound.orderLineCancel.idocType')) : {
		(rootElement map(val,key) -> {
			IDOC: {
				EDI_DC40: {
					DIRECT : 2,
					IDOCTYP : p('SAP.ORDCNL.IDOCTYP'),
					MESTYP : p('SAP.ORDCNL.MESTYP'),
					SNDPOR: p('SAP.SNDPOR'),
					SNDPRT: p('SAP.SNDPRT'),
					SNDPRN: p('SAP.SNDPRN'),
					RCVPOR: p('SAP.RCVPOR'),
					RCVPRT: p('SAP.RCVPRT'),
					RCVPRN: p('SAP.RCVPRN')
				},
				E1SHP_OBDLV_CHANGE : {
					DELIVERY : leftPad(val.orderId,10,0),
					E1BPOBDLVHDRCHG : {
						DELIV_NUMB : leftPad(val.orderId,10,0)
					},
					(if ((rootElement.documentActionCode)[0] == "CANCEL" and (rootElement)[0].lineItem.actionCode == null) E1BPOBDLVHDRCTRLCHG : {
						DELIV_NUMB : leftPad(val.orderId,10,0),
						DLV_DEL : "X"
					} else {
					}),
					E1BPDLVPARTNERCHG: {
						DELIV_NUMB : leftPad(val.orderId,10,0),
						PARTN_ROLE : "WE"
					},
					(val.lineItem map(ordline,ind) ->{
						E1BPOBDLVITEMCHG: {
							DELIV_NUMB : leftPad(val.orderId,10,0),
							DELIV_ITEM : leftPad(ordline.lineItemNumber,6,0),
							FACT_UNIT_NOM : "1",
							FACT_UNIT_DENOM : "1"
						},
						(if ((rootElement.documentActionCode)[0] == "PARTIAL_CHANGE" and ordline.actionCode == "CANCEL") E1BPOBDLVITEMCTRLCHG : {
						DELIV_NUMB : leftPad(val.orderId,10,0),
							DELIV_ITEM : leftPad(ordline.lineItemNumber,6,0),
							DEL_ITEM : "X"
					}  else {
					})
					})
				}
			}
		})
	}
}