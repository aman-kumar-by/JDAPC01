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
var deafultTimeInUTC = "T00:00:00.000+00:00"
---
{
	header : {
		sender : p('sap.sender'),
		receiver : (p("sap.receiver.productionMethod") splitBy ","),
		model : "BYDM",
		messageVersion : "BYDM 2021.2.0",
		messageId : uuid(),
		'type' : "productionRouting",
		creationDateAndTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"}
	// testMessage : false
	},
	productionRouting: ((payload groupBy(productionRoutingCriteria) -> (productionRoutingCriteria.VERID ++ productionRoutingCriteria.WERKS ++ productionRoutingCriteria.MATNR)) mapObject {
		root: {
			creationDateTime: now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
			documentStatusCode: "ORIGINAL",
			documentActionCode: "CHANGE_BY_REFRESH",
			productionRoutingId : $[0].VERID,
			item : $[0].MATNR,
			location : $[0].WERKS,
			billOfMaterialId : $[0].STLAL,
			incrementalLotQuantity : {
				value : $[0].BSTRF as Number
			},
			maximumLotQuantity : {
				value : $[0].BSTMA as Number
			},
			minimumLotQuantity : {
				value : $[0].BSTMI as Number
			},
			newSupplyPreventionDate : ((globalDataweaveFunctions::addDaysToCurrentDateTime(floor($[0].FXHOR default 0) as String))[0 to 9]),
			priority : $[0].PREIH as Number,
			splitFactor : ($[0].QUOTE)/100,
			effectiveUpToDate : globalDataweaveFunctions::formatDiscontinueDate($[0].BDATU default ""),
			effectiveFromDate : globalDataweaveFunctions::formatDate($[0].ADATU default ""),
			description : $[0].TEXT1,
			leadTime : ($[0].DZEIT as Number)*1440 as Number,
			(productionRoutingOperation: (($ distinctBy ($.VORNR) groupBy ($.VORNR)) mapObject {
				xx : {
					operationNumber : ($[0].VORNR) as Number,
					( ($ groupBy ($.ARBPL ++ $.WERKS ++ $.KAPAR)) mapObject {
						productionResource : ($ map {
								resourceId : $.ARBPL ++ $.WERKS ++ $.KAPAR,
								resourceCapacityUsageRate : $.PRATE as Number
						})
					}),
					effectiveFromDate : globalDataweaveFunctions::formatDate($[0].DATUV default ""),
					description : $[0].LTXA1,
					itemUnitOperationCost : $[0].PRKST as Number,
					operationDuration : {
						value : (if (p('production.method') == "SEQUENTIAL") ($[0].MACHN + $[0].LABOR) else if (p('production.method') == "PARALLEL") (if ($[0].MACHN >= $[0].LABOR) $[0].MACHN else $[0].LABOR) else 0) as Number,
						timeMeasurementUnitCode : if (p('production.method') == "SEQUENTIAL") (if (isEmpty($[0].MCUOM)) "MIN" else (if(not isEmpty(vars.uomCodeMap.timeMeasurementCodeMap[$[0].MCUOM default ""])) vars.uomCodeMap.timeMeasurementCodeMap[$[0].MCUOM] else $[0].MCUOM)) else if (p('production.method') == "PARALLEL") (if (($[0].MACHN >= $[0].LABOR) and (not (isEmpty($[0].MCUOM)))) (if(not isEmpty(vars.uomCodeMap.timeMeasurementCodeMap[$[0].MCUOM default ""])) vars.uomCodeMap.timeMeasurementCodeMap[$[0].MCUOM] else $[0].MCUOM) else if (($[0].MACHN < $[0].LABOR) and (not (isEmpty($[0].LBUOM)))) (if(not isEmpty(vars.uomCodeMap.timeMeasurementCodeMap[$[0].LBUOM default ""])) vars.uomCodeMap.timeMeasurementCodeMap[$[0].LBUOM] else $[0].LBUOM) else "MIN") else "MIN"
					},
					productionOffsetDuration : {
						value : $[0].SETUP as Number,
						timeMeasurementUnitCode : (if (isEmpty($[0].STUOM)) "MIN" else (if(not isEmpty(vars.uomCodeMap.timeMeasurementCodeMap[$[0].STUOM default ""])) vars.uomCodeMap.timeMeasurementCodeMap[$[0].STUOM] else $[0].STUOM))
					}
				}
			}).*xx),
			(if ($[0].BPCOM != null and $[0].BPCOM != "") (($ distinctBy ($.BPCOM)) map {
				outputYield : [{
					item : $.BPCOM,
					(if ($.BPCOF == "" or $.BPCOF == null) isByProduct : true else isByProduct : false),
					yieldFactor : $.BPCOQ as Number
				}]
			}) else {
			})
		}
	}).*root
}
