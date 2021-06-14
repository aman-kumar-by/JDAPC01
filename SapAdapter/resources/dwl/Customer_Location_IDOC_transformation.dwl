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
(payload.*IDOC default [] map {
			creationDateTime : now() as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
			documentStatusCode : "ORIGINAL",
			documentActionCode : if (upper($.E1KNA1M.LOEVM default "") == 'X') "DELETE" else if ($.E1KNA1M.MSGFN == "009") "ADD" else "CHANGE_BY_REFRESH",
			senderDocumentId : $.EDI_DC40.DOCNUM,
			locationId : $.E1KNA1M.KUNNR,
			parentParty : {
				additionalPartyId : [{
					value : "0000000000000",
					typeCode : "GLN"
				}],
				primaryId : "UNKNOWN",
				parentRole : "CUSTOMER"
			},
			basicLocation : using (role = $.E1KNA1M.KTOKD) {
				locationName : $.E1KNA1M.NAME1,
				address : {
					city : $.E1KNA1M.ORT01,
					countryCode : $.E1KNA1M.LAND1,
					languageOfThePartyCode : lower($.E1KNA1M.SPRAS_ISO default ""),
					name : $.E1KNA1M.NAME1,
					pOBoxNumber : $.E1KNA1M.PFACH,
					postalCode : $.E1KNA1M.PSTLZ,
					state : $.E1KNA1M.REGIO,
					streetAddressOne : $.E1KNA1M.STRAS
				},
				contact : flatten([
					 {
						contactTypeCode : "IC",
						personName : $.E1KNA1M.NAME1,
						(communicationChannel : [
							if (not isEmpty($.E1KNA1M.TELF1)) ({
								communicationChannelCode : "TELEPHONE",
								communicationValue : $.E1KNA1M.TELF1,
							}) else {},
							if (not isEmpty($.E1KNA1M.E1KNB1M.SMTP_ADDR)) ({
								communicationChannelCode : "EMAIL",
								communicationValue : $.E1KNA1M.E1KNB1M.SMTP_ADDR
							}) else {},
							if (not isEmpty($.E1KNA1M.TELFX )) ({
								communicationChannelCode : "TELEFAX",
								communicationValue : $.E1KNA1M.TELFX
							}) else {}
							])
					},
					($.E1KNA1M.*E1KNVKM map (e1knvkm, index) -> {
					contactTypeCode : e1knvkm.PAFKT, // Transformation required
					personName : if (not isEmpty(e1knvkm.NAMEV)) (e1knvkm.NAMEV ++ " " ++ e1knvkm.NAME1) else e1knvkm.NAME1,
					(communicationChannel : [{
							communicationChannelCode : "TELEPHONE",
							communicationValue : e1knvkm.TELF1,
							//communicationChannelName : "LANDLINE"
						}]) if (not isEmpty(e1knvkm.TELF1)),
					isPrimaryContact : if (not isEmpty(e1knvkm.PAVIP)) true else false
					})
				]),
				operatingHours : {
					regularOperatingHours : [{
						dayOfTheWeekCode : "MONDAY",
						isOperational : if (((not isEmpty($.E1KNA1M.E1KNVAM.MOBI1 )) or (not isEmpty($.E1KNA1M.E1KNVAM.MOAB1))) and ($.E1KNA1M.E1KNVAM.MOBI1 != "000000" and $.E1KNA1M.E1KNVAM.MOAB1 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.MOBI1 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.MOAB1 default "")
					},
					if ((not isEmpty($.E1KNA1M.E1KNVAM.MOBI2 )) or (not isEmpty($.E1KNA1M.E1KNVAM.MOAB2))) ({
						dayOfTheWeekCode : "MONDAY",
						isOperational : if (((not isEmpty($.E1KNA1M.E1KNVAM.MOBI2)) or (not isEmpty($.E1KNA1M.E1KNVAM.MOAB2))) and ($.E1KNA1M.E1KNVAM.MOBI2 != "000000" and $.E1KNA1M.E1KNVAM.MOAB2 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.MOBI2 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.MOAB2 default "")
					}) else {},
					{
						dayOfTheWeekCode : "TUESDAY",
						isOperational : if (((not isEmpty($.E1KNA1M.E1KNVAM.DIBI1)) or (not isEmpty($.E1KNA1M.E1KNVAM.DIAB1))) and ($.E1KNA1M.E1KNVAM.DIBI1 != "000000" and $.E1KNA1M.E1KNVAM.DIAB1 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.DIBI1 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.DIAB1 default "")
					},
					if ((not isEmpty($.E1KNA1M.E1KNVAM.DIBI2)) or (not isEmpty($.E1KNA1M.E1KNVAM.DIAB2))) ({
						dayOfTheWeekCode : "TUESDAY",
						isOperational : if (((not isEmpty($.E1KNA1M.E1KNVAM.DIBI2)) or (not isEmpty($.E1KNA1M.E1KNVAM.DIAB2 ))) and ($.E1KNA1M.E1KNVAM.DIBI2 != "000000" and $.E1KNA1M.E1KNVAM.DIAB2 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.DIBI2 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.DIAB2 default "")
					}) else {},
					{
						dayOfTheWeekCode : "WEDNESDAY",
						isOperational : if (((not isEmpty($.E1KNA1M.E1KNVAM.MIBI1)) or (not isEmpty($.E1KNA1M.E1KNVAM.MIAB1))) and ($.E1KNA1M.E1KNVAM.MIBI1 != "000000" and $.E1KNA1M.E1KNVAM.MIAB1 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.DIBI2 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.DIAB2 default "")
					},
					if ((not isEmpty($.E1KNA1M.E1KNVAM.MIBI2)) or (not isEmpty($.E1KNA1M.E1KNVAM.MIAB2))) ({
						dayOfTheWeekCode : "WEDNESDAY",
						isOperational : if (((not isEmpty($.E1KNA1M.E1KNVAM.MIBI2)) or (not isEmpty($.E1KNA1M.E1KNVAM.MIAB2))) and ($.E1KNA1M.E1KNVAM.MIBI2 != "000000" and $.E1KNA1M.E1KNVAM.MIAB2 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.MIBI2 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.MIAB2 default "")
					}) else {},
					{
						dayOfTheWeekCode : "THURSDAY",
						isOperational : if (((not isEmpty($.E1KNA1M.E1KNVAM.DOBI1)) or (not isEmpty($.E1KNA1M.E1KNVAM.DOAB1))) and ($.E1KNA1M.E1KNVAM.DOBI1 != "000000" and $.E1KNA1M.E1KNVAM.DOAB1 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.DOBI1 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.DOAB1 default "")
					},
					if ((not isEmpty($.E1KNA1M.E1KNVAM.DOBI2)) or (not isEmpty($.E1KNA1M.E1KNVAM.DOAB2))) ({
						dayOfTheWeekCode : "THURSDAY",
						isOperational : if (((not isEmpty($.E1KNA1M.E1KNVAM.DOBI2)) or (not isEmpty($.E1KNA1M.E1KNVAM.DOAB2))) and ($.E1KNA1M.E1KNVAM.DOBI2 != "000000" and $.E1KNA1M.E1KNVAM.DOAB2 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.DOBI2 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.DOAB2 default "")
					}) else {},
					{
						dayOfTheWeekCode : "FRIDAY",
						isOperational : if (((not isEmpty($.E1KNA1M.E1KNVAM.FRBI1)) or (not isEmpty($.E1KNA1M.E1KNVAM.FRAB1))) and ($.E1KNA1M.E1KNVAM.FRBI1 != "000000" and $.E1KNA1M.E1KNVAM.FRAB1 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.FRBI1 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.FRAB1 default "")
					},
					if ((not isEmpty($.E1KNA1M.E1KNVAM.FRBI2)) or (not isEmpty($.E1KNA1M.E1KNVAM.FRAB2))) ({
						dayOfTheWeekCode : "FRIDAY",
						isOperational : if (((not isEmpty($.E1KNA1M.E1KNVAM.FRBI2)) or (not isEmpty($.E1KNA1M.E1KNVAM.FRAB2))) and ($.E1KNA1M.E1KNVAM.FRBI2 != "000000" and $.E1KNA1M.E1KNVAM.FRAB2 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.FRBI2 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.FRAB2 default "")	
					}) else {},
					{
						dayOfTheWeekCode : "SATURDAY",
						isOperational : if (((not isEmpty($.E1KNA1M.E1KNVAM.SABI1)) or (not isEmpty($.E1KNA1M.E1KNVAM.SAAB1))) and ($.E1KNA1M.E1KNVAM.SABI1 != "000000" and $.E1KNA1M.E1KNVAM.SAAB1 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.SABI1 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.SAAB1 default "")
					},
					if ((not isEmpty($.E1KNA1M.E1KNVAM.SABI2)) or (not isEmpty($.E1KNA1M.E1KNVAM.SAAB2))) ({
						dayOfTheWeekCode : "SATURDAY",
						isOperational : if (((not isEmpty($.E1KNA1M.E1KNVAM.SABI2)) or (not isEmpty($.E1KNA1M.E1KNVAM.SAAB2))) and ($.E1KNA1M.E1KNVAM.SABI2 != "000000" and $.E1KNA1M.E1KNVAM.SAAB2 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.SABI2 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.SAAB2 default "")
					}) else {},
					{
						dayOfTheWeekCode : "SUNDAY",
						isOperational : if (((not isEmpty($.E1KNA1M.E1KNVAM.SOBI1)) or (not isEmpty($.E1KNA1M.E1KNVAM.SOAB1))) and ($.E1KNA1M.E1KNVAM.SOBI1 != "000000" and $.E1KNA1M.E1KNVAM.SOAB1 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.SOBI1 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.SOAB1 default "")
					},
					if ((not isEmpty($.E1KNA1M.E1KNVAM.SOBI2)) or (not isEmpty($.E1KNA1M.E1KNVAM.SOAB2))) ({
						dayOfTheWeekCode : "SUNDAY",
						isOperational : if (((not isEmpty($.E1KNA1M.E1KNVAM.SOBI2)) or (not isEmpty($.E1KNA1M.E1KNVAM.SOAB2))) and ($.E1KNA1M.E1KNVAM.SOBI2 != "000000" and $.E1KNA1M.E1KNVAM.SOAB2 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.SOBI2 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.E1KNA1M.E1KNVAM.SOAB2 default "")
					}) else {}
					
					]
				},
				locationTypeCode : "CUSTOMER",
				accountGroup : if ((((p('sap.receiver.customerLocation.buyer') splitBy ",") filter (role == $))!=[])) "BUYER" else if ((((p('sap.receiver.customerLocation.shipTo') splitBy ",") filter (role == $))!=[])) "SHIP_TO" else if ((((p('sap.receiver.customerLocation.billTo') splitBy ",") filter (role == $))!=[])) "BILL_TO" else null,
				shipToLocations : {
					isManagedByTransportation : true
				},
				shipFromLocations : {
					isManagedByTransportation : true
				},
				status : [{
					statusCode : if (upper($.E1KNA1M.LOEVM default "") == 'X') "INACTIVE" else "ACTIVE"
				}]
			}
	})