%dw 2.0
var csvCol = "itemId,demandChannel,locationId,priceEffectiveFromDate,priceEffectiveUpToDate,retailPrice,priceType,currencyCode" splitBy  ","
output application/json encoding = "UTF-8"
import lookup_utils::globalDataweaveFunctions
---
using(root = (payload default []  map ((priceData, index)  -> using ( channelData = (priceData.VKORG default "" ++ p('sap.demandChannel.delimiter') ++ priceData.VTWEG default ""))
	{
	(data: {
		(csvCol[0]) : priceData.MATNR default "",
	    (csvCol[1]) : globalDataweaveFunctions::demandChannelChk(channelData),
		(csvCol[2]) : priceData.WERKS,
		(csvCol[3]) : globalDataweaveFunctions::formatDate(priceData.CCDAT default ""),
		(csvCol[4]) : globalDataweaveFunctions::formatDate(priceData.ENDST default ""),
		(csvCol[5]): {
			value: priceData.STPRS as Number,
			currencyCode: priceData.WAERS_S
		},
		(csvCol[6]) : "PURCHASE",
	})
}
++
	{
	(data: {
		(csvCol[0]) : priceData.MATNR default "",
		(csvCol[1]) : globalDataweaveFunctions::demandChannelChk(channelData),
		(csvCol[2]) : priceData.WERKS,
		(csvCol[3]) : globalDataweaveFunctions::formatDate(priceData.CCDAT_N default ""),
		(csvCol[4]) : globalDataweaveFunctions::formatDate(priceData.ENDST_N default ""),
		(csvCol[5]) : {
			value: priceData.KBETR_N as Number,
			currencyCode: ((if ( not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[priceData.WAERS_N default ""]) ) vars.uomCodeMap.measurementUnitCodeMap[priceData.WAERS_N] else priceData.WAERS_N default ""))
		},
		(csvCol[6]) : "NORMAL",
	})
}
++
 {
	(data: {
		(csvCol[0]) : priceData.MATNR default "",
		(csvCol[1]) : globalDataweaveFunctions::demandChannelChk(channelData),
		(csvCol[2]) : priceData.WERKS,
		(csvCol[3]) : globalDataweaveFunctions::formatDate(priceData.CCDAT_D default ""),
		(csvCol[4]) : globalDataweaveFunctions::formatDate(priceData.ENDST_D default ""),
		(csvCol[5]) : {
			value: priceData.KBETR_D as Number,
			currencyCode: ((if ( not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[priceData.WAERS_D default ""]) ) vars.uomCodeMap.measurementUnitCodeMap[priceData.WAERS_D] else priceData.WAERS_D default ""))	
		},
		(csvCol[6]) : "REDUCED",
	})
})))root