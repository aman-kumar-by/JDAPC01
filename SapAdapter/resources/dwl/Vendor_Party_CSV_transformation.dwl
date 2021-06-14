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
				documentActionCode : if (upper($.LOEVM default "") == 'X') "DELETE" else if (upper($.MSGFN) == "009") "ADD" else "CHANGE_BY_REFRESH",
				partyId : $.LIFNR default "",
				basicParty : {
						(additionalPartyId : [{
							value : $.SCACD default "",
							typeCode : "SCAC"
						}]) if(not isEmpty($.SCACD)),
						(additionalPartyId : [{
							value : $.KRAUS,
							typeCode : "DUNS"
						}]) if(not isEmpty($.KRAUS)),
						partyName : $.NAME1 default "",
						description :{
							value : $.NAME1 default "",
							languageCode : "en"
						},
						partyRole : if (($.KTOKK default "") == '0001' or ($.KTOKK default "") == '0002') "SUPPLIER" else if ($[0].KTOKK default "" == '0005') "CARRIER" else if ($[0].KTOKK default "" == '0007') "CORPORATE_ENTITY" else "",
						partyAddress : {
							city : $.ORT01 default "",
							countryCode : $.LAND1 default "",
							pOBoxNumber : $.PFACH default "",
							postalCode : $.PSTLZ default "",
							state : $.REGIO default "",
							streetAddressOne : $.STRAS default "",
							addressDistrict : $.ORT02 default "",
							addressRegion : $.REGIO default ""
						},
						partyContact : [{
							contactTypeCode : "IC",
							personName : $.NAME1 default "",
							communicationChannel : [{
								communicationChannelCode : "TELEPHONE",
								communicationValue : $.TELF1 default ""
							}]
						}],
						status : [{
							statusCode : if (upper($.LOEVM default "") == 'X') "INACTIVE" else "ACTIVE"
						}]
				}
		})
}