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
	(payload default[] map (record, index) -> {
		creationDateTime: now() as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
		documentStatusCode : "ORIGINAL",
		documentActionCode : "CHANGE_BY_REFRESH",
		promotionId : record.AKTNR,
		name : record.AKTNR,
		description : {
			value : record.AKTKT
		},
		effectiveFromDate : globalDataweaveFunctions::formatDate(record.VKDAB default ""),
		effectiveUpToDate : globalDataweaveFunctions::formatDiscontinueDate(record.VKDBI default ""),
		promotionTypeCode : record.AKART,
		eligibilityInformation : [
		{
			actionCode : if(record.DFUFLAG == "ADD") "ADD" else if (record.DFUFLAG == "UPDATE") "CHANGE" else "CHANGE",
			item : {
				itemId : record.ARTNR
			},
			location : {
				locationId : record.WERKS
			},
			demandChannel : record.VKORG default "" ++ p("sap.demandChannel.delimiter") ++ record.VTWEG default "",
			forecastMethod : 0,
			marketingStrategyName : record.AKART,
			marketingStrategyAttribute : record.MEDIA_TYPE,
			leadTime : {
				value : record.AKLIZ as Number ,
				timeMeasurementUnitCode : "DAY"
			},
			financialInformation : {
				(vendorCost : {
					value : record.NETPR as Number,
					currencyCode : record.WAELA
				}) if record.NETPR != null and record.NETPR != "",
				(retailCost : {
					value : record.PLEKP as Number,
					currencyCode : record.WAELA
				})if record.PLEKP != null and record.PLEKP != "",
				(promotionRetailPrice : {
					value : record.PLVKP as Number,
					currencyCode : record.WAELA
				})if record.PLVKP != null and record.PLVKP != "",
				(effectivePrice : {
					value : record.PLVKP as Number,
					currencyCode : record.WAELA
				})if record.PLVKP != null and record.PLVKP != "",
				useRetailPrice : false
			},
			effectiveFromDate : globalDataweaveFunctions::formatDate(record.VKDAB default ""),
			effectiveUpToDate : globalDataweaveFunctions::formatDiscontinueDate(record.VKDBI default "")
		} 
        ]
	})
}