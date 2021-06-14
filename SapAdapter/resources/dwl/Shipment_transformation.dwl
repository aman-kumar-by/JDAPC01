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
output application/json  skipNullOn="everywhere", encoding="UTF-8"
import lookup_utils::globalDataweaveFunctions
---
{
	header : {
		sender : p('sap.sender'),
		receiver : (p("sap.receiver.shipmentHistory") splitBy ","),
		model : "BYDM",
		messageVersion : "BYDM 2021.2.0",
		messageId : uuid(),
		'type' : "inventoryTransaction2",
		creationDateAndTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"}
        // testMessage : false
	},
	inventoryTransaction2:
		(payload default {} pluck using (data1 = $$ splitBy "_88_")  {
		itemId: data1[1],
		demandChannel: data1[6],
		locationId: data1[3],
		(transactionCode: (if (data1[2] == "J") "142" else if (data1[2] == "T") "141" else "")) if(not isEmpty(data1[2])),
		startDate: (globalDataweaveFunctions::formatDate (data1[4] default "")),
		(quantity: {
			measurementUnitCode: ((if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[data1[5] default 0])) vars.uomCodeMap.measurementUnitCodeMap[data1[5]] else data1[5]  default 0)),
			value: $.quantity 
		}) if (data1[5] != null and data1[5] != ""),
	})
}
