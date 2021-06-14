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
var csvCol = "itemId,demandChannel,locationId,transactionCode,eventId,startDate,lastSoldDateTime,quantity.value,quantity.measurementUnitCode,totalRetailAmount.currencyCode,totalRetailAmount.value,totalRetailAmountWithTaxes.value" splitBy  ","
output application/csv
import lookup_utils::globalDataweaveFunctions
---
payload default [] map {
    (csvCol[0]) : $.MATNR default "",
    (csvCol[1]) : globalDataweaveFunctions::demandChannelChk($.VKORG default "" ++ p('sap.demandChannel.delimiter') ++ $.VTWEG default ""),
    (csvCol[2]) : $.WERKS,
    (csvCol[3]) : if(not isEmpty($.AKTNR)) (if ($.UMART == "A") "21" else "22") else if(not isEmpty($.MFCNR)) (if ($.UMART == "A") "15" else "16") else if($.UMART == "A") "11" else "12",
    (csvCol[4]) : if(not isEmpty($.AKTNR)) $.AKTNR else "",
    (csvCol[5]) : globalDataweaveFunctions::formatDate($.SPTAG default ""),
    (csvCol[6]) : if(not isEmpty(globalDataweaveFunctions::formatDate($.SPTAG))) (globalDataweaveFunctions::formatDate($.SPTAG) default "" ++ (if (not isEmpty($.EZEIT)) "T" ++ $.EZEIT[0 to 1] ++ ":" ++ $.EZEIT[2 to 3] ++ ":" ++ $.EZEIT[4 to 5] ++ "Z" else "T00:00:00Z")) else "",
    (csvCol[7]) : $.VKMNG,
	(csvCol[8]) : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.VRKME default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.VRKME] else $.VRKME default "",
	(csvCol[9]) : $.WAERK,
	(csvCol[10]) : $.UMSGVO,
	(csvCol[11]) : $.UMSGVP,
}