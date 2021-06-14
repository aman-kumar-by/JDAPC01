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
output application/json encoding="UTF-8", skipNullOn="everywhere"
import lookup_utils::globalDataweaveFunctions
---
{
	(payload default [] map using(channelData = ($.VKORG default "" ++ p('sap.demandChannel.delimiter') ++ $.VTWEG default "")) {
	
			creationDateTime : now() as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
			documentStatusCode : "ORIGINAL",
			documentActionCode : "CHANGE_BY_REFRESH",
			demandForecastUnitId : {
				demandUnit : $.MATNR,
				demandChannel : globalDataweaveFunctions::demandChannelChk(channelData),
				location : {
					primaryId: $.WERKS,
				}
			},
			effectiveUpToDate : globalDataweaveFunctions::formatDiscontinueDate($.MSTDV default ""),
			isNewProductIntroduction : false,
			isObsolete : if ((upper($.LVORM) == "X") or (upper($.LVORM_W) == "X") or (upper($.LVORM_V) == "X")) true else false
		}
	)
}