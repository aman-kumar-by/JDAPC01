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
output application/json skipNullOn = "everywhere", encoding = "UTF-8"
import lookup_utils::globalDataweaveFunctions
---
{
	header: {
		sender: p('sap.sender'),
		receiver: (p("sap.receiver.actualCustomerOrder.csv") splitBy ","),
		model: "BYDM",
		messageVersion: "BYDM 2021.2.0",
		messageId: uuid(),
		'type': "orderClose",
		creationDateAndTime: now() as DateTime {
			format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
		}
	},
	orderClose: (payload default [] map {
		creationDateTime: globalDataweaveFunctions::formatDateToDateTime(globalDataweaveFunctions::formatDate($.ERDAT default "")),
		documentStatusCode: "ORIGINAL",
		documentActionCode: "ADD",
		demandChannel: globalDataweaveFunctions::demandChannelChk($.VKORG default "" ++ p('sap.demandChannel.delimiter') ++ $.VTWEG default ""),
		orderId: $.VBELN,
		orderTypeCode: "10006",
		buyer: {
			primaryId: $.KUNNR
		},
		supplier: {
			primaryId: $.VKORG
		},
		orderLogisticalInformation: {
			shipTo: {
				primaryId: "*UNKNOWN"
			}
		},
		lineItem: [{
			lineItemNumber: $.POSNR as Number,
			demandChannel: globalDataweaveFunctions::demandChannelChk($.VKORG default "" ++ p('sap.demandChannel.delimiter') ++ $.VTWEG default ""),
			isReservedOrder: false,
			planningStatus: 1,
			requestedQuantity: {
				value: $.BMENG as Number,
				measurementUnitCode: if ( not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""]) ) vars.uomCodeMap.measurementUnitCodeMap[$.MEINS] else $.MEINS
			},
			netPrice: {
				value: $.NETPR as Number,
				currencyCode: $.WAERK
			},
			transactionalTradeItem: {
				primaryId: $.MATNR
			},
			lineItemDetail: [{
				requestedQuantity: {
					value: $.BMENG as Number,
					measurementUnitCode: if ( not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""]) ) vars.uomCodeMap.measurementUnitCodeMap[$.MEINS] else $.MEINS
				},
				orderLogisticalInformation: {
					shipFrom: {
						primaryId: $.WERKS
					},
					shipTo: {
						primaryId: $.KUNNR
					},
					orderLogisticalDateInformation: {
						requestedDeliveryDateTime: {
							date: globalDataweaveFunctions::formatDate($.VDATU default "")
						},
						requestedShipDateTime: {
							date: globalDataweaveFunctions::formatDate($.WADAT default "")
						}
					}
				}
			}],
			avpList: [{
				(if ( $.LPRIO != null ) name: "orderLinePriority" else {
				}),
				value: $.LPRIO
			},
				{
				name: "deliveryMethodCode",
				qualifierCodeList: "DeliveryMethodTypeCode",
				value: "Ship"
			},
								{
				(if ( $.WADAT_IST != "" and $.WADAT_IST != null and $.WADAT_IST != "00000000" ) name: "actualExecutionDateTime" else {
				}),
				(value: globalDataweaveFunctions::formatDate($.WADAT_IST default "") ++ 'T' ++ globalDataweaveFunctions::timeConversion((($.SPE_WAUHR_IST default "") as String {
					format : "000000"
				})) ++ "+00:00") if ($.WADAT_IST != "" and $.WADAT_IST != null and $.WADAT_IST != "00000000")
			},
								{
				(if ( $.'OPENQTY/CLOSEDQTY' != null ) name: "actualQuantity" else {
				}),
				value: $.'OPENQTY/CLOSEDQTY'
			}]
		}]
	})
}