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
(payload.*IDOC default [] map (idoc, index) -> {
			creationDateTime: now() as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
			documentStatusCode: "ORIGINAL",
			documentActionCode : if (upper(idoc.E1MARAM.LVORM default "") == "X") "DELETE" else if (idoc.E1MARAM.MSGFN == "009") "ADD" else "CHANGE_BY_REFRESH",
			senderDocumentId : idoc.EDI_DC40.DOCNUM,
			demandUnitId: if (not isEmpty (idoc.E1MARAM.MATNR_LONG)) idoc.E1MARAM.MATNR_LONG else idoc.E1MARAM.MATNR,
			(demandUnitHierarchyInformation : {
				ancestry: [{
					memberId: idoc.E1MARAM.PRDHA,
					hierarchyLevelId : "3"
				}]
			}) if (not (isEmpty (idoc.E1MARAM.PRDHA))),
			demandUnitDetails: {
				demandUnitBaseUnitOfMeasure: if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[idoc.E1MARAM.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[idoc.E1MARAM.MEINS] else idoc.E1MARAM.MEINS,
				description: {
					value : idoc.E1MARAM.E1MAKTM.MAKTX
				},
				(handlingInstruction : {
					handlingInstructionCode : "PER"
				}) if ((lower (idoc.E1MARAM.MTART default "")) == "frip")
			}
	})