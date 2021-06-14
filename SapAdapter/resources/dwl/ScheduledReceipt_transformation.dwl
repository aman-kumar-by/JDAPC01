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
(payload.*IDOC filter (not ($.E1AFKOL.*E1JSTKL.STAT contains "I0013")) map (item, index) -> {
			creationDateTime : globalDataweaveFunctions::formatDateToDateTime(globalDataweaveFunctions::formatDate(item.EDI_DC40.CREDAT default "")),
			documentStatusCode : "ORIGINAL",
			documentActionCode : "CHANGE_BY_REFRESH",
			senderDocumentId : item.EDI_DC40.DOCNUM,
			scheduledReceiptId : {	
				item : {
					additionalTradeItemId : [{
						value : "00000000000000",
						typeCode : "BUYER_ASSIGNED"
					}],
					primaryId : item.E1AFKOL.MATNR
				},
				location : {
					additionalPartyId : [{
						value : "0000000000000",
						typeCode : "GLN" //GLN
					}],
					primaryId : item.E1AFKOL.WERKS,
				},
				scheduledOnHandDate : globalDataweaveFunctions::formatDate(item.E1AFKOL.GLTRP default ""),
				productionStartDate : globalDataweaveFunctions::formatDate(item.E1AFKOL.GSTRS default "")
				
			},
			(status : if ((item.E1AFKOL.*E1JSTKL.STAT contains "I0045") or (item.E1AFKOL.*E1JSTKL.STAT contains "I0046") or (item.E1AFKOL.*E1JSTKL.STAT contains "I0012") ) "CLOSED" else "OPEN"),
			lineItem : [{
				lineItemNumber : if(isInteger(item.EDI_DC40.DOCNUM)) item.EDI_DC40.DOCNUM as Number else "",
				orderReferenceId : item.E1AFKOL.AUFNR,
				isDependentDemandRequired : false,
				lastCompletedOperationNumber : (if (not isEmpty((item.E1AFKOL.E1AFFLL.*E1AFVOL filter ((daysBetween(globalDataweaveFunctions::formatDate($.FSEVD default ""),globalDataweaveFunctions::formatDate(item.EDI_DC40.CREDAT default ""))) > 0)))) (((item.E1AFKOL.E1AFFLL.*E1AFVOL filter ((daysBetween(globalDataweaveFunctions::formatDate($.FSEVD default ""),globalDataweaveFunctions::formatDate(item.EDI_DC40.CREDAT default ""))) > 0)) orderBy ((daysBetween(globalDataweaveFunctions::formatDate($.FSEVD default ""),globalDataweaveFunctions::formatDate(item.EDI_DC40.CREDAT default "")))))[0].VORNR) as Number else null),
				proposedQuantity : {
					value : item.E1AFKOL.E1AFPOL.PSMNG as Number,
					measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[item.E1AFKOL.BMEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[item.E1AFKOL.BMEINS] else item.E1AFKOL.BMEINS
				},
				receivedQuantity : {
					value : item.E1AFKOL.E1AFPOL.WEMNG as Number,
					measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[item.E1AFKOL.BMEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[item.E1AFKOL.BMEINS] else item.E1AFKOL.BMEINS
				},
				productionRoutingId : item.E1AFKOL.E1AFPOL.VERID,
			 	productionRoutingOperationInformation : (item.E1AFKOL.E1AFFLL.*E1AFVOL map (e1afvol, index) -> {
						operationNumber : e1afvol.VORNR as Number,
						operationStartDate : globalDataweaveFunctions::formatDate(e1afvol.FSAVD default ""),
						scheduledOperationOnHandDate : globalDataweaveFunctions::formatDate(e1afvol.FSEVD default "")
				})
			}]
	})