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
	(payload default[] map using (hierarchyInfo = $.PRDHA) {
		creationDateTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
		documentStatusCode : "ORIGINAL",
		documentActionCode : "ADD",
		itemId : {
			primaryId : $.MATNR
		},
		description : [{
			 value : $.MAKTX,
			 languageCode : if (not isEmpty($.SPRAS)) lower($.SPRAS) else "en", 
			 descriptionType : "ITEM_NAME"
		}],
		countryOfOrigin : [ $.HERKL ],
		tradeItemBaseUnitOfMeasure : if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEINS] else $.MEINS,
		(itemHierarchyInformation : {
			(ancestry : [
				({
					hierarchyLevelId : "level-1",
					memberId : hierarchyInfo[10 to 17],
					memberName : hierarchyInfo[10 to 17]
				}) if ((sizeOf(hierarchyInfo) > 10) and (sizeOf(hierarchyInfo) >= 18)),
				({
					hierarchyLevelId : "level-2",
					memberId : hierarchyInfo[5 to 9],
					memberName: hierarchyInfo[5 to 9]
				}) if ((sizeOf(hierarchyInfo) > 5) and (sizeOf(hierarchyInfo) >= 10)),
				({
					hierarchyLevelId : "level-3",
					memberId : hierarchyInfo[0 to 4],
					memberName : hierarchyInfo[0 to 4]
				}) if (sizeOf(hierarchyInfo) >= 5)
			])
		}) if (hierarchyInfo != null and hierarchyInfo != ""),
		status : [{
			statusCode : if(upper($.LVORM default "") == "X") "INACTIVE" else "ACTIVE"
		}],
		classifications : {
			itemType : $.MTART,
			itemFamilyGroup : $.MATKL,
			lineOfBusiness : $.SPART,
			handlingInstruction : [
				({
					handlingInstructionCode : "PER",
				}) if ((lower($.MTART default "")) == "frip"),
				({
					handlingInstructionCode : "TMC",
				}) if ($.TEMPB != null and $.TEMPB != ""),
				({
					handlingInstructionCode : "DAE",
					handlingInstructionText : {
						value : $.STOFF,
						languageCode : "en"
					}
				}) if ($.STOFF != null and $.STOFF != "")
			]
		},
		tradeItemMeasurements : {
			(inBoxCubeDimension : {
				value : $.VOLUM as Number,
				measurementUnitCode : if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.VOLEH default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.VOLEH] else $.VOLEH
			}) if (($.VOLUM as Number default 0) > 0),
			tradeItemWeight : {
				(grossWeight : {
					value : trim($.BRGEW default "0") as Number,
					measurementUnitCode : if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.GEWEI default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.GEWEI] else $.GEWEI
				}) if (($.BRGEW as Number default 0) > 0),
				(netWeight : {
					value : trim($.NTGEW default "0") as Number,
					measurementUnitCode : if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.GEWEI default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.GEWEI] else $.GEWEI
				}) if (($.NTGEW as Number default 0) > 0)
			}
		},
		operationalRules : {
			trackingInformation : {
				trackLotNumbers : if (upper($.XCHPF default "") =="X") true else false
			},
			(shelfLife : {
				value : $.MHDHB as Number,
				timeMeasurementUnitCode : if ($.IPRKZ == null or $.IPRKZ == "") "DAY" else if($.IPRKZ as Number == 1) "WEE" else if($.IPRKZ as Number == 2) "MON" else if($.IPRKZ as Number == 3) "ANN" else ""
			}) if ($.MHDHB != null and $.MHDHB != "")
		},
		measurementTypeConversion : [{
			sourceMeasurementUnitCode : {
				measurementUnitCode : if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINH default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEINH] else $.MEINH
			},
			targetMeasurementUnitCode : {
				measurementUnitCode : if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.MEINS] else $.MEINS
			},
			(ratioOfTargetPerSource : (trim($.UMREZ) / trim($.UMREN)) as Number) if (trim($.UMREN default 0) > 0)
		}]
	})
}