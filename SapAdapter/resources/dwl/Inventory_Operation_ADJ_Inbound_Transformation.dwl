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
	(p('SAP.INVOPR.IDOCTYP')) : {
		(payload.inventoryOperation map(inventoryOperation, IOIndex) -> using (
			entryVal = (inventoryOperation.inventoryInformation.*inventoryDetails.*adjustmentQuantity)[0].value
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
						REF_DOC_NO: inventoryOperation.reason,
						HEADER_TXT: inventoryOperation.transactionType
					},
					E1BP2017_GM_CODE: {
						GM_CODE: "03"
					},
					E1BP2017_GM_ITEM_CREATE: {
						MATERIAL: (inventoryOperation.inventoryInformation.itemInformation.itemId.primaryId)[0],
						PLANT: (inventoryOperation.inventoryInformation.itemInformation.ownerOfTradeItem.primaryId)[0],
						STGE_LOC: inventoryOperation.inventoryInformation.inventoryDetails.costAccountId,
						BATCH: (inventoryOperation.inventoryInformation.itemInformation.lotNumber),
						MOVE_TYPE: ((vars.reasonCodeMap[inventoryOperation.reason]) splitBy ",")[0],
						ENTRY_QNT: (if(entryVal < 0) ((entryVal)*(-1)) else entryVal),
						ENTRY_UOM: "EA",
						ENTRY_UOM_ISO: "EA",
						COSTCENTER: ((vars.reasonCodeMap[inventoryOperation.reason]) splitBy ",")[1]
					}
				}
			}
		})
	}
}