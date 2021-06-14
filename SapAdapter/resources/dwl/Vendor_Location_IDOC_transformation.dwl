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
(payload.*IDOC default [] map using (
        role = $.E1LFA1M.KTOKK
    ) {
			creationDateTime : now() as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
			documentStatusCode : "ORIGINAL",
			documentActionCode : if (upper($.E1LFA1M.LOEVM default "") == 'X') "DELETE" else if ($.E1LFA1M.MSGFN == "009") "ADD" else "CHANGE_BY_REFRESH",
			senderDocumentId : $.EDI_DC40.DOCNUM,
			locationId : $.E1LFA1M.LIFNR,
			parentParty : {
				additionalPartyId : [{
					value : "0000000000000",
					typeCode : "GLN",
				}],
				primaryId : "UNKNOWN",
				parentRole : if ((((p('sap.receiver.vendorLocation.supplier') splitBy ",") filter (role == $))!=[])) "SUPPLIER" else if ((((p('sap.receiver.vendorLocation.corporateEntity') splitBy ",") filter (role == $))!=[])) "CORPORATE_ENTITY" else null
			},
			basicLocation : {
				locationName : $.E1LFA1M.NAME1,
				address : {
					city : $.E1LFA1M.ORT01,
					countryCode : $.E1LFA1M.LAND1,
					name : $.E1LFA1M.NAME1,
					pOBoxNumber : $.E1LFA1M.PFACH,
					postalCode : $.E1LFA1M.PSTLZ,
					state : $.E1LFA1M.REGIO,
					streetAddressOne : $.E1LFA1M.STRAS
				},
				contact : [{
					contactTypeCode : "IC",
					personName : $.E1LFA1M.NAME1,
					communicationChannel: [
					if (not isEmpty($.E1LFA1M.E1LFA1A.LFURL))({
						communicationChannelCode : "EMAIL",
						communicationValue : $.E1LFA1M.E1LFA1A.LFURL
					}) else {},
					if (not isEmpty($.E1LFA1M.TELFX))({
						communicationChannelCode : "TELEFAX",
						communicationValue : $.E1LFA1M.TELFX
					}) else {},
					if (not isEmpty($.E1LFA1M.TELF1)) ({
						communicationChannelCode : "TELEPHONE",
						communicationValue : $.E1LFA1M.TELF1,
						communicationChannelName : "LANDLINE"
					}) else {}
					]
				}],
				locationTypeCode : if ($.E1LFA1M.KTOKK == "0001" or $.E1LFA1M.KTOKK == "0002") "SUPPLIER" else if ($.E1LFA1M.KTOKK == "0007") "WAREHOUSE_AND_OR_DEPOT" else null,
				shipToLocations : {
					isManagedByTransportation : true
				},
				shipFromLocations : {
					isManagedByTransportation : true
				},
				status : [{
					statusCode : if (upper($.E1LFA1M.LOEVM default "") == 'X') "INACTIVE" else "ACTIVE"
				}]
			}
	})