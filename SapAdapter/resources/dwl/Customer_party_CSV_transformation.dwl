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
				documentActionCode : if (upper($.LOEVM default "") == 'X') "DELETE"  else "CHANGE_BY_REFRESH",
				senderDocumentId : $.KUNNR default "",
				partyId : $.KUNNR default "",
				basicParty : {
						partyName : $.NAME1 default "",
						description : {
							value : $.NAME1 default "",
							languageCode : "en"
						},
						partyRole : "CUSTOMER",
						partyAddress : {
							city : $.ORT01 default "",
							countryCode : $.LAND1 default "",
							languageOfThePartyCode : lower($.SPRAS default ""),
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
							 (communicationChannel : [(if ($.TELF1 != null and $.TELF1 != ""){
								communicationChannelCode : "TELEPHONE",
								communicationValue : $.TELF1 default ""
							} else {}),
							(if ($.TELFX != null and $.TELFX != "") {
								communicationChannelCode : "TELEFAX",
								communicationValue : $.TELFX default ""
							} else {})]) ,
						},
						(if ($.TELF1_P != null and $.TELF1_P != ""){
								contactTypeCode : $.PAFKT default "",
								personName : if ($.NAMEV != null and $.NAMEV != "") ($.NAMEV ++ " " ++ $.NAME1_P) else $.NAME1_P default "",
								communicationChannel : [{
									communicationChannelCode : "TELEPHONE",
									communicationValue : $.TELF1_P default ""
								}]
						} else {})],
						status : [{
							statusCode : if (upper($.LOEVM default "") == 'X') "INACTIVE" else "ACTIVE"
						}]
				},
				customerDetails : {
					customerClass : $.KUKLA default "",
					organisationalInformation : {
						accountGroup : if (($.KTOKD default "") == '0001') "BUYER" else if (($.KTOKD default "") == '0002') "SHIP_TO" else if (($.KTOKD default "") == '0004') "BILL_TO" else ""
					}
				}
		})
}