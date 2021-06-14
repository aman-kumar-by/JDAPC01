%dw 2.0
var csvCol = "itemId,demandChannel,locationId,priceEffectiveFromDate,priceEffectiveEndDate,retailPrice.value,retailPrice.currencyCode,priceType," splitBy  ","
output application/csv encoding="UTF-8"
import lookup_utils::globalDataweaveFunctions
---
		
(payload default [] filter ((not isEmpty($.WAERS_S)) and (not isEmpty($.STPRS))) map (priceData, index) -> using(channelData = (priceData.VKORG default "" ++ p('sap.demandChannel.delimiter') ++ priceData.VTWEG default "")) {
    (csvCol[0]) : priceData.MATNR! default "",
    (csvCol[1]) : globalDataweaveFunctions::demandChannelChk(channelData),
    (csvCol[2]) : priceData.WERKS!,
    (csvCol[3]) : "",
    (csvCol[4]) : globalDataweaveFunctions::formatDate(priceData.ENDST default ""),
    (csvCol[5]) : priceData.STPRS,
    (csvCol[6]) : priceData.WAERS_S,
	(csvCol[7]) : "PURCHASE",
	
})
++
(payload default [] filter ((not isEmpty($.WAERS_N)) and (not isEmpty($.KBETR_N))) map (priceData, index) -> using(channelData = (priceData.VKORG default "" ++ p('sap.demandChannel.delimiter') ++ priceData.VTWEG default "")) {
    (csvCol[0]) : priceData.MATNR! default "",
    (csvCol[1]) : globalDataweaveFunctions::demandChannelChk(channelData),
    (csvCol[2]) : priceData.WERKS!,
    (csvCol[3]) : globalDataweaveFunctions::formatDate(priceData.CCDAT_N default ""),
    (csvCol[4]) : globalDataweaveFunctions::formatDate(priceData.ENDST_N default ""),
    (csvCol[5]) : priceData.KBETR_N,
    (csvCol[6]) : priceData.WAERS_N,
	(csvCol[7]) : "NORMAL",
	
})
++
(payload default [] filter ((not isEmpty($.WAERS_D)) and (not isEmpty($.KBETR_D))) map (priceData, index) -> using(channelData = (priceData.VKORG default "" ++ p('sap.demandChannel.delimiter') ++ priceData.VTWEG default "")) {
    (csvCol[0]) : priceData.MATNR! default "",
    (csvCol[1]) : globalDataweaveFunctions::demandChannelChk(channelData),
    (csvCol[2]) : priceData.WERKS!,
    (csvCol[3]) : globalDataweaveFunctions::formatDate(priceData.CCDAT_D default ""),
    (csvCol[4]) : globalDataweaveFunctions::formatDate(priceData.ENDST_D default ""),
    (csvCol[5]) : priceData.KBETR_D,
    (csvCol[6]) : priceData.WAERS_D,
	(csvCol[7]) : "REDUCED",
	
})