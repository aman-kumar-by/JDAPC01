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
output application/json skipNullOn="everywhere", encoding="UTF-8"
import lookup_utils::globalDataweaveFunctions
---
(payload.*IDOC default[] map (idoc, idocIndex) -> {
		creationDateTime: now() as DateTime {
			format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
		},
		documentStatusCode: "ORIGINAL",
		documentActionCode: "ADD",
		senderDocumentId: idoc.EDI_DC40.DOCNUM,
		receivingAdviceId: idoc.E1MBGMCR.E1BP2017_GM_HEAD_01.REF_DOC_NO,
		receivingDateTime: globalDataweaveFunctions::formatDateToDateTime(globalDataweaveFunctions::formatDate(idoc.E1MBGMCR.E1BP2017_GM_HEAD_01.PSTNG_DATE default "") default ""),
		reportingCode: "FULL_DETAILS",
		shipper: {
			primaryId: idoc.E1MBGMCR.E1BP2017_GM_ITEM_CREATE.VENDOR,
		},
		receiver: {
			primaryId: idoc.E1MBGMCR.E1BP2017_GM_ITEM_CREATE.PLANT
		},
		shipTo: {
			primaryId: idoc.E1MBGMCR.E1BP2017_GM_ITEM_CREATE.PLANT
		},
		shipFrom: {
			primaryId: idoc.E1MBGMCR.E1BP2017_GM_ITEM_CREATE.VENDOR
		},
		(receivingAdviceLogisticUnit: [{
			lineItem: (idoc.E1MBGMCR.*E1BP2017_GM_ITEM_CREATE map (item,index) -> {
					lineItemNumber: item.ORDER_ITNO as Number,
					quantityReceived: {
						value: item.ENTRY_QNT as Number,
						measurementUnitCode: (if ( not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[item.ENTRY_UOM_ISO default ""]) ) vars.uomCodeMap.measurementUnitCodeMap[item.ENTRY_UOM_ISO] else item.ENTRY_ISO)
					},
					quantityAccepted: {
						value: item.ENTRY_QNT as Number,
						measurementUnitCode: (if ( not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[item.ENTRY_UOM_ISO default ""]) ) vars.uomCodeMap.measurementUnitCodeMap[item.ENTRY_UOM_ISO] else item.ENTRY_ISO)
					},
					transactionalTradeItem: {
						primaryId: item.MATERIAL,
						(transactionalItemData: [{
							batchNumber: item.BATCH,
							itemExpirationDate: globalDataweaveFunctions::formatDate(item.EXPIRYDATE default ""),
							lotNumber: item.BATCH,
							productionDate: globalDataweaveFunctions::formatDate(item.PROD_DATE default "")
						}]) if (item.BATCH != null and item.BATCH != "")
					},
					(purchaseOrder: {
						entityId: item.PO_NUMBER,
						(lineItemNumber: item.PO_ITEM as Number) if (not (isEmpty (item.PO_ITEM)))
					}) if (not (isEmpty (item.PO_NUMBER)))
			})
		}])
	})