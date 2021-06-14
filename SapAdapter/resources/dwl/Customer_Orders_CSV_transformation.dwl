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
		receiver : (p("sap.receiver.customerOrder.csv") splitBy ","),
		model : "BYDM",
		messageVersion : "BYDM 2021.2.0",
		messageId : uuid(),
		'type' : "customerOrder",
		creationDateAndTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"}
	// testMessage : false
	},
	customerOrder: ((payload groupBy(order) -> order.VBELN) mapObject {
		root: {
			creationDateTime: globalDataweaveFunctions::formatDateToDateTime(globalDataweaveFunctions::formatDate($[0].ERDAT default "")),
			documentStatusCode: "ORIGINAL",
			documentActionCode: "ADD",
			demandChannel : globalDataweaveFunctions::demandChannelChk($[0].VKORG default "" ++ p('sap.demandChannel.delimiter') ++ $[0].VTWEG default ""),
			orderId : $$,
			orderTypeCode : "221",
			buyer : {
				primaryId : $[0].KUNNR
			},
			supplier : {
				primaryId : $[0].VKORG
			},
			orderLogisticalInformation : {
				shipTo : {
					primaryId : "*UNKNOWN"
				}
			},
			lineItem : ( $ map {
					lineItemNumber : $.POSNR as Number,
					demandChannel : globalDataweaveFunctions::demandChannelChk($.VKORG default "" ++ p('sap.demandChannel.delimiter') ++ $.VTWEG default ""),
					isReservedOrder : false,
					planningStatus : 1,
					(if ($.'OPENQTY/CLOSEDQTY' != null and $.'OPENQTY/CLOSEDQTY' != "") {
						totalOpenQuantity: {
							value: $.'OPENQTY/CLOSEDQTY' as Number,
							measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEINS] else $.MEINS
						}
					} else {
					}),
					requestedQuantity : {
						value : $.BMENG as Number,
						measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEINS] else $.MEINS
					},
					(if ($.NETPR != null and $.NETPR != "") netPrice : {
						value : $.NETPR as Number,
						currencyCode : $.WAERK
					} else {
					}),
					transactionalTradeItem : {
						primaryId : $.MATNR
					},
					lineItemDetail: [{
						requestedQuantity : {
							value : $.BMENG as Number,
							measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEINS] else $.MEINS
						},
						orderLogisticalInformation : {
							shipFrom : {
								primaryId : $.WERKS
							},
							shipTo : {
								primaryId : $.KUNNR
							},
							orderLogisticalDateInformation : {
								requestedDeliveryDateTime : {
									(date : globalDataweaveFunctions::formatDate($.VDATU default ""))if(not isEmpty($.VDATU))
								},
								requestedShipDateTime : {
									date : if((not isEmpty($.WADAT)) and ($.WADAT != "00000000")) globalDataweaveFunctions::formatDate($.WADAT default "") else if((not isEmpty($.VDATU)) and ($.VDATU != "00000000")) globalDataweaveFunctions::formatDate($.VDATU default "") else ""
								}
							}
						}
					}],
					avpList : [{
						name : "orderLinePriority",
						value : $.LPRIO
					}]
			})
		}
	}).*root
}
