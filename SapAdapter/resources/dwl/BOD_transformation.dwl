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
    (payload default[] map {
			creationDateTime :  now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
			documentStatusCode : "ORIGINAL",
			documentActionCode : "CHANGE_BY_REFRESH",
			networkId : if (($.ROUTE != null) and ($.ROUTE != "") ) $.ROUTE else ($.SOURCE default "" ++ $.DEST default "" ++ $.ITEM default "" ++ $.TRANSMODE default ""),
			pickUpLocation : {
				locationId : $.SOURCE
			},
			dropOffLocation : {
				locationId : if($.DEST != null and $.DEST != "") $.DEST else $.KUNNR
			},
			transportModeCode : $.VSART,
			transportEquipmentTypeCode : {
				value : if ($.TRANSMODE != "") $.TRANSMODE else "*UNKNOWN"
			},
			freightCharacteristics : {
				(transitDuration : {
					value :  ($.TRANSLEADTIME default 0) as Number,
					timeMeasurementUnitCode : "DAY"
				}) if($.TRANSLEADTIME != null and $.TRANSLEADTIME != "")
			},
			sourcingInformation : [{
				sourcingMethod : ($.SOURCE default "" ++ $.DEST default "" ++ $.ITEM default "" ++ $.TRANSMODE default ""),
				sourcingItem : {
					itemId : $.ITEM
				},
				procurementCalendar : $.SPFBK,
				sourcingDetails : {
					procurementDetails : { 
						(maximumOrderQuantity : {
							value : ($.LFMAX default 0) as Number,
							measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEINS] else $.MEINS
						}) if($.LFMAX != null and $.LFMAX != ""), 
						(minimumOrderQuantity : {
							value : ($.LFMNG default 0) as Number
						}) if($.LFMNG != null and $.LFMNG != ""),
						(incrementalOrderQuantity : {
							value : ($.BSTRF default 0) as Number
						})  if($.BSTRF != null and $.BSTRF != "")
					}
				}
				
			}],
			laneInformation : [{
				fromSupplier : $.NAME1_S,
				toCustomer : $.NAME1_C
			}]
	})
}