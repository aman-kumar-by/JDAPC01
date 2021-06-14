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
		sender : p("sap.sender"),
		receiver : (p("sap.receiver.inventory.onhand") splitBy ","),
		model : "BYDM",
		messageVersion : "BYDM 2021.2.0",
		messageId : uuid(),
		'type' : "inventoryOnHand2",
		creationDateAndTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"}
		//testMessage : false
	},
	inventoryOnHand2 :
		(payload default [] map  {
			itemId : $.MATNR, 
			locationId : $.WERKS,
			(quantity : {
				measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEINS] else $.MEINS,
				value : if ($.QUANT endsWith "-") ( ("-" ++ ($.QUANT[0 to (($.QUANT find "-")[0] -1)])) as Number) else $.QUANT as Number
			}) if (not (isEmpty($.QUANT))),
			bestBeforeDate : globalDataweaveFunctions::formatDate($.VFDAT default ""),
			availableForSupplyDate : globalDataweaveFunctions::formatDate($.SDATE default ""),
			storageLocation : $.LGORT,
			inventoryStatus : if (not isEmpty($.STCAT)) 
									(if ($.STCAT == "UR") "AVAILABLE_FOR_SALE" 
									else if ($.STCAT == "QI") "INSPECT" 
									else if ($.STCAT == "RE") "RETURNED" 
									else if ($.STCAT == "BL") "ON_HOLD" 
									else if ($.STCAT == "TR") "IN_TRANSIT" 
									else if ($.STCAT == "RS") "PUT_ASIDE" 
									else "")
			 				else "AVAILABLE_FOR_SALE",
			onHandMeasureCode : if (not isEmpty($.STCAT)) 
									(if ($.STCAT == "UR") "On Hand" 
									else if ($.STCAT == "QI") "Total Stock" 
									else if ($.STCAT == "RE") "Total Stock" 
									else if ($.STCAT == "BL") "Total Stock" 
									else if ($.STCAT == "TR") "Total Stock" 
									else if ($.STCAT == "RS") "Total Stock" 
									else "") 
								else "On Hand",
			batchNumber : $.CHARG,
			lotNumber : $.CHARG,
			onHandPostDateTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"}	
			
		})
}