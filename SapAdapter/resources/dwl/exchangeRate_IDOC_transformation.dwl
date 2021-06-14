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
fun checkNumber(value)=(if(value != null and value != "") ceil(value as Number) else 0)
---
(payload..*E1BP1093_0 map {
		creationDateTime : now() as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
		documentStatusCode : "ORIGINAL",
		documentActionCode : "CHANGE_BY_REFRESH",
		senderDocumentId : payload..EDI_DC40.DOCNUM[0],
		exchangeRateType : $.RATE_TYPE,
		sourceCurrency : $.FROM_CURR,
		targetCurrency : $.TO_CURRNCY,
		effectiveFromDate : globalDataweaveFunctions::formatDate($.VALID_FROM default ""),
		sourceToTargetRatio : if ((checkNumber($.EXCH_RATE_V)) != 0) ((($.EXCH_RATE_V)*($.FROM_FACTOR_V))/($.TO_FACTOR_V)) as Number else ((($.EXCH_RATE)*($.TO_FACTOR))/($.FROM_FACTOR)) as Number
	})