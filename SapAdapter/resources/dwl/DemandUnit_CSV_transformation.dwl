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
---
 {
	(payload default[] map {
			creationDateTime: now() as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
			documentStatusCode: "ORIGINAL",
			documentActionCode: "ADD",
			demandUnitId: if (not isEmpty ($.MATNR_LONG)) $.MATNR_LONG else $.MATNR,
			(demandUnitHierarchyInformation : {
				ancestry: [{
					memberId: $.PRDHA,
					hierarchyLevelId : "3"
				}],
			}) if (not (isEmpty ($.PRDHA))),
			demandUnitDetails: {
				demandUnitBaseUnitOfMeasure: if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEINS] else $.MEINS,
				description: {
					value : $.MAKTX
				},
				(handlingInstruction : {
					handlingInstructionCode : "PER"
				}) if ((lower ($.MTART default "")) == "frip")
			}
	})
}