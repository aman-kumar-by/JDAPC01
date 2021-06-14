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
---
(payload.*IDOC default [] map {
			creationDateTime : now() as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
			documentStatusCode : "ORIGINAL",
			documentActionCode : "CHANGE_BY_REFRESH",
			senderDocumentId : $.EDI_DC40.DOCNUM,
			locationId : $.E1TPTRM.E1TPLOC.LOCID,
			parentParty : {
				//gln : "0000000000000",
				primaryId : "UNKNOWN",
				parentRole : if ($.E1TPTRM.TRMTYP == "NO") "CROSS_DOCK" else if ($.E1TPTRM.TRMTYP == "SP") "CORPORATE_ENTITY" else null
			},
			basicLocation : {
				locationName : $.E1TPTRM.E1TPLOC.LOCNAM,
				address : {
					city : $.E1TPTRM.E1TPLOC.CITY1,
					countryCode : $.E1TPTRM.E1TPLOC.CNTRY,
					name : $.E1TPTRM.E1TPLOC.NAME1,
					pOBoxNumber : $.E1TPTRM.E1TPLOC.POBOX,
					postalCode : $.E1TPTRM.E1TPLOC.ZIPPO,
					state : $.E1TPTRM.E1TPLOC.STATE,
					streetAddressOne : $.E1TPTRM.E1TPLOC.STRT1,
					streetAddressTwo : $.E1TPTRM.E1TPLOC.STRT2
				},
				contact: [{
					contactTypeCode: "IC",
					personName: $.E1TPTRM.E1TPLOC.NAME1,
					communicationChannel: [if ( not isEmpty($.E1TPTRM.E1TPLOC.PHONE) ) ({
						communicationChannelCode: "TELEPHONE",
						communicationValue: $.E1TPTRM.E1TPLOC.PHONE,
						communicationChannelName: "LANDLINE"
					}) else {
					},
							if ( not isEmpty($.E1TPTRM.E1TPLOC.FAX ) ) ({
						communicationChannelCode: "TELEFAX",
						communicationValue: $.E1TPTRM.E1TPLOC.FAX
					}) else {
					}]
				}],
				locationTypeCode : if ($.E1TPTRM.TRMTYP == "NO") "PORT" else if ($.E1TPTRM.TRMTYP == "SP") "DOCK_DOOR" else null,
				shipToLocations : {
					isManagedByTransportation : true
				},
				shipFromLocations : {
					isManagedByTransportation : true
				},
				status : [{
					statusCode : "ACTIVE"
				}]
			}
	})