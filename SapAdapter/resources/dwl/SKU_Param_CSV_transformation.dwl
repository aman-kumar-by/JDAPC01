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
output application/json encoding="UTF-8",skipNullOn="everywhere"
import lookup_utils::globalDataweaveFunctions
---
{
    (payload default [] map {
       creationDateTime: globalDataweaveFunctions::formatDateToDateTime(globalDataweaveFunctions::formatDate($.ERSDA default "")),
        documentStatusCode: "ORIGINAL",
        documentActionCode: "CHANGE_BY_REFRESH",
        itemLocationId: {
          item: {
            primaryId : $.MATNR
          },
          location: {
            primaryId : $.WERKS
          }
        },
        statusCode : if (($.LVORM default "") == "X") "INACTIVE" else "ACTIVE",
		demandParameters : {
				unitCost :{
					value : $.PRICE as Number,
					currencyCode: p('sap.defaultCurrencyCode')
				}
		},
		effectiveInventoryParameters :
		[{
			maximumOnHandQuantity : {
				value : $.MABST as Number,
				measurementUnitCode: if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEINS] else $.MEINS
			},
			minimumSafetyStockQuantity : {
				value: $.EISLO as Number,
				measurementUnitCode: if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEINS] else $.MEINS
			}
		}],
		perishableParameters : {	
			shelfLifeDuration : {
				value: $.MHDHB as Number,
				timeMeasurementUnitCode: if(isEmpty($.IPRKZ)) "DAY" else if($.IPRKZ as Number == 1) "WEE" else if($.IPRKZ as Number == 2) "MON" else if($.IPRKZ as Number == 3) "ANN" else ""	
			},
			minimumShelfLifeDuration : {
				value: $.MHDRZ as Number,
				timeMeasurementUnitCode: if(isEmpty($.IPRKZ)) "DAY" else if($.IPRKZ as Number == 1) "WEE" else if($.IPRKZ as Number == 2) "MON" else if($.IPRKZ as Number == 3) "ANN" else ""	
			},
			minimumShipmentShelfLifeDuration : {
				value: $.MHDLP as Number,
				timeMeasurementUnitCode: if(isEmpty($.IPRKZ)) "DAY" else if($.IPRKZ as Number == 1) "WEE" else if($.IPRKZ as Number == 2) "MON" else if($.IPRKZ as Number == 3) "ANN" else ""	
			} 
		},
        planningParameters : {
        	supplyLeadBufferDuration : {
        		value: $.WEBAZ as Number,
				timeMeasurementUnitCode: "DAY"
        	},
        	(holdingCost : {
        		value : $.LOSFX as Number,
				currencyCode: p('sap.defaultCurrencyCode')
        	}) if (not isEmpty($.LOSFX)),
			incrementalDRPQuantity : {
				value: $.BSTRF as Number
			},
			incrementalMPSQuantity : {
				value: $.BSTRF as Number
			},
			maximumOnHandQuantity : {
				value: $.MABST as Number,
				measurementUnitCode: if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEINS] else $.MEINS
			},
			manufactureDuration : {
				value: $.DZEIT as Number,
				timeMeasurementUnitCode: "DAY"
			},
			minimumDRPQuantity : {
				value: $.BSTMI as Number
				},
			minimumMPSQuantity : {
				value: $.BSTMI as Number
				},
			shrinkageFactor : $.KAUSF as Number
        },
		safetyStockParameters : 
		{
			accumulationDuration : {
				value: 1 as Number,
				timeMeasurementUnitCode: if (($.PERKZ default "") == "M")
											"MON"
										else if (($.PERKZ default "") == "T")
											"DAY"
										else if (($.PERKZ default "") == "W")
											"WEE"
										else
											"DAY"
			},
			averageReplenishmentLeadDuration : {
				value: $.WZEIT as Number,
				timeMeasurementUnitCode: "DAY"
			},
			maximumSafetyStock : {
				value: $.EISBE as Number,
				measurementUnitCode: if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEINS] else $.MEINS
			},
			minimumSafetyStock : {
				value: $.EISLO as Number,
				measurementUnitCode: if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEINS] else $.MEINS
			}
		}
    })
  }