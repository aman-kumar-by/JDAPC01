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
var vendorPartyIDOC = vars.entityMap..vendorPartyIDOC[0]
---
(payload.*IDOC default [] map using (role = $.E1LFA1M.KTOKK) {

			creationDateTime: now() as DateTime {
				format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
			},
			documentStatusCode: "ORIGINAL",
			documentActionCode: if ( upper($.E1LFA1M.LOEVM default "") == 'X' ) "DELETE" else if ( $.E1LFA1M.MSGFN == "009" ) "ADD" else "CHANGE_BY_REFRESH",
			senderDocumentId : $.EDI_DC40.DOCNUM,
			partyId:  $.E1LFA1M.LIFNR,
	
			basicParty: {
				//primaryId: $.E1LFA1M.LIFNR,
                additionalPartyId:[{
							value: if($.E1LFA1M.KRAUS != null) $.E1LFA1M.KRAUS else "default_val",
							typeCode : "DUNS"
					    },
					    {
					    	value: if($.E1LFA1M.SCACD != null) $.E1LFA1M.SCACD else "default_val",
							typeCode : "SCAC"
					    }],
                //name: "_name_",      
				partyName: $.E1LFA1M.NAME1,
				
				description: {
					value:  $.E1LFA1M.NAME1,
					languageCode: "en"
				},
				
				partyRole: if ((((p('sap.receiver.vendorParty.supplier') splitBy ",") filter (role == $))!=[])) "SUPPLIER" else if ((((p('sap.receiver.vendorParty.corporateEntity') splitBy ",") filter (role == $))!=[])) "CORPORATE_ENTITY" else if ((((p('sap.receiver.vendorParty.carrier') splitBy ",") filter (role == $))!=[])) "CARRIER" else null,
				partyAddress: {
					city: $.E1LFA1M.ORT01,
					countryCode: $.E1LFA1M.LAND1,
					pOBoxNumber: $.E1LFA1M.PFACH,
					postalCode: $.E1LFA1M.PSTLZ,
					state: $.E1LFA1M.REGIO,
					streetAddressOne: $.E1LFA1M.STRAS,
					addressDistrict: $.E1LFA1M.ORT02,
					addressRegion: $.E1LFA1M.REGIO
				},
				partyContact:[ {
					contactTypeCode: "IC",
					personName: $.E1LFA1M.NAME1,
					communicationChannel: [{
						(communicationChannelCode: "TELEPHONE") if ($.E1LFA1M.TELF1 != null and $.E1LFA1M.TELF1 != ""),
						communicationValue: $.E1LFA1M.TELF1
					}]
				}],
				status: [{
					statusCode: if ( upper($.E1LFA1M.LOEVM default "") == 'X' ) "INACTIVE" else "ACTIVE"
				}]
			}
		
	})