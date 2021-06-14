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
		(payload default [] map {
				creationDateTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
				documentStatusCode : "ORIGINAL",
				documentActionCode : if (upper($.LOEVM default "") == 'X') "DELETE" else if (upper($.MSGFN default "") == "009") "ADD" else "CHANGE_BY_REFRESH",
				locationId : $.LIFNR default "",
				parentParty : {
					additionalPartyId : [{
						value : "0000000000000",
						typeCode : "GLN"
					}],
					primaryId : "UNKNOWN",
					parentRole : if ((($.KTOKK default "") == '0001') or (($.KTOKK default "") == '0002')) "SUPPLIER" else if (($.KTOKK default "") == '0007') "CORPORATE_ENTITY" else ""
				},
				basicLocation : {
					locationName : $.NAME1 default "",
					address : {
						city : $.ORT01 default "",
						countryCode : $.LAND1 default "",
						name : $.NAME1 default "",
						pOBoxNumber : $.PFACH default "",
						postalCode : $.PSTLZ default "",
						state : $.REGIO default "",
						streetAddressOne : $.STRAS default ""
					},
					contact : [{
						contactTypeCode : "IC",
						personName : $.NAME1 default "",
						(communicationChannel : [
							(if ($.LFURL != null and $.LFURL != "") {
								communicationChannelCode : "EMAIL",
								communicationValue : $.LFURL default ""
							} else {}),
						(if ($.TELFX != null and $.TELFX != "") {
							communicationChannelCode : "TELEFAX",
							communicationValue : $.TELFX default ""
						} else {}),
						{
							communicationChannelCode : "TELEPHONE",
							communicationValue : $.TELF1 default "",
							communicationChannelName : "LANDLINE"
						}
						])
					}],
					locationTypeCode : if (($.KTOKK default "") == '0001' or ($.KTOKK default "") == '0002') "SUPPLIER" else if (($.KTOKK default "") == '0007') "WAREHOUSE_AND_OR_DEPOT" else "",
					shipToLocations : {
						isManagedByTransportation : true
					},
					shipFromLocations : {
						isManagedByTransportation : true
					},
					status : [{
						statusCode : if (upper($.LOEVM default "") == 'X') "INACTIVE" else "ACTIVE"
					}]
				}
		})
}