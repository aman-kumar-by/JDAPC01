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
	(p('SAP.RCVADV.IDOCTYP')) : {
		(payload.receivingAdvice map(receivingAdvice, RAIndex) -> {
			(receivingAdvice.receivingAdviceLogisticUnit.*lineItem map (idoc, IdocIndex) -> {
				(idoc distinctBy (($.lineItemNumber as String) ++ $.invoiceId) map (line,lineInd) -> {
					IDOC : {
						EDI_DC40: {
							IDOCTYP: p('SAP.RCVADV.IDOCTYP'),
							MESTYP: p('SAP.RCVADV.MESTYP'),
							SNDPOR: p('SAP.SNDPOR'),
							SNDPRT: p('SAP.SNDPRT'),
							SNDPRN: p('SAP.SNDPRN'),
							RCVPOR: p('SAP.RCVPOR'),
							RCVPRT: p('SAP.RCVPRT'),
							RCVPRN: p('SAP.RCVPRN'),
							DIRECT: 2
						},
						E1MBGMCR: {
							E1BP2017_GM_HEAD_01: {
								PSTNG_DATE: receivingAdvice.receivingDateTime as DateTime  as String {
							format : "yyyy-MM-dd"
						},
								DOC_DATE: receivingAdvice.receivingDateTime as DateTime  as String {
							format : "yyyy-MM-dd"
						},
								REF_DOC_NO: line.customerReference.entityId,
								BILL_OF_LADING: receivingAdvice.billOfLadingNumber.entityId,
								HEADER_TXT: receivingAdvice.receivingAdviceTransportInformation.transportLoadId
							},
							E1BP2017_GM_CODE: {
								GM_CODE: "01"
							},
							E1BP2017_GM_ITEM_CREATE: {
								MATERIAL: line.transactionalTradeItem.primaryId,
								PLANT: line.ownerOfTradeItem,
								STGE_LOC: receivingAdvice.inventoryReceiptInformation.costAccountId,
								BATCH: line.transactionalTradeItem.transactionalItemData.lotNumber,
								MOVE_TYPE: (if (receivingAdvice.reportingCode == "REVERSE_RECEIPT") "102" else "101"),
								STCK_TYPE: if ( not isEmpty(line.inventoryStatusType) ) vars.orgCodeMap[line.inventoryStatusType as String] else "",
								ENTRY_QNT: line.quantityReceived.value,
								ENTRY_UOM: "EA",
								ENTRY_UOM_ISO: "EA",
								MVT_IND: "B",
							    DELIV_NUMB_TO_SEARCH: leftPad(line.customerReference.entityId,10,0),
								DELIV_ITEM_TO_SEARCH: leftPad(line.customerReference.lineItemNumber,6,0)
							}
						}
					}
				})
			})
		})
	}
}