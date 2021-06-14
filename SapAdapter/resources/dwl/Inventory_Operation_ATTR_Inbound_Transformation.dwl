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
	(p('SAP.INVOPR.IDOCTYP')) : {
		(payload.inventoryOperation map(inventoryOperation, IOIndex) -> using (
             status = inventoryOperation.inventoryInformation.*inventoryDetails.inventoryStatusType,
            fVal = (inventoryOperation.inventoryInformation.*inventoryDetails filter ($.inventoryStatusType == status[0])).*adjustmentQuantity.value,
            nVal = (inventoryOperation.inventoryInformation.*inventoryDetails filter ($.inventoryStatusType == status[1])).*adjustmentQuantity.value,
			pCostId = (inventoryOperation.inventoryInformation.*inventoryDetails filter ($.adjustmentQuantity.value as Number > 0)).costAccountId,
            nCostId = (inventoryOperation.inventoryInformation.*inventoryDetails filter ($.adjustmentQuantity.value as Number < 0)).costAccountId,
            plant = if ((inventoryOperation.inventoryInformation.*inventoryDetails.adjustmentQuantity.value)[0] < 0) (inventoryOperation.inventoryInformation.itemInformation.ownerOfTradeItem.primaryId)[0] else (inventoryOperation.inventoryInformation.itemInformation.ownerOfTradeItem.primaryId)[1],
            movePlant = if ((inventoryOperation.inventoryInformation.*inventoryDetails.adjustmentQuantity.value)[0] > 0) (inventoryOperation.inventoryInformation.itemInformation.ownerOfTradeItem.primaryId)[0] else (inventoryOperation.inventoryInformation.itemInformation.ownerOfTradeItem.primaryId)[1]
            ) {
			IDOC: {
				EDI_DC40: {
					IDOCTYP: p('SAP.INVOPR.IDOCTYP'),
					MESTYP: p('SAP.INVOPR.MESTYP'),
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
						PSTNG_DATE: inventoryOperation.creationDateTime as DateTime  as String {
							format : "yyyy-MM-dd"
						},
						DOC_DATE: inventoryOperation.creationDateTime as DateTime  as String {
							format : "yyyy-MM-dd"
						},
						REF_DOC_NO: inventoryOperation.transactionType,
						HEADER_TXT: inventoryOperation.transactionType
					},
					E1BP2017_GM_CODE: {
						GM_CODE: "04"
					},
					E1BP2017_GM_ITEM_CREATE: {
						MATERIAL: (inventoryOperation.inventoryInformation.itemInformation.itemId.primaryId)[0],
						PLANT: plant,
						STGE_LOC: nCostId,
						BATCH: (inventoryOperation.inventoryInformation.itemInformation.lotNumber)[0],
						MOVE_TYPE: "301",
						VENDOR: leftPad(("P" ++ plant),10,0),
						ENTRY_QNT: (inventoryOperation.inventoryInformation.*inventoryDetails.*adjustmentQuantity filter ($.value > 0))[0].value,
						ENTRY_UOM: "EA",
						ENTRY_UOM_ISO: "EA",
						//COSTCENTER: ((vars.reasonCodeMap[inventoryOperation.reason]) splitBy ",")[1],
						MOVE_PLANT: movePlant,
						MOVE_STLOC : pCostId
						
					}
				}
			}
		})
	}
}        