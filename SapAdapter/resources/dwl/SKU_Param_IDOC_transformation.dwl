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
output application/json skipNullOn = "everywhere", encoding = "UTF-8"
import lookup_utils::globalDataweaveFunctions
---
({
	(payload.*IDOC default [] map (idoc, index) -> {
		root: (idoc.E1MARAM.*E1MARCM map (e1marcm,e1marcm_index) -> {
			creationDateTime: globalDataweaveFunctions::formatDateToDateTime(globalDataweaveFunctions::formatDate(idoc.E1MARAM.ERSDA default "")),
			documentStatusCode: "ORIGINAL",
			documentActionCode: if ( ((e1marcm.LVORM) default "") == "X" ) "DELETE"
           else if ( (idoc.E1MARAM.LVORM default "") == "X" ) "DELETE"
          else if ( (e1marcm.MSGFN default "") == "009" ) "ADD"
          else
            "CHANGE_BY_REFRESH",
			(lastUpdateDateTime: if ( (idoc.E1MARAM.LAEDA default "")!= '00000000' ) globalDataweaveFunctions::formatDateToDateTime(globalDataweaveFunctions::formatDate(idoc.E1MARAM.LAEDA default "")) else "") if (not (vars.isCSV == "true")),
			senderDocumentId: idoc.EDI_DC40.DOCNUM,
			itemLocationId: {
				item: {
					primaryId: idoc.E1MARAM.MATNR
				},
				location: {
					primaryId: e1marcm.WERKS
				}
			},
			statusCode: if ( ((idoc.E1MARAM.LVORM default "") == "X") or (((e1marcm.LVORM) default "") == "X") ) "INACTIVE" else "ACTIVE",
			effectiveUpToDate: if ( ((e1marcm.LVORM) default "") == "X" ) globalDataweaveFunctions::formatDiscontinueDate(idoc.EDI_DC40.CREDAT default "") else "",
			demandParameters: {
				(idoc.E1MARAM.*E1MBEWM map (e1mbewm,e1mbewm_index) ->{
					(unitCost: {
						(if ( e1mbewm.VPRSV == 'S' ) {
							value: e1mbewm.STPRS as Number,
							currencyCode: p('sap.defaultCurrencyCode')
						}
	         else {
							value: e1mbewm.VERPR as Number,
							currencyCode: p('sap.defaultCurrencyCode')
						})
					}) if (e1mbewm.BWKEY == e1marcm.WERKS)
				})
			},
			effectiveInventoryParameters: [{
				maximumOnHandQuantity: {
					value: e1marcm.MABST as Number,
					measurementUnitCode: if ( not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[idoc.E1MARAM.MEINS default ""]) ) vars.uomCodeMap.measurementUnitCodeMap[idoc.E1MARAM.MEINS] else idoc.E1MARAM.MEINS
				},
				minimumSafetyStockQuantity: {
					value: e1marcm.EISLO as Number,
					measurementUnitCode: if ( not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[idoc.E1MARAM.MEINS default ""]) ) vars.uomCodeMap.measurementUnitCodeMap[idoc.E1MARAM.MEINS] else idoc.E1MARAM.MEINS
				}
			}],
			perishableParameters: {
				(shelfLifeDuration: {
					value: idoc.E1MARAM.MHDHB as Number,
					timeMeasurementUnitCode: if ( isEmpty(idoc.E1MARAM.IPRKZ) ) "DAY" else if ( idoc.E1MARAM.IPRKZ as Number == 1 ) "WEE" else if ( idoc.E1MARAM.IPRKZ as Number == 2 ) "MON" else if ( idoc.E1MARAM.IPRKZ as Number == 3 ) "ANN" else ""
				}) if (idoc.E1MARAM.MHDHB != null and idoc.E1MARAM.MHDHB != "" and idoc.E1MARAM.MHDHB != "0"),
				(minimumShelfLifeDuration: {
					value: idoc.E1MARAM.MHDRZ as Number,
					timeMeasurementUnitCode: if ( isEmpty(idoc.E1MARAM.IPRKZ) ) "DAY" else if ( idoc.E1MARAM.IPRKZ as Number == 1 ) "WEE" else if ( idoc.E1MARAM.IPRKZ as Number == 2 ) "MON" else if ( idoc.E1MARAM.IPRKZ as Number == 3 ) "ANN" else ""
				}) if (idoc.E1MARAM.MHDRZ != null and idoc.E1MARAM.MHDRZ != "" and idoc.E1MARAM.MHDRZ != "0"),
				(minimumShipmentShelfLifeDuration: {
					value: idoc.E1MARAM.MHDLP as Number,
					timeMeasurementUnitCode: if ( isEmpty(idoc.E1MARAM.IPRKZ) ) "DAY" else if ( idoc.E1MARAM.IPRKZ as Number == 1 ) "WEE" else if ( idoc.E1MARAM.IPRKZ as Number == 2 ) "MON" else if ( idoc.E1MARAM.IPRKZ as Number == 3 ) "ANN" else ""
				}) if (idoc.E1MARAM.MHDLP != null and idoc.E1MARAM.MHDLP != "" and idoc.E1MARAM.MHDLP != "0")
			},
			planningParameters: {
				supplyLeadBufferDuration: {
					value: e1marcm.WEBAZ as Number,
					timeMeasurementUnitCode: "DAY"
				},
				(holdingCost: {
					value: e1marcm.LOSFX as Number,
					"currencyCode": p('sap.defaultCurrencyCode')
				}) if (not isEmpty(e1marcm.LOSFX)),
				incrementalDRPQuantity: {
					value: e1marcm.BSTRF as Number
				},
				incrementalMPSQuantity: {
					value: e1marcm.BSTRF as Number
				},
				maximumOnHandQuantity: {
					value: e1marcm.MABST as Number,
					measurementUnitCode: if ( not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[idoc.E1MARAM.MEINS default ""]) ) vars.uomCodeMap.measurementUnitCodeMap[idoc.E1MARAM.MEINS] else idoc.E1MARAM.MEINS
				},
				manufactureDuration: {
					value: e1marcm.DZEIT as Number,
					timeMeasurementUnitCode: "DAY"
				},
				minimumDRPQuantity: {
					value: e1marcm.BSTMI as Number
				},
				minimumMPSQuantity: {
					value: e1marcm.BSTMI as Number
				},
				shrinkageFactor: e1marcm.KAUSF as Number
			},
			safetyStockParameters: {
				accumulationDuration: {
					value: 1 as Number,
					timeMeasurementUnitCode: if ( ((e1marcm.PERKZ) default "") == "M" ) "MON"
          else if ( (e1marcm.PERKZ default "") == "T" ) "DAY"
          else if ( (e1marcm.PERKZ default "") == "W" ) "WEE"
            else "DAY"
				},
				averageReplenishmentLeadDuration: {
					value: e1marcm.WZEIT as Number,
					timeMeasurementUnitCode: "DAY"
				},
				maximumSafetyStock: {
					value: e1marcm.EISBE as Number,
					measurementUnitCode: if ( not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[idoc.E1MARAM.MEINS default ""]) ) vars.uomCodeMap.measurementUnitCodeMap[idoc.E1MARAM.MEINS] else idoc.E1MARAM.MEINS
				},
				minimumSafetyStock: {
					value: e1marcm.EISLO as Number,
					measurementUnitCode: if ( not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[idoc.E1MARAM.MEINS default ""]) ) vars.uomCodeMap.measurementUnitCodeMap[idoc.E1MARAM.MEINS] else idoc.E1MARAM.MEINS
				}
			}
		})
	})
}).root