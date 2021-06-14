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
var csvCol = "itemId,locationId,quantity.measurementUnitCode,quantity.value,bestBeforeDate,availableForSupplyDate,storageLocation,inventoryStatus,onHandMeasureCode,batchNumber,lotNumber,onHandPostDateTime" splitBy  ","

output application/csv encoding="UTF-8"
import lookup_utils::globalDataweaveFunctions
---
		
payload map {
    (csvCol[0]) : if (not (isEmpty($.MATNR_LONG))) $.MATNR_LONG else $.MATNR default "",
    (csvCol[1]) : $.WERKS default "",
    (csvCol[2]) : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEINS] else $.MEINS default "",
    (csvCol[3]) : globalDataweaveFunctions::moveHyphen($.QUANT default "0.000") default "",
    (csvCol[4]) : globalDataweaveFunctions::formatDate($.VFDAT default ""),
    (csvCol[5]) : globalDataweaveFunctions::formatDate($.SDATE default ""),
	(csvCol[6]) : $.LGORT default "",
    (csvCol[7]) : if (not isEmpty(vars.uomCodeMap.inventoryStausCodeMap[$.STCAT default ""])) vars.uomCodeMap.inventoryStausCodeMap[$.STCAT] else "AVAILABLE_FOR_SALE",
	(csvCol[8]) : if (not isEmpty(vars.uomCodeMap.onHandMeasureCodeList[$.STCAT default ""])) vars.uomCodeMap.onHandMeasureCodeList[$.STCAT] else "On Hand",
	(csvCol[9]) : $.CHARG default "",
	(csvCol[10]) : $.CHARG default "",
	(csvCol[11]) : now() as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"}
}