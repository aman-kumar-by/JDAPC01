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
    (payload default[] map {
			creationDateTime :  now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
			documentStatusCode : "ORIGINAL",
			documentActionCode : "CHANGE_BY_REFRESH",
			itemBatchId : {
				itemId : {
					primaryId : $.MATNR
				},
				batchNumber : $.CHARG
			},
			status : [{
				statusCode : if ((upper($.ZUSTD default "")) == "X") "INACTIVE" else "ACTIVE"
			}],
			totalLotCount : 1,
			itemBatchLotDetail : [
				{
					lotNumber : $.CHARG,
					productionDate : globalDataweaveFunctions::formatDate($.HSDAT default ""),
					lotExpirationDate : globalDataweaveFunctions::formatDate($.VFDAT default ""),
					countryOfOrigin : $.HERKL,
					(shelfLife : {
						(value : ($.MHDHB as Number)) if ($.MHDHB != null and $.MHDHB != "" and $.MHDHB != "0"),
						timeMeasurementUnitCode : if (not isEmpty(vars.uomCodeMap.timeMeasurementCodeMap[$.IPRKZ default ""])) vars.uomCodeMap.timeMeasurementCodeMap[$.IPRKZ] else $.IPRKZ
					}) if ($.MHDHB != null and $.MHDHB != "" and $.MHDHB != "0"),
					inventoryStatusCode : if (not isEmpty(vars.uomCodeMap.inventoryStausCodeMap[$.STCAT default ""])) vars.uomCodeMap.inventoryStausCodeMap[$.STCAT] else "AVAILABLE_FOR_SALE",
					tradeItemQuantity :{
						value : (globalDataweaveFunctions::moveHyphen($.QUANT default "0.000") as Number),
						measurementUnitCode: if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEINS] else $.MEINS
					}
				}]
	})
}