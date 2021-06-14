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
var vllCsv = vars.entityMap..vllCsv[0]
import lookup_utils::globalDataweaveFunctions
---
{
	header : {
		sender :  p('sap.sender'),
		receiver : (p("sap.receiver.vehicleLoadLine") splitBy ","),
		model : "BYDM",
		messageVersion : "BYDM 2021.2.0",
		messageId : uuid(),
		'type' : "transportLoad",
		creationDateAndTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"}
		//testMessage : false
		},
		
		transportLoad : using (varTransLoad = ((payload groupBy(VLL) -> VLL.IDENT) mapObject
		{
			(transLoad : {
				creationDateTime : now() as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
				documentStatusCode : "ORIGINAL",
				documentActionCode : "ADD", // TODO: if STATUS = open-->"ADD" ELSE --> "CBR"
				//added avpList Auto-Customization
				avpList: using( varAvpList = ($ map {
                   ($ mapObject (val, key) -> {
                       avpL:{
							(name: (key) as String) if((not isEmpty(vllCsv[(key) as String])) and (not isEmpty((val)))),
							(value :(val))if((not isEmpty(vllCsv[(key) as String])) and (not isEmpty((val))))
                       }
                   })
                })) varAvpList.*avpL,
				transportLoadId : if($$!=null) $$ else "",

				loadStatusCode : if ($[0].WBSTK == "C") "IN_TRANSIT" else "PLANNED",
				logisticServicesSeller : {
					primaryId : "*UNKNOWN"
				},
				logisticServicesBuyer : {
					primaryId : "*UNKNOWN"
				},
				transportModeCode : "30",
				transportCargoCharacteristics : {
					cargoTypeCode : "12"
				},
				transportServiceCategoryType : "30",
				transportEquipment : {
					transportEquipmentTypeCode :{
						value: if ($[0].TRMTYP == "" or $[0].TRMTYP == null) "*UNKNOWN" else $[0].TRMTYP
					} 
				},
				stop :[{
					stopSequenceNumber : 1 as Number,
					stopLocation : {
						gln : "0000000000000",
					},
					stopLogisticEvent : [
						{
						logisticEventTypeCode : "TERMINAL_ARRIVAL",
						logisticEventDateTime : {
							"date" : globalDataweaveFunctions::formatDate($[0].LFDAT default "")
							}
						},
						{
						logisticEventTypeCode : "TERMINAL_DEPARTURE",
						logisticEventDateTime : {
							"date" : if ((globalDataweaveFunctions::formatDate($[0].WADAT_IST default "") != "")) globalDataweaveFunctions::formatDate($[0].WADAT_IST default "") else globalDataweaveFunctions::formatDate($[0].WADAT default "")
							}	
						}
					]
				}],
				shipment: ( $ map {
						primaryId: if ($.VBELN != null and $.VBELN != "") $.VBELN else "00000",
						(parentShipmentID : {
							primaryId: $.TPNUM
						}) if ($.TPNUM != null and $.TPNUM != ""),
						receiver : {
							primaryId: "0000000000000"
						},
						shipper : {
							primaryId: "0000000000000"
						},
						shipTo: {
							primaryId: $.DWERK

						},
						shipFrom: {
							primaryId: $.SWERK						
						},
						logisticServiceRequirementCode : "2",
						transportServiceCategoryType : "30",
						transportCargoCharacteristics : {
							cargoTypeCode : "12"
						},
						plannedDelivery : {
							logisticEventDateTime : {
								date : globalDataweaveFunctions::formatDate($.LFDAT default "")
							}
						},
						plannedDespatch : {
							logisticEventDateTime : {
								date : globalDataweaveFunctions::formatDate($.WADAT default "")
							}
						},
						(transportReference : [{
							entityId : $.EBELN,
							typeCode : "TO"
						}]) if ($.EBELN != null and $.EBELN != ""),
						shipmentItem : [{
							lineItemNumber : $.POSNR as Number,
						
							transactionalTradeItem : [{
								primaryId: $.MATNR,
								tradeItemQuantity :{
									value: $.LFIMG as Number 
								}
							}],
							requestedTradeItem : {
								primaryId: $.MATNR
							}
						}]
				} )
			})
		}))varTransLoad.*transLoad
}