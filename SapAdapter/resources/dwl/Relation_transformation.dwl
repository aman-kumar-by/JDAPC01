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
			documentActionCode : "ADD",
			relationId : {
				relationId : ($.MATWA default "") ++ "_" ++ ($.SMATN default ""),
				relationType : "SUPERSESSION"   
			},
			relatedComponent : [ 
				{
				componentType : "ITEM",
                relatedFrom : $.MATWA,
				relatedTo : $.SMATN
			  }
			],
			effectiveFromDate : globalDataweaveFunctions::formatDate($.DATAB default ""),
			effectiveUpToDate : globalDataweaveFunctions::formatDate($.DATBI default "")
	})
}
