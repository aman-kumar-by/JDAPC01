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
		sender : p('sap.sender'),
		receiver : (p("sap.receiver.actualPurchaseOrder.csv") splitBy ","),
		model : "BYDM",
		messageVersion : "BYDM 2021.2.0",
		messageId : uuid(),
		'type' : "orderClose",
		creationDateAndTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"}
	},
	orderClose : ((payload groupBy($.EBELN default "")) mapObject {
		root : {
		creationDateTime : globalDataweaveFunctions::formatDateToDateTime(globalDataweaveFunctions::formatDate($[0].AEDAT default "")),
		documentStatusCode : "ORIGINAL",
		documentActionCode : "CHANGE_BY_REFRESH",
		purchaseMethod : $[0].LIFNR,
		orderId : $[0].EBELN,
		orderTypeCode : "10007",
		buyer :{
			primaryId : $[0].WERKS
		},
		supplier : {
			primaryId : $[0].LIFNR
		},
		orderLogisticalInformation : {
			shipTo : {
				primaryId : $[0].WERKS
			}
		},
		lineItem : ($ map {
				lineItemNumber : ($.EBELP default "" ++  $.ETENS default "") as Number,
				requestedQuantity : {
						value : $.MENGE as Number,
						measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEINS] else $.MEINS
					},
					netPrice : {
					value : $.BRTWR as Number,
					currencyCode : $.WAERS
					},
				transactionalTradeItem : {
					//gtin : "00000000000000",
					primaryId : $.MATNR
				},
				lineItemDetail : [{
				requestedQuantity : {
						value : $.MENGE as Number,
						measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEINS] else $.MEINS
					},
					orderLogisticalInformation : {
						shipFrom : {
							primaryId : $.LIFNR
						},
						shipTo : {
							primaryId : $.WERKS
						},
						orderLogisticalDateInformation : {
							requestedDeliveryDateTime : {
								date : globalDataweaveFunctions::formatDate($.EINDT default "")
							}
						}
					}
				}]
		})
		
	}
	}).*root
}