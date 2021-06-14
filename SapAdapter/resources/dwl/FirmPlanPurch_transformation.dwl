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
		sender :  p('sap.sender'),
		receiver : (p("sap.receiver.firmPlanPurch") splitBy ","),
		model : "BYDM",
		messageVersion : "BYDM 2021.2.0",
		messageId : uuid(),
		'type' : "plannedSupply",
		creationDateAndTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"}
		//testMessage : false
		},
		plannedSupply:
	(payload default [] map (record, index) -> {
				creationDateTime : now() as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
				documentStatusCode : "ORIGINAL",
				documentActionCode : "ADD",
				plannedSupplyId : {
					item: {
						primaryId : record.MATNR	
						  },
					shipTo : {
						primaryId : record.WERKS
							}
				},
				"type" : "PLAN_PURCHASE",
				plannedSupplyDetail : [{
					requestedDeliveryDate : globalDataweaveFunctions::formatDate(record.LFDAT default ""),
					isFirmPlannedSupply : true,
					requestedQuantity : {
									value: ((record.MENGE as String) replace "," with "") as Number
					}
											
				}]
		}
	)
}