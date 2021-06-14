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
	(payload map {
			creationDateTime : now() as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
			documentStatusCode : "ORIGINAL",
			documentActionCode : "CHANGE_BY_REFRESH",
			exchangeRateType : $.KURST,
			sourceCurrency : $.FCURR,
			targetCurrency : $.TCURR,
			effectiveFromDate : globalDataweaveFunctions::formatDate($.GDATU default ""),
			sourceToTargetRatio : ((($.UKURS)*($.TFACT))/($.FFACT)) as Number
	})	
}