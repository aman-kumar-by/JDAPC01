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
output application/json encoding = "UTF-8",skipNullOn = "everywhere"
import lookup_utils::globalDataweaveFunctions
---
{
	itemHierarchyLevelMember :
		(payload.*IDOC.E1WAH01.*E1WAH02 default [] map (e1wah02, index) -> {
			creationDateTime: now() as DateTime {
				format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
			},
			documentStatusCode: "ORIGINAL",
			documentActionCode: "CHANGE_BY_REFRESH",
			itemHierarchyLevelMemberId: e1wah02.NODE,
			itemHierarchyInformation: {
				(memberName: e1wah02.E1WAH05.LTEXT) if (e1wah02.E1WAH05.SPRAS_ISO == 'EN'),
				hierarchyLevelId: e1wah02.TREE_LEVEL,
				(ancestry: [{
					hierarchyLevelId: e1wah02.TREE_LEVEL,
					memberId: e1wah02.PARENT
				}]) if (e1wah02.PARENT != null and e1wah02.PARENT != "")
			}
		})
}