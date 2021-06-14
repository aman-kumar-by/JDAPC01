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
		header : {
			sender :  p("sap.sender"),
			receiver : (p("sap.receiver.openingHours") splitBy ","),
			model : "BYDM",
			messageVersion : "BYDM 2021.2.0",
			messageId : uuid(),
			'type' : "calendar",
			creationDateAndTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"}
		},
		calendar : ((payload groupBy(calendar) -> calendar.LOCNR) mapObject {
			root : {
				creationDateTime : globalDataweaveFunctions::formatDateToDateTime(globalDataweaveFunctions::formatDate($[0].ERDAT default "")),
				documentStatusCode : "ORIGINAL",
				documentActionCode : "ADD",
				calendarId : $$,
				calendarStartDate : globalDataweaveFunctions::formatDate($[0].EROED default ""),
				calendarEndDate : globalDataweaveFunctions::formatDate($[0].SCHLD default ""),
				calendarType : "OPEN_HOURS",
				relatedLocation : [{
					primaryId : $[0].LOCNR
				}],
				pattern : [{
					isHoliday : false,
					patternFrequencyCode : "DAY_OF_WEEK",
					patternFrequency : {
						weekly : {
							weeksOfRecurrence : 1,
							dayOfWeek : [
								"MONDAY"
							]
						}
					},
					(calendarAttribute : [
						if (($[0].MOAB1 != null and $[0].MOAB1 != "") or ($[0].MOBI1 != null and $[0].MOBI1 != "")) {
						attributeType : "1",
						startTime : globalDataweaveFunctions::timeConversion($[0].MOAB1 default ""),
						endTime : globalDataweaveFunctions::timeConversion($[0].MOBI1 default "")
					} else {},
					if (($[0].MOAB2 != null and $[0].MOAB2 != "") or ($[0].MOBI2 != null and $[0].MOBI2 != "")) {
						attributeType : "1",
						startTime : globalDataweaveFunctions::timeConversion($[0].MOAB2 default ""),
						endTime : globalDataweaveFunctions::timeConversion($[0].MOBI2 default "")
					} else {}])
				},
				{
					isHoliday : false,
					patternFrequencyCode : "DAY_OF_WEEK",
					patternFrequency : {
						weekly : {
							weeksOfRecurrence : 1,
							dayOfWeek : [
								"TUESDAY"
							]
						}
					},
					(calendarAttribute : [
						if (($[0].DIAB1 != null and $[0].DIAB1 != "") or ($[0].DIBI1 != null and $[0].DIBI1 != "")) {
						attributeType : "1",
						startTime : globalDataweaveFunctions::timeConversion($[0].DIAB1 default ""),
						endTime : globalDataweaveFunctions::timeConversion($[0].DIBI1 default "")
					}else {},
					if (($[0].DIAB2 != null and $[0].DIAB2 != "") or ($[0].DIBI2 != null and $[0].DIBI2 != "")){
						attributeType : "1",
						startTime : globalDataweaveFunctions::timeConversion($[0].DIAB2 default ""),
						endTime : globalDataweaveFunctions::timeConversion($[0].DIBI2 default "")
					} else {}])
				},
				{
					isHoliday : false,
					patternFrequencyCode : "DAY_OF_WEEK",
					patternFrequency : {
						weekly : {
							weeksOfRecurrence : 1,
							dayOfWeek : [
								"WEDNESDAY"
							]
						}
					},
					(calendarAttribute : [
						if (($[0].MIAB1 != null and $[0].MIAB1 != "") or ($[0].MIBI1 != null and $[0].MIBI1 != "")) {
						attributeType : "1",
						startTime : globalDataweaveFunctions::timeConversion($[0].MIAB1 default ""),
						endTime : globalDataweaveFunctions::timeConversion($[0].MIBI1 default "")
					}else {},
					if (($[0].MIAB2 != null and $[0].MIAB2 != "") or ($[0].MIBI2 != null and $[0].MIBI2 != "")) {
						attributeType : "1",
						startTime : globalDataweaveFunctions::timeConversion($[0].MIAB2 default ""),
						endTime : globalDataweaveFunctions::timeConversion($[0].MIBI2 default "")
					} else {}])
				},
				{
					isHoliday : false,
					patternFrequencyCode : "DAY_OF_WEEK",
					patternFrequency : {
						weekly : {
							weeksOfRecurrence : 1,
							dayOfWeek : [
								"THURSDAY"
							]
						}
					},
					(calendarAttribute : [
						if (($[0].DOAB1 != null and $[0].DOAB1 != "") or ($[0].DOBI1 != null and $[0].DOBI1 != "")) {
						attributeType : "1",
						startTime : globalDataweaveFunctions::timeConversion($[0].DOAB1 default ""),
						endTime : globalDataweaveFunctions::timeConversion($[0].DOBI1 default "")
					} else {},
					if (($[0].DOAB2 != null and $[0].DOAB2 != "") or ($[0].DOBI2 != null and $[0].DOBI2 != "")){
						attributeType : "1",
						startTime : globalDataweaveFunctions::timeConversion($[0].DOAB2 default ""),
						endTime : globalDataweaveFunctions::timeConversion($[0].DOBI2 default "")
					} else {}])
				},
				{
					isHoliday : false,
					patternFrequencyCode : "DAY_OF_WEEK",
					patternFrequency : {
						weekly : {
							weeksOfRecurrence : 1,
							dayOfWeek : [
								"FRIDAY"
							]
						}
					},
					(calendarAttribute : [
						if (($[0].FRAB1 != null and $[0].FRAB1 != "") or ($[0].FRBI1 != null and $[0].FRBI1 != "")) {
						attributeType : "1",
						startTime : globalDataweaveFunctions::timeConversion($[0].FRAB1 default ""),
						endTime : globalDataweaveFunctions::timeConversion($[0].FRBI1 default "")
					} else{},
					if (($[0].FRAB2 != null and $[0].FRAB2 != "") or ($[0].FRBI2 != null and $[0].FRBI2 != "")){
						attributeType : "1",
						startTime : globalDataweaveFunctions::timeConversion($[0].FRAB2 default ""),
						endTime : globalDataweaveFunctions::timeConversion($[0].FRBI2 default "")
					} else {}])
				},
				{
					isHoliday : false,
					patternFrequencyCode : "DAY_OF_WEEK",
					patternFrequency : {
						weekly : {
							weeksOfRecurrence : 1,
							dayOfWeek : [
								"SATURDAY"
							]
						}
					},
					(calendarAttribute : [
						if (($[0].SAAB1 != null and $[0].SAAB1 != "") or ($[0].SABI1 != null and $[0].SABI1 != "")) {
						attributeType : "1",
						startTime : globalDataweaveFunctions::timeConversion($[0].SAAB1 default ""),
						endTime : globalDataweaveFunctions::timeConversion($[0].SABI1 default "")
					} else {},
					if (($[0].SAAB2 != null and $[0].SAAB2 != "") or ($[0].SABI2 != null and $[0].SABI2 != "")){
						attributeType : "1",
						startTime : globalDataweaveFunctions::timeConversion($[0].SAAB2 default ""),
						endTime : globalDataweaveFunctions::timeConversion($[0].SABI2 default "")
					} else {}])
				},
				{
					isHoliday : false,
					patternFrequencyCode : "DAY_OF_WEEK",
					patternFrequency : {
						weekly : {
							weeksOfRecurrence : 1,
							dayOfWeek : [
								"SUNDAY"
							]
						}
					},
					(calendarAttribute : [
						if (($[0].SOAB1 != null and $[0].SOAB1 != "") or ($[0].SOBI1 != null and $[0].SOBI1 != "")){
						attributeType : "1",
						startTime : globalDataweaveFunctions::timeConversion($[0].SOAB1 default ""),
						endTime : globalDataweaveFunctions::timeConversion($[0].SOBI1 default "")
					} else {},
					if (($[0].SOAB2 != null and $[0].SOAB2 != "") or ($[0].SOBI2 != null and $[0].SOBI2 != "")){
						attributeType : "1",
						startTime : globalDataweaveFunctions::timeConversion($[0].SOAB2 default ""),
						endTime : globalDataweaveFunctions::timeConversion($[0].SOBI2 default "")
					} else {}])
				}]
			}
		}).*root
}