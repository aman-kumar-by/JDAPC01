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
{
	(payload map(record, index) -> {
					creationDateTime : (globalDataweaveFunctions::formatDate(record.ERDAT default "") ++ 'T' ++ (if (sizeOf(record.ERZET) == 6) globalDataweaveFunctions::timeConversion(record.ERZET) 
																		else if (sizeOf(record.ERZET) == 5) globalDataweaveFunctions::timeConversion("0" ++ record.ERZET) 
																		else if (sizeOf(record.ERZET) == 4) globalDataweaveFunctions::timeConversion("00" ++ record.ERZET) 
																		else if (sizeOf(record.ERZET) == 3) globalDataweaveFunctions::timeConversion("000" ++ record.ERZET) 
																		else if (sizeOf(record.ERZET) == 2) globalDataweaveFunctions::timeConversion("0000" ++ record.ERZET) 
																		else if (sizeOf(record.ERZET) == 1) globalDataweaveFunctions::timeConversion("00000" ++ record.ERZET) 
																		else globalDataweaveFunctions::timeConversion("000000"))),
			documentStatusCode : "ORIGINAL",
			documentActionCode : "ADD",
			transportInstructionId : record.VBELN,
			transportInstructionFunction : "SHIPMENT",
			logisticServicesSeller : {
				primaryId : record.VKORG
			},
			logisticServicesBuyer : {
				primaryId : record.KUNNR
			},
			shipment : [{
				//gsin : "00000000000000000",
				customerCode : record.KUNNR,
				shipperName : record.VTEXT,
				receiverName : record.NAME1,
				actualShipDateTime : (globalDataweaveFunctions::formatDate(record.WADAT_IST default "") ++ 'T' ++ (if (sizeOf(record.SPE_WAUHR_IST) == 6) globalDataweaveFunctions::timeConversion(record.SPE_WAUHR_IST) 
																							else if (sizeOf(record.SPE_WAUHR_IST) == 5) globalDataweaveFunctions::timeConversion("0" ++ record.SPE_WAUHR_IST) 
																							else if (sizeOf(record.SPE_WAUHR_IST) == 4) globalDataweaveFunctions::timeConversion("00" ++ record.SPE_WAUHR_IST) 
																							else if (sizeOf(record.SPE_WAUHR_IST) == 3) globalDataweaveFunctions::timeConversion("000" ++ record.SPE_WAUHR_IST) 
																							else if (sizeOf(record.SPE_WAUHR_IST) == 2) globalDataweaveFunctions::timeConversion("0000" ++ record.SPE_WAUHR_IST) 
																							else if (sizeOf(record.SPE_WAUHR_IST) == 1) globalDataweaveFunctions::timeConversion("00000" ++ record.SPE_WAUHR_IST) 
																							else globalDataweaveFunctions::timeConversion("000000"))),
	            shippingInformation : {
				(if (record.AUTLF == "X") shipmentSplitMethod : "NO_SPLIT" else shipmentSplitMethod : "DETAIL_LEVEL"),
				holdShipment : if (not isEmpty (record.LIFSK)) true else false,
				},
				primaryId : record.VBELN,
				receiver : {
					primaryId : record.KUNNR
				},
				shipper : {
					primaryId : record.VKORG,
				    organisationName : record.VTEXT
				},
				shipTo : {
					primaryId : record.NAME1
				},
				shipFrom : {
					primaryId : record.VSTEL
				},
				transportInstructionTerms : {
					transportServiceCategoryType : "30"
				},
				transportCargoCharacteristics : {
					cargoTypeCode : "12"
				},
				plannedDelivery : {
					logisticEventPeriod : {
						beginDate : globalDataweaveFunctions::formatDate(record.WADAT default ""),
						beginTime : "00:01:00",
						endDate : globalDataweaveFunctions::formatDate(record.WADAT default ""),
						endTime : "23:59:00"
					}
				},
				plannedDespatch : {
					logisticEventDateTime  : {
						date : globalDataweaveFunctions::formatDate(record.WADAT default "")
					}
				},
				(if (record.BOLNR != null and record.BOLNR != "") transportReference : [{
					entityId : record.BOLNR,
					typeCode : "BM"
				}] else {
				}),
				shipmentItem : [{
					lineItemNumber : record.POSNR as Number,
					itemName : record.ARKTX,
					transactionalTradeItem : [{
						//gtin : "00000000000000",
						primaryId : record.MATNR,
						tradeItemQuantity : {
						value : record.LFIMG as Number,
						measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[record.VRKME default ""])) vars.uomCodeMap.measurementUnitCodeMap[record.VRKME] else record.VRKME
						},
						tradeItemDescription : {
						value : record.ARKTX,
						languageCode : "en"
						},
						transactionalItemData : [{
							batchNumber : if (not isEmpty (record.CHARG)) record.CHARG else "",
							countryOfOrigin : record.SPE_HERKL
						}]
					}],
					transportCargoCharacteristics : {
						cargoTypeCode : "12",
						totalGrossWeight : {
						value : record.BRGEW as Number,
						measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[record.GEWEI default ""])) vars.uomCodeMap.measurementUnitCodeMap[record.GEWEI] else record.GEWEI
						}
					},
					(if (record.VGBEL != null and record.VGBEL != "") transportReference : [{
						entityId : record.VGBEL,
						lineItemNumber : record.VGPOS as Number,
						typeCode : "ON"
					}] else {
					})
				}]
			}]
	})
}