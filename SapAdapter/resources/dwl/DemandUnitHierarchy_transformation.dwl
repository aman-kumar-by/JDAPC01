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
	(payload default [] map (idoc, index) -> {
			creationDateTime: now() as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
			documentStatusCode: "ORIGINAL",
			documentActionCode: "CHANGE_BY_REFRESH",
			itemHierarchyLevelMemberId: idoc.PRODH,
			itemHierarchyInformation : {
				memberName: idoc.VTEXT,
				hierarchyLevelId: idoc.STUFE,
				(ancestry: [{
					hierarchyLevelId: idoc."STUFE_1",
					memberId: idoc."PRODH_1",
					memberName: idoc."VTEXT_1"
				}]) if (idoc."PRODH_1" != null and idoc."PRODH_1" != "")
		}
	})
}