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
		itemId: $.MATNR,
		demandChannel: globalDataweaveFunctions::demandChannelChk($.VKORG default "" ++ p('sap.demandChannel.delimiter') ++ $.VTWEG default ""),
		locationId: $.WERKS,
		transactionCode: (if ( not isEmpty($.AKTNR) ) (if ( $.UMART == "A" ) "21" else "22") else if ( not isEmpty($.MFCNR) ) (if ( $.UMART == "A" ) "15" else "16") else if ( $.UMART == "A" ) "11" else "12"),
		eventId: (if ( not isEmpty($.AKTNR) ) $.AKTNR else ""),
		startDate: (globalDataweaveFunctions::formatDate($.SPTAG default "")),
		lastSoldDateTime: (globalDataweaveFunctions::formatDate($.SPTAG default "")) ++  (if ( not isEmpty($.EZEIT) ) "T" ++ $.EZEIT[0 to 1] ++ ":" ++ (if ( not isEmpty($.EZEIT[2 to 3]) ) $.EZEIT[2 to 3] else "00") ++ ":" ++ (if ( not isEmpty($.EZEIT[4 to 5]) ) $.EZEIT[4 to 5] else "00") ++ "Z" else "T00:00:00Z"),
		(quantity: {
			measurementUnitCode: ((if ( not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.VRKME default ""]) ) vars.uomCodeMap.measurementUnitCodeMap[$.VRKME] else $.VRKME default "")),
			value: $.VKMNG as Number
		}) if ($.VKMNG != null and $.VKMNG != ""),
		(totalRetailAmount: {
			currencyCode: $.WAERK,
			value: $.UMSGVO as Number
		}) if ($.WAERK != null and $.WAERK != ""),
		(totalRetailAmountWithTaxes: {
			value: $.UMSGVP as Number
		}) if ($.UMSGVP != null and $.UMSGVP != "")
	})
}