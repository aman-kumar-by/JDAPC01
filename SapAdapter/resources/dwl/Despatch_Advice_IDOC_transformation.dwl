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
(payload.*IDOC map {
			creationDateTime: now() as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
			documentStatusCode: "ORIGINAL",
			documentActionCode: "ADD",
			orderReferenceType: (if ($.E1EDL20.LIFEX == null) "PW" else "TO"),
			despatchAdviceId: $.E1EDL20.VBELN,
			receiver: {
				primaryId: (($.E1EDL20.*E1ADRM1 filter ($.PARTNER_Q  == "OSP"))[0].PARTNER_ID replace /^0+/ with "")
			},
			shipper: {
				primaryId: "UNKNOWN"
			},
			shipTo : {
				primaryId: ($.E1EDL20.*E1EDL24.WERKS)[0],
				additionalPartyId : [{
					typeCode : "FOR_INTERNAL_USE_1",
					value : vars.plantCodeMap[($.E1EDL20.*E1EDL24.WERKS)[0]]
				}],
			},
			despatchInformation: {
				(($.E1EDL20.*E1EDT13) filter ($.QUALF == "015") map {
					actualShipDateTime : (globalDataweaveFunctions::formatDate($.NTANF default "")) ++ "T" ++ (globalDataweaveFunctions::timeConversion("000000"))}),
				(($.E1EDL20.*E1EDT13) filter ($.QUALF == "007") map {
					estimatedDeliveryDateTime : (globalDataweaveFunctions::formatDate($.NTANF default "")) ++ "T" ++ (globalDataweaveFunctions::timeConversion("000000"))})
			},
			despatchAdviceTransportInformation: {
				transportLoadId: $.E1EDL20.BOLNR,
				billOfLadingNumber: {
					entityId: $.E1EDL20.BOLNR
				},
				shipmentId: {
					primaryId: $.E1EDL20.VBELN
				}
			},
			(if(not isEmpty($.E1EDL20.*E1EDL37)) {
				despatchAdviceLogisticUnit: ($.E1EDL20.*E1EDL37 map(logisticUnit,index) -> {
					levelId: 2,
					logisticUnitId: {
						primaryId: logisticUnit.EXIDV2
					},
					lineItem : (logisticUnit.*E1EDL44 filter ($.VELIN == "1") map(lineItem,index) -> using (
						measureValue = ($.E1EDL20.*E1EDL24 filter ($.POSNR   == lineItem.POSNR))[0].BRGEW,
						measureCode = ($.E1EDL20.*E1EDL24 filter ($.POSNR   == lineItem.POSNR))[0].GEWEI,
						lineNumber = ($.E1EDL20.*E1EDL24 filter ($.POSNR   == lineItem.POSNR or $.POSEX   == lineItem.POSNR))[0].POSEX,
						lineNumLif = ($.E1EDL20.*E1EDL24 filter ($.POSNR   == lineItem.POSNR or $.POSEX   == lineItem.POSNR))[0].POSNR
					) {
						lineItemNumber : lineItem.POSNR as Number,
						itemOwner : {
							primaryId : (($.E1EDL20.*E1ADRM1 filter ($.PARTNER_Q  == "OSP"))[0].PARTNER_ID replace /^0+/ with "")
						},
						despatchedQuantity : {
							value : lineItem.VEMNG as Number,
							measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[lineItem.VEMEH default ""])) vars.uomCodeMap.measurementUnitCodeMap[lineItem.VEMEH] else lineItem.VEMEH
						},
						transactionalTradeItem : {
							primaryId : lineItem.MATNR,
							transactionalItemData: [{
								lotNumber: lineItem.CHARG
							}]
						},
						customerReference: {
							entityId: (if ($.E1EDL20.LIFEX != null and ($.E1EDL20.LIFEX as Number != 0)) $.E1EDL20.LIFEX else $.E1EDL20.VBELN),
							lineItemNumber: (if (lineNumber != null and (lineNumber as Number != 0)) (lineNumber as Number) else (lineNumLif as Number))
						},
						purchaseOrder: {
							entityId: (if ($.E1EDL20.LIFEX != null) $.E1EDL20.LIFEX else ($.E1EDL20.*E1EDL24.*E1EDL43 filter ($.QUALF  == "V"))[0].BELNR),
						},
						transactionalReference: [{
							entityId: (if ($.E1EDL20.LIFEX != null and ($.E1EDL20.LIFEX as Number != 0)) $.E1EDL20.LIFEX else $.E1EDL20.VBELN),
							transactionalReferenceTypeCode: "SRN"
						}]
					})
				})	
			} else {
				despatchAdviceLogisticUnit: ($.E1EDL20.*E1EDL24 map(lineItem,index) -> using (
						measureValue = ($.E1EDL20.*E1EDL24 filter ($.POSNR   == lineItem.POSNR))[0].BRGEW,
						measureCode = ($.E1EDL20.*E1EDL24 filter ($.POSNR   == lineItem.POSNR))[0].GEWEI
					){
					lineItem : [{
						lineItemNumber : lineItem.POSNR as Number,
						itemOwner : {
							primaryId : (($.E1EDL20.*E1ADRM1 filter ($.PARTNER_Q  == "OSP"))[0].PARTNER_ID replace /^0+/ with "")
						},
						despatchedQuantity : {
							value : lineItem.LGMNG as Number,
							measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[lineItem.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[lineItem.MEINS] else lineItem.MEINS
						},
						transactionalTradeItem : {
							primaryId : lineItem.MATNR,
							transactionalItemData: [{
								lotNumber: lineItem.CHARG
							}]
						},
						customerReference: {
							entityId: (if ($.E1EDL20.LIFEX != null and ($.E1EDL20.LIFEX as Number != 0)) $.E1EDL20.LIFEX else $.E1EDL20.VBELN),
							lineItemNumber: (if (lineItem.POSEX != null and (lineItem.POSEX as Number != 0)) (lineItem.POSEX as Number) else (lineItem.POSNR as Number))
						},
						purchaseOrder: {
							entityId: (if ($.E1EDL20.LIFEX != null) $.E1EDL20.LIFEX else ($.E1EDL20.*E1EDL24.*E1EDL43 filter ($.QUALF  == "V"))[0].BELNR),
						},
						transactionalReference: [{
							entityId: (if ($.E1EDL20.LIFEX != null and ($.E1EDL20.LIFEX as Number != 0)) $.E1EDL20.LIFEX else $.E1EDL20.VBELN),
							transactionalReferenceTypeCode: "SRN"
						}]
					}]
				})
			}),
			
			shipment: {
				assetInformation: [{
					assetType: ($.E1EDL20.*E1EDL37.VEBEZ)[0]
				}]
			}
	})