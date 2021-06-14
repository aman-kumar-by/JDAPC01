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
(payload.*IDOC default [] filter (($.E1PLAFL.AUFFX default "") == "X") map {
				creationDateTime : globalDataweaveFunctions::formatDateToDateTime(globalDataweaveFunctions::formatDate($.EDI_DC40.CREDAT default "")),
				documentStatusCode : "ORIGINAL",
				documentActionCode : "ADD",
				senderDocumentId : $.EDI_DC40.DOCNUM,
				scheduledReceiptId : {
					item : {
						//gtin : "00000000000000",
						primaryId : "UNKNOWN",
						additionalTradeItemId: [
						{
							value: $.E1PLAFL.MATNR,
							typeCode: "BUYER_ASSIGNED"
						}
					]
					},
					location : {
						//gln : "0000000000000",
						primaryId : "UNKNOWN",
						additionalPartyId: [
						{
							value: $.E1PLAFL.PLWRK,
							typeCode: "UNKNOWN"
						}
					]
					},
					scheduledOnHandDate : globalDataweaveFunctions::formatDate($.E1PLAFL.PEDTR default ""),
					productionStartDate : globalDataweaveFunctions::formatDate($.E1PLAFL.PSTTR default "")
				},
				lineItem : [{
					lineItemNumber : if(isInteger($.EDI_DC40.DOCNUM)) $.EDI_DC40.DOCNUM as Number else "" ,
					orderReferenceId : $.E1PLAFL.PLNUM,
					isDependentDemandRequired : false,
					proposedQuantity: {
						value: $.E1PLAFL.GSMNG as Number,
						measurementUnitCode: if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.E1PLAFL.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.E1PLAFL.MEINS] else $.E1PLAFL.MEINS
					},
					productionRoutingId : $.E1PLAFL.VERID,
					productionRoutingOperationInformation : [{
						operationNumber : 10
					}]
				}]
		})