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
var calCsv = vars.entityMap..calCsv[0]
import lookup_utils::globalDataweaveFunctions
var calendarMonthDateStartDefaultValue = "-01-01"
var calendarMonthDateEndDefaultValue = "-12-31"
var calendarTypeValue = "WORKING"
var invalidDateValue = "00000000"
---
{		
	header : {
		sender :  p('sap.sender'),
		receiver : (p("sap.receiver.calendar") splitBy ","),
		model : "BYDM",
		messageVersion : "BYDM 2021.2.0",
		messageId : uuid(),
		'type' : "calendar",
		creationDateAndTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"}
		},
		calendar : using (varCal = ((payload groupBy(calendars) -> calendars.IDENT) mapObject {
			cals : {
				creationDateTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
				documentStatusCode : "ORIGINAL",
				documentActionCode : "CHANGE_BY_REFRESH",
				lastUpdateDateTime : (globalDataweaveFunctions::formatDate($[0].CRDAT default "") ++ "T" ++ $[0].CRTIME default ""),
				"calendarId": $[0].IDENT,
				
				description : {
						value: $[0].LTEXT
				},
				//added avpList Auto-Customization
				avpList: using( varAvpList = ($ map {
                   ($ mapObject (val, key) -> {
                       avpL:{
							(name: (key) as String) if((not isEmpty(calCsv[(key) as String])) and (not isEmpty((val)))),
							(value :(val))if((not isEmpty(calCsv[(key) as String])) and (not isEmpty((val))))
                       }
                   })
                })) varAvpList.*avpL,
				calendarStartDate : $[0].VJAHR ++ calendarMonthDateStartDefaultValue,
				calendarEndDate : $[0].BJAHR ++ calendarMonthDateEndDefaultValue,
				calendarType : calendarTypeValue, 
					(pattern : $ map {
						name : $.LTEXT,
						isHoliday : if (($.FETAG == "1") or ($.DATUM == invalidDateValue)) null else (if (($.MOTAG == "0") or ($.DITAG == "0") or ($.MIWCH == "0") or ($.DOTAG == "0") or ($.FRTAG == "0") or ($.SATAG == "0") or ($.SOTAG == "0")) true else false),
						startDate : if($.DATUM == invalidDateValue) ($.VJAHR ++ calendarMonthDateStartDefaultValue) else globalDataweaveFunctions::formatDate($.DATUM default ""),
						endDate : if($.DATUM == invalidDateValue) ($.BJAHR ++ calendarMonthDateEndDefaultValue) else globalDataweaveFunctions::formatDate($.DATUM default ""),
						patternFrequencyCode : "DAY_OF_WEEK",
						patternFrequency : {
							weekly : {
								weeksOfRecurrence : 1,
								dayOfWeek : [
								(globalDataweaveFunctions::returnDayOfWeek(($.DATUM as String), ($.MOTAG as String), "MONDAY")),
								(globalDataweaveFunctions::returnDayOfWeek(($.DATUM as String), ($.DITAG as String), "TUESDAY")),
								(globalDataweaveFunctions::returnDayOfWeek(($.DATUM as String), ($.MIWCH as String), "WEDNESDAY")),
								(globalDataweaveFunctions::returnDayOfWeek(($.DATUM as String), ($.DOTAG as String), "THURSDAY")),
								(globalDataweaveFunctions::returnDayOfWeek(($.DATUM as String), ($.FRTAG as String), "FRIDAY")),
								(globalDataweaveFunctions::returnDayOfWeek(($.DATUM as String), ($.SATAG as String), "SATURDAY")),
								(globalDataweaveFunctions::returnDayOfWeek(($.DATUM as String), ($.SOTAG as String), "SUNDAY"))
								]
							}
						},
						calendarAttribute : [ {
							attributeType : if ($.DATUM == invalidDateValue) "1" else "0"
						} ]
					}) if (not ($.FETAG == "1") and ($.DATUM != invalidDateValue))	
				}
			})
		) varCal.*cals
}