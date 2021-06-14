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
output application/json encoding="UTF-8", skipNullOn="everywhere"
---
{
	header : {
		sender :  p('sap.sender'),
		receiver : (p("sap.receiver.item.csv") splitBy ","),
		model : "BYDM",
		messageVersion : "BYDM 2021.3.0",
		messageId : uuid(),
		'type' : "item",
		creationDateAndTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"}
		//testMessage : false
	},	
	item :
		(payload default [] groupBy (if (not isEmpty ($.MATNR_LONG)) $.MATNR_LONG else $.MATNR) pluck (record) -> using (hierarchyInfo = record[0].PRDHA) {
			creationDateTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
			documentStatusCode : "ORIGINAL",
			documentActionCode : "ADD",
			itemId : {
				primaryId : if (not isEmpty (record[0].MATNR_LONG)) record[0].MATNR_LONG else record[0].MATNR,
				itemName : record[0].MAKTX
			},
			(description : [{
					value : record[0].MAKTX,
					languageCode : if (not isEmpty (record[0].SPRAS)) lower(record[0].SPRAS) else "en", 
					descriptionType : "ITEM_NAME"	
			}]) if (record[0].MAKTX != "" and record[0].MAKTX != null),
			countryOfOrigin : [ record[0].HERKL ],
			tradeItemBaseUnitOfMeasure : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[record[0].MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[record[0].MEINS] else record[0].MEINS,
			(itemHierarchyInformation : {
				ancestry : [{
						hierarchyLevelId : "3",
						memberId : hierarchyInfo
				}]
			}) if (not isEmpty(hierarchyInfo)),
			itemLogisticUnitInformation : [{
				actionCode : "ADD",
				//isDefaultLogisticUnitConfiguration : if (record[0].MEINS == record[0].MEINH) true else false,
				itemLogisticUnit : 
				(record map {
					logisticUnitName : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINH default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEINH] else $.MEINH,
					actionCode : "ADD",
					(tradeItemQuantity : {
						value : (((trim($.UMREZ default "0") as Number) / trim($.UMREN)) as Number),
						measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEINS] else $.MEINS
					}) if (((((trim($.UMREZ default "0") as Number) / trim($.UMREN)) as Number) > 0) and (trim(($.UMREN default "0") as Number) > 0)),
					tradeItemQuantityPerLayer: {
							value: 1
					},
					packageLevelNumber : ($$ + 1),
					(grossWeight : {
						value : if ((trim($.BRGEW_UOM default "0") as Number) > 0) (trim($.BRGEW_UOM default "0") as Number) else ((trim($.BRGEW default "0") as Number) * (((trim($.UMREZ default "0") as Number) / trim($.UMREN)) as Number)),
						measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.GEWEI_UOM default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.GEWEI_UOM] else $.GEWEI_UOM
					}) if (((trim($.BRGEW_UOM default "0") as Number) > 0) or ((((trim($.BRGEW default "0") as Number) * (((trim($.UMREZ default "0") as Number) / trim($.UMREN)) as Number)) > 0) and (trim(($.UMREN default "0") as Number) > 0))),
					(netWeight : {
						value : (((trim($.NTGEW default "0")) as Number) * (((trim($.UMREZ default "0") as Number) / trim($.UMREN)) as Number)),
						measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.GEWEI default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.GEWEI] else $.GEWEI
					}) if ((($.NTGEW as Number default 0) > 0) and ((trim($.UMREN default "0") as Number) > 0)),
					dimensionsOfLogisticUnit : {
						(depth : {
							value : $.LAENG as Number,
							measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEABM default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEABM] else $.MEABM
						}) if (not (isEmpty($.LAENG))),
						(height : {
							value : $.HOEHE as Number,
							measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEABM default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEABM] else $.MEABM
						}) if (not (isEmpty($.HOEHE))),
						(width : {
							value : $.BREIT as Number,
							measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEABM default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEABM] else $.MEABM
						}) if (not (isEmpty($.BREIT))),
					},
					(grossVolume : {
						value : if ((trim($.VOLUM_UOM default "0") as Number) > 0) (trim($.VOLUM_UOM default "0") as Number) else ((trim($.VOLUM default "0") as Number) * (((trim($.UMREZ default "0") as Number) / trim($.UMREN)) as Number)),
						measurementUnitCode : if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.VOLEH_UOM default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.VOLEH_UOM] else $.VOLEH_UOM
					}) if (((trim($.VOLUM_UOM default "0") as Number) > 0) or ((((trim($.VOLUM default "0") as Number) * (((trim($.UMREZ default "0") as Number) / trim($.UMREN)) as Number)) > 0) and (trim(($.UMREN default "0") as Number) > 0))),
					isCaseEquivalent : if (($.MEINH == "CS") or ($.MEINH == "CSE")) true else false,
					isPackEquivalent : if ($.MEINH == "PK") true else false,
					isPalletEquivalent : if ($.MEINH == "PF") true else false
				})
			}],
			status : [{
				statusCode : if((record[0].LVORM default "") == "X") "INACTIVE" else "ACTIVE"
			}],
			classifications : {
				itemType : record[0].MTART,
				itemFamilyGroup : record[0].MATKL default "",
				lineOfBusiness : record[0].SPART,
				handlingInstruction : [
					({
						handlingInstructionCode : "PER"
					}) if ((lower(record[0].MTART default ""))=="frip"),
					({
						handlingInstructionCode : "TMC"
					}) if (not isEmpty(record[0].TEMPB)),
					({
						handlingInstructionCode : "DAE",
						handlingInstructionText : {
							value : record[0].STOFF,
							languageCode : "en"
						}
					}) if (not isEmpty(record[0].STOFF))
				]
			},
			tradeItemMeasurements : {
				(inBoxCubeDimension : {
					value : record[0].VOLUM as Number,
					measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[record[0].VOLEH default ""])) vars.uomCodeMap.measurementUnitCodeMap[record[0].VOLEH] else record[0].VOLEH
				}) if ((record[0].VOLUM as Number default 0) > 0),
				tradeItemWeight : {
					(grossWeight : {
						value : trim(record[0].BRGEW default "0") as Number,
						measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[record[0].GEWEI default ""])) vars.uomCodeMap.measurementUnitCodeMap[record[0].GEWEI] else record[0].GEWEI
					}) if ((record[0].BRGEW as Number default 0) > 0),
					(netWeight : {
						value : trim(record[0].NTGEW default "0") as Number,
						measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[record[0].GEWEI default ""])) vars.uomCodeMap.measurementUnitCodeMap[record[0].GEWEI] else record[0].GEWEI
					}) if ((record[0].NTGEW as Number default 0) > 0)
				}
			},
			operationalRules : {
				trackingInformation : {
					trackLotNumbers : if (upper(record[0].XCHPF default "o") =="X") true else false
				},
				receiveInventoryStatus : "AVAILABLE_FOR_SALE",
				(shelfLife : {
					value : record[0].MHDHB as Number,
					timeMeasurementUnitCode : if(isEmpty(record[0].IPRKZ)) "DAY" else if(record[0].IPRKZ as Number == 1) "WEE" else if(record[0].IPRKZ as Number == 2) "MON" else if(record[0].IPRKZ as Number == 3) "ANN" else "DAY"
				}) if (record[0].MHDHB != null and record[0].MHDHB != "" and record[0].MHDHB != "0")
			},
			measurementTypeConversion : (record map {
				sourceMeasurementUnitCode : {
					measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINH default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEINH] else $.MEINH
				},
				targetMeasurementUnitCode : {
					measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEINS] else $.MEINS
				},
				(ratioOfTargetPerSource : ((((trim($.UMREZ default "0")) as Number) / trim($.UMREN)) as String {format : "#.###############"}) as Number) if (((trim($.UMREN default "0")) as Number) > 0)
			})
		})
}