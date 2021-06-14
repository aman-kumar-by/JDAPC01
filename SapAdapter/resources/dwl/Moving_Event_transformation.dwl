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
{
		header : {
		sender : p('sap.sender'),
		receiver : (p("sap.receiver.movingEvent") splitBy ","),
		model : "BYDM",
		messageVersion : "BYDM 2021.2.0",
		messageId : uuid(),
		'type' : "eventGroup",
		creationDateAndTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"}
	// testMessage : false
	},
		eventGroup : ((payload groupBy(item) -> item.IDENT) mapObject {
			(root : {
				creationDateTime: now() as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
				documentStatusCode: "ORIGINAL",
				documentActionCode: "ADD",
				eventGroupId : ($$),
				name: ($.LTEXT_H filter(key,value) -> (value != null))[0],
				description: {
					value: ($.LTEXT_H filter(key,value) -> (value != null))[0],
					languageCode: lower(($.SPRAS_H filter(key,value) -> (value != null))[0])
					//descriptionType: _descriptionType_
				},
			event: ($ filter ((not isEmpty($.DATUM)) and sizeOf($.DATUM) == 8 and ($.DATUM as Number) >0) map {
				actionCode: "CHANGE",
				eventName: ((($$) default "") ++ "_" ++ ($.FTGID default "") ++ "_" ++ ($.KTEXT default "")),
				description: {
					value: $.LTEXT,
					languageCode: lower($.SPRAS)
					//descriptionType: _descriptionType_
				},
						isMovingEvent: if($.REGEL == 'F') false else true,
						(eventDate : [{
							actionCode: "CHANGE",
							eventDate: $.DATUM as Date {format : "yyyyMMdd"} as Date {format : "yyyy-MM-dd"},
							isPublicHoliday: true
						}])
					}),
					eventLocation: ($ filter (not isEmpty($.WERKS)) map {
						actionCode: "CHANGE",
						location: {
							primaryId : $.WERKS
						},
						(effectiveFromDate: $.VJAHR ++ "-01-01") if (not isEmpty($.VJAHR)), // as Date {format : "yyyyMMdd"} as Date {format : "yyyy-MM-dd"},
						(effectiveUpToDate: $.BJAHR ++ "-12-31") if (not isEmpty($.BJAHR))
					})
			}) if(not isEmpty($.LTEXT_H[0]))
		}).*root
	}
