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
var defaultEndDate = "9999-12-31"
var defaultStartDate = "1900-01-01"
var defaultCalenderPatternStartDate = "2000-01-01"
var capacityCategoriesList =  p('valid.capacity.categories') splitBy "," map trim($)
import lookup_utils::globalDataweaveFunctions
---
({
		(payload.*IDOC map (idoc, index) -> {
		root : 
			((idoc.E1CRHDL.*E1CRCAL filter (capacityCategoriesList contains $.E1KAKOL.KAPAR)) map (resource, resourceIndex) ->  using (versaValue = if ((resource.E1KAKOL.VERSA == "") or (resource.E1KAKOL.VERSA == null) or (resource.E1KAKOL.VERSA == "00")) "01" else resource.E1KAKOL.VERSA) {
					creationDateTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
					documentStatusCode : "ORIGINAL",
					documentActionCode : "CHANGE_BY_REFRESH",
					lastUpdateDateTime : globalDataweaveFunctions::formatDateToDateTime(globalDataweaveFunctions::formatDate(idoc.EDI_DC40.CREDAT default "")),
					senderDocumentId : idoc.EDI_DC40.DOCNUM,
					resourceId : idoc.E1CRHDL.ARBPL default "" ++ idoc.E1CRHDL.WERKS default "" ++ resource.E1KAKOL.KAPAR default "",
					description : {
						value : (if (isEmpty(idoc.E1CRHDL.*E1CRTXL filter ((e1crtxl, index) -> (e1crtxl.SPRAS == "E")))) idoc.E1CRHDL.*E1CRTXL[0].KTEXT else (idoc.E1CRHDL.*E1CRTXL filter((e1crtxl, index) -> (e1crtxl.SPRAS == "E")))[0].KTEXT) default "" ++ idoc.E1CRHDL.WERKS default "" ++ resource.E1KAKOL.KAPAR default "",
						languageCode : "en"
					},
					capacityConstraintType : if ((resource.E1KAKOL.UEBERLAST default "") == "000") 1 else 3,
					resourceLocation : {
						primaryId : idoc.E1CRHDL.WERKS,
					},
					resourceCategory : 4,
					productionAdjustmentFactor : 100,
					resourceCalendar : {
						calendarId : idoc.E1CRHDL.ARBPL default "" ++ idoc.E1CRHDL.WERKS default "" ++ resource.E1KAKOL.KAPAR default "",
						description : {
							value : (if (isEmpty(idoc.E1CRHDL.*E1CRTXL filter ((e1crtxl, index) -> (e1crtxl.SPRAS == "E")))) idoc.E1CRHDL.*E1CRTXL[0].KTEXT else (idoc.E1CRHDL.*E1CRTXL filter((e1crtxl, index) -> (e1crtxl.SPRAS == "E")))[0].KTEXT) default "" ++ idoc.E1CRHDL.WERKS default "" ++ resource.E1KAKOL.KAPAR default "",
							languageCode : "en"
						},
						calendarStartDate : defaultStartDate,
						calendarEndDate : defaultEndDate,
						calendarType : "PRODUCTION_CAPACITY",
						pattern : ( if ((not isEmpty(resource.E1KAKOL.*E1KAZYL)) and (not isEmpty(resource.E1KAKOL.*E1KAZYL filter (versaValue == $.VERSN)))) 
							xx: ((resource.E1KAKOL.*E1KAZYL filter (versaValue == $.VERSN)) map(e1kzylValue,e1kzylIndex) -> {
							(
							if (not isEmpty(e1kzylValue.*E1KAPAL))(e1kzylValue.*E1KAPAL map(e1kapalValue, e1kapalIndex) -> { 
									name : idoc.E1CRHDL.ARBPL default "" ++ idoc.E1CRHDL.WERKS default "" ++ resource.E1KAKOL.KAPAR default "",
									rank : (e1kzylIndex + 1) as Number,
									startDate : if ((e1kzylValue.DATUV default "") == "00000000") defaultCalenderPatternStartDate else globalDataweaveFunctions::formatDate(e1kzylValue.DATUV default ""),
									endDate : if (e1kzylValue.DATUB == null) defaultEndDate else globalDataweaveFunctions::formatDate(e1kzylValue.DATUB default ""),
									patternFrequencyCode : if(e1kzylValue.ANZTG == "07") "DAY_OF_WEEK" else "EVERY_DAY",
									patternFrequency : {
										weekly : 
											dayOfWeek : [
												if(e1kzylValue.ANZTG == "07") (if (e1kapalValue.TAGNR == "001") "MONDAY" else if (e1kapalValue.TAGNR == "002") "TUESDAY" else if (e1kapalValue.TAGNR == "003") "WEDNESDAY" else if (e1kapalValue.TAGNR == "004") "THURSDAY" else if (e1kapalValue.TAGNR == "005") "FRIDAY" else if (e1kapalValue.TAGNR == "006") "SATURDAY" else if (e1kapalValue.TAGNR == "007") "SUNDAY" else null) else null
											]
									},
									calendarAttribute : [
										{
										attributeType : "6",
										value : ((e1kapalValue.KAPAZ/3600) as Number)*(e1kapalValue.ANZHL) as Number,
										startTime : ((globalDataweaveFunctions::secondsToTimeFormat((e1kapalValue.BEGZT)/3600)) ++ ":" ++ (globalDataweaveFunctions::secondsToTimeFormat (((e1kapalValue.BEGZT) mod 3600)/60)) ++ ":" ++ (globalDataweaveFunctions::secondsToTimeFormat (((e1kapalValue.BEGZT) mod 3600) mod 60))),
										endTime : if (((globalDataweaveFunctions::secondsToTimeFormat((e1kapalValue.ENDZT)/3600)) ++ ":" ++ (globalDataweaveFunctions::secondsToTimeFormat (((e1kapalValue.ENDZT) mod 3600)/60)) ++ ":" ++ (globalDataweaveFunctions::secondsToTimeFormat (((e1kapalValue.ENDZT) mod 3600) mod 60))) == "00:00:00") "23:59:59" else ((globalDataweaveFunctions::secondsToTimeFormat((e1kapalValue.ENDZT)/3600)) ++ ":" ++ (globalDataweaveFunctions::secondsToTimeFormat (((e1kapalValue.ENDZT) mod 3600)/60)) ++ ":" ++ (globalDataweaveFunctions::secondsToTimeFormat (((e1kapalValue.ENDZT) mod 3600) mod 60)))
									}]
							})
							else {
									name : idoc.E1CRHDL.ARBPL default "" ++ idoc.E1CRHDL.WERKS default "" ++ resource.E1KAKOL.KAPAR default "",
									rank : (e1kzylIndex + 1) as Number,
									startDate : if ((e1kzylValue.DATUV default "") == "00000000") defaultCalenderPatternStartDate else globalDataweaveFunctions::formatDate(e1kzylValue.DATUV default ""),
									endDate : if (e1kzylValue.DATUB == null) defaultEndDate else globalDataweaveFunctions::formatDate(e1kzylValue.DATUB default ""),
									patternFrequencyCode : "EVERY_DAY",
									calendarAttribute : [{
										attributeType : "6",
										value : ((((resource.E1KAKOL.NGRAD)/100)*(abs(resource.E1KAKOL.ENDZT - (resource.E1KAKOL.BEGZT + resource.E1KAKOL.PAUSE))))/3600)*(resource.E1KAKOL.AZNOR) as Number,
										startTime : ((globalDataweaveFunctions::secondsToTimeFormat((resource.E1KAKOL.BEGZT)/3600)) ++ ":" ++ (globalDataweaveFunctions::secondsToTimeFormat (((resource.E1KAKOL.BEGZT) mod 3600)/60)) ++ ":" ++ (globalDataweaveFunctions::secondsToTimeFormat (((resource.E1KAKOL.BEGZT) mod 3600) mod 60))),
										endTime : if (((globalDataweaveFunctions::secondsToTimeFormat((resource.E1KAKOL.ENDZT)/3600)) ++ ":" ++ (globalDataweaveFunctions::secondsToTimeFormat (((resource.E1KAKOL.ENDZT) mod 3600)/60)) ++ ":" ++ (globalDataweaveFunctions::secondsToTimeFormat (((resource.E1KAKOL.ENDZT) mod 3600) mod 60))) == "00:00:00") "23:59:59" else ((globalDataweaveFunctions::secondsToTimeFormat((resource.E1KAKOL.ENDZT)/3600)) ++ ":" ++ (globalDataweaveFunctions::secondsToTimeFormat (((resource.E1KAKOL.ENDZT) mod 3600)/60)) ++ ":" ++ (globalDataweaveFunctions::secondsToTimeFormat (((resource.E1KAKOL.ENDZT) mod 3600) mod 60)))
									}]
								} 
							)
						}).xx
					else [{
								name : idoc.E1CRHDL.ARBPL default "" ++ idoc.E1CRHDL.WERKS default "" ++ resource.E1KAKOL.KAPAR default "",
								rank : 1,
								startDate : defaultCalenderPatternStartDate,
								endDate : defaultEndDate,
								patternFrequencyCode : "EVERY_DAY",
								calendarAttribute : [{
									attributeType : "6",
									value : ((((resource.E1KAKOL.NGRAD)/100)*(abs(resource.E1KAKOL.ENDZT - (resource.E1KAKOL.BEGZT + resource.E1KAKOL.PAUSE))))/3600)*(resource.E1KAKOL.AZNOR) as Number,
									startTime : ((globalDataweaveFunctions::secondsToTimeFormat((resource.E1KAKOL.BEGZT)/3600)) ++ ":" ++ (globalDataweaveFunctions::secondsToTimeFormat (((resource.E1KAKOL.BEGZT) mod 3600)/60)) ++ ":" ++ (globalDataweaveFunctions::secondsToTimeFormat (((resource.E1KAKOL.BEGZT) mod 3600) mod 60))),
									endTime : if (((globalDataweaveFunctions::secondsToTimeFormat((resource.E1KAKOL.ENDZT)/3600)) ++ ":" ++ (globalDataweaveFunctions::secondsToTimeFormat (((resource.E1KAKOL.ENDZT) mod 3600)/60)) ++ ":" ++ (globalDataweaveFunctions::secondsToTimeFormat (((resource.E1KAKOL.ENDZT) mod 3600) mod 60))) == "00:00:00") "23:59:59" else ((globalDataweaveFunctions::secondsToTimeFormat((resource.E1KAKOL.ENDZT)/3600)) ++ ":" ++ (globalDataweaveFunctions::secondsToTimeFormat (((resource.E1KAKOL.ENDZT) mod 3600)/60)) ++ ":" ++ (globalDataweaveFunctions::secondsToTimeFormat (((resource.E1KAKOL.ENDZT) mod 3600) mod 60)))
								}]
						}])
					}
			})
		})
}).root