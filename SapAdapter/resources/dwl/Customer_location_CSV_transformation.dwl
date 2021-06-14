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
				documentActionCode : if (upper($.LOEVM default "") == 'X') "DELETE" else "CHANGE_BY_REFRESH",
				locationId : $.KUNNR default "",
				parentParty : {
					additionalPartyId : [{
						value : "0000000000000",
						typeCode : "GLN"
					}],
					primaryId : "UNKNOWN",
					parentRole : "CUSTOMER"
				},
				basicLocation : {
					locationName : $.NAME1 default "",
					address : {
						city : $.ORT01 default "",
						countryCode : $.LAND1 default "",
						languageOfThePartyCode : $.SPRAS default "",
						name : $.NAME1 default "",
						pOBoxNumber : $.PFACH default "",
						postalCode : $.PSTLZ default "",
						state : $.REGIO default "",
						streetAddressOne : $.STRAS default ""
					},
					contact : flatten([{
						contactTypeCode : "IC",
						personName : $.NAME1 default "",
						(communicationChannel : [
							if (($.TELF1 != null) and ($.TELF1 != ""))({
							communicationChannelCode : "TELEPHONE",
							communicationValue : $.TELF1 default ""
							}) else {},
							if (($.TELFX != null) and ($.TELFX != ""))({
								communicationChannelCode : "TELEFAX",
								communicationValue : $.TELFX default ""
							}) else {}
						])
					},
				(payload map {
						contactTypeCode : $.PAFKT default "", 
						personName : if ($.NAMEV != null and $.NAMEV != "") ($.NAMEV ++ " " ++ $.NAME1) else $.NAME1 default "",
						(communicationChannel : [{
							communicationChannelCode : "TELEPHONE",
							communicationValue : $.TELF1 default ""
						}]) if (($.TELF1 != null) and ($.TELF1 != "")),
						isPrimaryContact : if (($.PAVIP != null) and ($.PAVIP != "")) true else false
				})]),
				operatingHours : {
					regularOperatingHours : [{
						dayOfTheWeekCode : "MONDAY",
						isOperational : if ((($.MOBI1 != null and $.MOBI1 != "") or ($.MOAB1 != null and $.MOAB1 != "")) and ($.MOBI1 != "000000" and $.MOAB1 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.MOBI1 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.MOAB1 default "")
					},
					if (($.MOBI2 != null and $.MOBI2 != "") or ($.MOAB2 != null and $.MOAB2 != "")) ({
						dayOfTheWeekCode : "MONDAY",
						isOperational : if ((($.MOBI2 != null and $.MOBI2 != "") or ($.MOAB2 != null and $.MOAB2 != "")) and ($.MOBI2 != "000000" and $.MOAB2 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.MOBI2 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.MOAB2 default "")
					}) else {},
					{
						dayOfTheWeekCode : "TUESDAY",
						isOperational : if ((($.DIBI1 != null and $.DIBI1 != "") or ($.DIAB1 != null and $.DIAB1 != "")) and ($.DIBI1 != "000000" and $.DIAB1 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.DIBI1 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.DIAB1 default "")
					},
					if (($.DIBI2 != null and $.DIBI2 != "") or ($.DIAB2 != null and $.DIAB2 != "")) ({
						dayOfTheWeekCode : "TUESDAY",
						isOperational : if ((($.DIBI2 != null and $.DIBI2 != "") or ($.DIAB2 != null and $.DIAB2 != "")) and ($.DIBI2 != "000000" and $.DIAB2 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.DIBI2 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.DIAB2 default "")
					}) else {},
					{
						dayOfTheWeekCode : "WEDNESDAY",
						isOperational : if ((($.MIBI1 != null and $.MIBI1 != "") or ($.MIAB1 != null and $.MIAB1 != "")) and ($.MIBI1 != "000000" and $.MIAB1 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.MIBI1 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.MIAB1 default "")
					},
					if (($.MIBI2 != null and $.MIBI2 != "") or ($.MIAB2 != null and $.MIAB2 != "")) ({
						dayOfTheWeekCode : "WEDNESDAY",
						isOperational : if ((($.MIBI2 != null and $.MIBI2 != "") or ($.MIAB2 != null and $.MIAB2 != "")) and ($.MIBI2 != "000000" and $.MIAB2 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.MIBI2 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.MIAB2 default "")
					}) else {},
					{
						dayOfTheWeekCode : "THURSDAY",
						isOperational : if ((($.DOBI1 != null and $.DOBI1 != "") or ($.DOAB1 != null and $.DOAB1 != "")) and ($.DOBI1 != "000000" and $.DOAB1 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.DOBI1 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.DOAB1 default "")
					},
					if (($.DOBI2 != null and $.DOBI2 != "") or ($.DOAB2 != null and $.DOAB2 != "")) ({
						dayOfTheWeekCode : "THURSDAY",
						isOperational : if ((($.DOBI2 != null and $.DOBI2 != "") or ($.DOAB2 != null and $.DOAB2 != "")) and ($.DOBI2 != "000000" and $.DOAB2 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.DOBI2 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.DOAB2 default "")
					}) else {},
					{
						dayOfTheWeekCode : "FRIDAY",
						isOperational : if ((($.FRBI1 != null and $.FRBI1 != "") or ($.FRAB1 != null and $.FRAB1 != "")) and ($.FRBI1 != "000000" and $.FRAB1 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.FRBI1 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.FRAB1 default "")
					},
					if (($.FRBI2 != null and $.FRBI2 != "") or ($.FRAB2 != null and $.FRAB2 != "")) ({
						dayOfTheWeekCode : "FRIDAY",
						isOperational : if ((($.FRBI2 != null and $.FRBI2 != "") or ($.FRAB2 != null and $.FRAB2 != "")) and ($.FRBI2 != "000000" and $.FRAB2 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.FRBI2 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.FRAB2 default "")
					}) else {},
					{
						dayOfTheWeekCode : "SATURDAY",
						isOperational : if ((($.SABI1 != null and $.SABI1 != "") or ($.SAAB1 != null and $.SAAB1 != "")) and ($.SABI1 != "000000" and $.SAAB1 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.SABI1 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.SAAB1 default "")
					},
					if (($.SABI2 != null and $.SABI2 != "") or ($.SAAB2 != null and $.SAAB2 != "")) ({
						dayOfTheWeekCode : "SATURDAY",
						isOperational : if ((($.SABI2 != null and $.SABI2 != "") or ($.SAAB2 != null and $.SAAB2 != "")) and ($.SABI2 != "000000" and $.SAAB2 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.SABI2 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.SAAB2 default "")
					}) else {},
					{
						dayOfTheWeekCode : "SUNDAY",
						isOperational : if ((($.SOBI1 != null and $.SOBI1 != "") or ($.SOAB1 != null and $.SOAB1 != "")) and ($.SOBI1 != "000000" and $.SOAB1 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.SOBI1 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.SOAB1 default "")
					},
					if (($.SOBI2 != null and $.SOBI2 != "") or ($.SOAB2 != null and $.SOAB2 != "")) ({
						dayOfTheWeekCode : "SUNDAY",
						isOperational : if ((($.SOBI2 != null and $.SOBI2 != "") or ($.SOAB2 != null and $.SOAB2 != "")) and ($.SOBI2 != "000000" and $.SOAB2 != "000000")) true else false,
						closingTime : globalDataweaveFunctions::timeConversion($.SOBI2 default ""),
						openingTime : globalDataweaveFunctions::timeConversion($.SOAB2 default "")
					}) else {}
					]
				},
				accountGroup : if ($.KTOKD == "0001") "BUYER" else if ($.KTOKD == "0002") "SHIP_TO" else if ($.KTOKD == "0004") "BILL_TO" else null,
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