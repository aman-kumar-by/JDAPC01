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
output application/json skipNullOn = "everywhere", encoding = "UTF-8"
import lookup_utils::globalDataweaveFunctions
---
{
	(payload default [] map (record, index) -> {
		creationDateTime: now() as DateTime {
			format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
		},
		documentStatusCode: "ORIGINAL",
		documentActionCode: "CHANGE_BY_REFRESH",
		locationId: record.WERKS,
		parentParty: {
			additionalPartyId: [{
				value: "0000000000000",
				typeCode: "GLN"
			}],
			primaryId: "UNKNOWN",
			parentRole: "CORPORATE_ENTITY"
		},
		basicLocation: {
			locationName: record.NAME1,
			address: {
				city: record.ORT01,
				cityCode: record.CITYC,
				countryCode: record.LAND1,
				languageOfThePartyCode: lower(record.SPRAS default "en"),
				pOBoxNumber: record.PFACH,
				postalCode: record.PSTLZ,
				state: record.REGIO,
				streetAddressOne: record.STRAS
			},
			contact : [{
					contactTypeCode : "IC",
					communicationChannel: [if ( (not isEmpty(record."TEL_NUMBER" default "")) or (not isEmpty(record."TEL_EXTENS" default "")) ) ({
						communicationChannelCode: "TELEPHONE",
						communicationValue: (record."TEL_NUMBER" default "") ++ (record."TEL_EXTENS" default ""),
						communicationChannelName: "LANDLINE"
					}) else {
					},
							if ( not isEmpty(record."MOB_NUMBER") ) ({
						communicationChannelCode: "TELEPHONE",
						communicationValue: record."MOB_NUMBER",
						communicationChannelName: "MOBILE"
					}) else {
					},
							if ( not isEmpty(record."SMTP_ADDR") ) ({
						communicationChannelCode: "EMAIL",
						communicationValue: record."SMTP_ADDR"
					}) else {
					},
							if ( not isEmpty(record."FAX_NUMBER") ) ({
						communicationChannelCode: "TELEFAX",
						communicationValue: record."FAX_NUMBER"
					}) else {
					}]
				}],
			locationTypeCode: if ( (record.NODETYPE  default "") == "PL" ) "MANUFACTURING_PLANT"
	            					else if ( (record.NODETYPE  default "") == "A" ) "STORE"
	            					else if ( ((record.NODETYPE  default "")== "B") or ((record.NODETYPE  default "")== "DC") or ((record.NODETYPE  default "")== "EW") ) "WAREHOUSE_AND_OR_DEPOT"
	            					else "",
			shipToLocations: {
				isManagedByTransportation: true
			},
			shipFromLocations: {
				isManagedByTransportation: true
			},
			status: [{
				statusCode: "ACTIVE"
			}]
		}
	})
}