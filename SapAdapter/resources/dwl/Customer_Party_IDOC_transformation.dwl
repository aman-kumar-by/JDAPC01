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
var custPartyIDOC = vars.entityMap..custPartyIDOC[0]
---
(payload.*IDOC default [] map {
			creationDateTime: now() as DateTime {
				format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
			},
			documentStatusCode: "ORIGINAL",
			documentActionCode: if ( upper($.E1KNA1M.LOEVM default "") == 'X' ) "DELETE" else if ( $.E1KNA1M.MSGFN == "009" ) "ADD" else "CHANGE_BY_REFRESH",
			senderDocumentId : $.EDI_DC40.DOCNUM,
			partyId:  $.E1KNA1M.KUNNR,
			basicParty: {
                //primaryId: $.E1KNA1M.KUNNR,
				(additionalPartyId : [{
							value : $.E1KNA1M.*E1KNKKM[0].KRAUS default "",
							typeCode : "DUNS"
						}]) if(not isEmpty($.E1KNA1M.*E1KNKKM[0].KRAUS)),	    
					         
				partyName: $.E1KNA1M.NAME1,
				description: {
					value:  $.E1KNA1M.NAME1,
					languageCode: "en"
				},
				partyRole: "CUSTOMER",
				partyAddress: {
					city: $.E1KNA1M.ORT01,
					countryCode: $.E1KNA1M.LAND1,
					languageOfThePartyCode: lower($.E1KNA1M.SPRAS_ISO default ""),
					pOBoxNumber: $.E1KNA1M.PFACH,
					postalCode: $.E1KNA1M.PSTLZ,
					state: $.E1KNA1M.REGIO,
					streetAddressOne: $.E1KNA1M.STRAS,
					addressDistrict: $.E1KNA1M.ORT02,
					addressRegion: $.E1KNA1M.REGIO
				},
				partyContact: flatten([{
					contactTypeCode: "IC",
					personName: $.E1KNA1M.NAME1,
					(communicationChannel: [if ( not isEmpty($.E1KNA1M.TELF1 ) ) ({
						communicationChannelCode: "TELEPHONE",
						communicationValue: $.E1KNA1M.TELF1 default ""
					})else {
					},
								if ( not isEmpty($.E1KNA1M.TELFX) ) ({
						communicationChannelCode: "TELEFAX",
						communicationValue: $.E1KNA1M.TELFX default ""
					}) else {
					}])
				},
							
							($.E1KNA1M.*E1KNVKM map {
					contactTypeCode: $.PAFKT, // Need transformation TBD
					personName: if ( $.NAMEV != null and $.NAMEV != "" ) ($.NAMEV ++ " " ++ $.NAME1) else $.NAME1,
					(communicationChannel: [if ( not isEmpty($.TELF1) ) {
						communicationChannelCode: "TELEPHONE",
						communicationValue: $.TELF1 default ""
					} else {
					}])
				})]),
				status: [{
					statusCode: if ( upper($.E1KNA1M.LOEVM default "") == 'X' ) "INACTIVE" else "ACTIVE"
				}]
			},
			customerDetails: {
				customerClass: $.E1KNA1M.KUKLA,
				organisationalInformation: {
					accountGroup: if ( $.E1KNA1M.KTOKD == "0001" ) "BUYER" else if ( $.E1KNA1M.KTOKD == "0002" ) "SHIP_TO" else if ( $.E1KNA1M.KTOKD == "0004" ) "BILL_TO" else null
				}
			}

	})