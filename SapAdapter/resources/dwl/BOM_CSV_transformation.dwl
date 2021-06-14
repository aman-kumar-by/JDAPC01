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
		receiver : (p("sap.receiver.bom.csv") splitBy ","),
		model : "BYDM",
		messageVersion : "BYDM 2021.2.0",
		messageId : uuid(),
		'type' : "billOfMaterial",
		creationDateAndTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"}
		//testMessage : false
		},
		
			billOfMaterial: 
			(payload groupBy ($.BOMIdent default "" ++ '_' ++ $.AltBOM default "") pluck{
					creationDateTime : now() as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
					documentStatusCode: "ORIGINAL",
					documentActionCode: "CHANGE_BY_REFRESH",
					billOfMaterialId : $[0].BOMIdent,
					(item : {
						primaryId : $[0].BOMNum
					}) if (not isEmpty($[0].BOMNum)),
					(location : {
						primaryId : $[0].Location
					}) if (not isEmpty($[0].Location)),
					(billOfMaterialNumber : $[0].AltBOM as Number) if(not isEmpty($[0].AltBOM)),
					(billOfMaterialTypeCode : $[0].BOMUsage) if(not isEmpty($[0].BOMUsage)),
					component : ($ groupBy ($.BOMNum default "" ++ $.AltBOM default "" ++ $.Item default "" ++ $.Location default "") mapObject using (offsetsize = sizeOf($[0].Offset default [])) {
						comp : {
							componentItem : {
								primaryId : $[0].Item
							},
							componentLocation : {
								primaryId : $[0].Location
							},
							effectiveFromDate : globalDataweaveFunctions::formatDate($[0].EffDate default ""),
							effectiveUpToDate : globalDataweaveFunctions::formatDate(p('default.date.discontinueDate') default ""),
							(offset : {
								value : if($[0].Offset contains "-") ("-" ++ ($[0].Offset[0 to (offsetsize - 2)])) as Number else $[0].Offset as Number,
								timeMeasurementUnitCode : "DAY"
							})if($[0].Offset != null and not isEmpty($[0].Offset)),
							(
								drawQuantity : {
									value : $[0].DrawQty as Number,
									measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$[0].QtyUOM default ""])) vars.uomCodeMap.measurementUnitCodeMap[$[0].QtyUOM] else $[0].QtyUOM
								}	
							) if($[0].DrawQty != null and not isEmpty($[0].DrawQty)),
							yieldFactor : 100 - ($[0].YieldFactor as Number default 0),
							(substituteComponent: ($ filter ($.AltSubord != null and not isEmpty($.AltSubord)) map {
								substituteItem : {
									primaryId : $.AltSubord
								},
								substituteLocation : {
									primaryId : $.Location
								},
								effectiveFromDate : globalDataweaveFunctions::formatDate($.AltSubordEff default ""),
								effectiveUpToDate : globalDataweaveFunctions::formatDate(p('default.date.discontinueDate') default ""),
								(
									drawQuantity : {
									value : $.AltSubordDrawQty as Number,
									measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.AltSubordDrawQtyUOM default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.AltSubordDrawQtyUOM] else $.AltSubordDrawQtyUOM
									}	
								)if($.AltSubordDrawQty != null and not isEmpty($.AltSubordDrawQty)),
								yieldFactor : $.AltSubordYieldFactor as Number
							}))
						}
					}).*comp
			})
}
