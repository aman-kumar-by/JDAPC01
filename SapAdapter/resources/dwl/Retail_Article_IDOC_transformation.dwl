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
(payload.*IDOC default [] map using (hierarchyInfo = $.E1BPE1MARART.PROD_HIER) {
			creationDateTime : now() as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
			documentStatusCode : "ORIGINAL",
			documentActionCode : if (upper($.E1BPE1MARART.DEL_FLAG default "") == "X") "DELETE" else if ($.E1BPE1MATHEAD.FUNCTION == "009") "ADD" else "CHANGE_BY_REFRESH",
			senderDocumentId : $.EDI_DC40.DOCNUM,
			itemId : {
				primaryId : $.E1BPE1MATHEAD.MATERIAL,
				itemName : $.E1BPE1MATHEAD.MATERIAL
			},
			description : [{
				value : $.E1BPE1MAKTRT.MATL_DESC,
				languageCode : lower($.E1BPE1MAKTRT.LANGU_ISO default "en")
			}],
			countryOfOrigin : [ $.E1BPE1MAKTRT.E1BPE1MARART1.COUNTRYORI ],
			tradeItemBaseUnitOfMeasure : if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.E1BPE1MARARTX.BASE_UOM default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.E1BPE1MARARTX.BASE_UOM] else $.E1BPE1MARARTX.BASE_UOM,
			(itemHierarchyInformation : {
				ancestry : [
					({
						hierarchyLevelId : "level-1",
						memberId : hierarchyInfo[10 to 17]
					}) if ((sizeOf(hierarchyInfo) > 10) and (sizeOf(hierarchyInfo) >= 18)),
					({
						hierarchyLevelId : "level-2",
						memberId : hierarchyInfo[5 to 9]
					}) if ((sizeOf(hierarchyInfo) > 5) and (sizeOf(hierarchyInfo) >= 10)),
					({
						hierarchyLevelId : "level-3",
						memberId : hierarchyInfo[0 to 4]
					}) if (sizeOf(hierarchyInfo) >= 5)
				]
			}) if (hierarchyInfo != null and hierarchyInfo != ""),
			itemLogisticUnitInformation : [{
				actionCode : if($.E1BPE1MARMRT.FUNCTION == '009') "ADD" else "CHANGE",
				itemLogisticUnit : 
				($.*E1BPE1MARMRT map (e1bpe1marmrt, Index) -> {
					logisticUnitName : if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[e1bpe1marmrt.ALT_UNIT_ISO default ""])) vars.uomCodeMap.measurementUnitCodeMap[e1bpe1marmrt.ALT_UNIT_ISO] else e1bpe1marmrt.ALT_UNIT_ISO,
					actionCode : if(e1bpe1marmrt.FUNCTION == '009') "ADD" else "CHANGE",
					tradeItemQuantity : {
						(value : ((e1bpe1marmrt.NUMERATOR/e1bpe1marmrt.DENOMINATR default "0") as Number)) if (trim(e1bpe1marmrt.DENOMINATR default 0) > 0),
						measurementUnitCode : if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.E1BPE1MARART.BASE_UOM default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.E1BPE1MARART.BASE_UOM] else $.E1BPE1MARART.BASE_UOM
					},
					tradeItemQuantityPerLayer : {
						value : 1,
					},
					packageLevelNumber : Index,
					(grossWeight : {
						value : trim(e1bpe1marmrt.GROSS_WT default "0") as Number,
						measurementUnitCode : if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.E1BPE1MARMRTX.UNIT_OF_WT default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.E1BPE1MARMRTX.UNIT_OF_WT] else $.E1BPE1MARMRTX.UNIT_OF_WT
					}) if ((e1bpe1marmrt.GROSS_WT as Number default 0) > 0),
					(netWeight : {
						value : trim($.E1BPE1MARART.NET_WEIGHT default "0") as Number,
						measurementUnitCode : if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.E1BPE1MARMRTX.UNIT_OF_WT default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.E1BPE1MARMRTX.UNIT_OF_WT] else $.E1BPE1MARMRTX.UNIT_OF_WT
					}) if (($.E1BPE1MARART.NET_WEIGHT as Number default 0) > 0),
					dimensionsOfLogisticUnit : {
						depth : {
							value : trim(e1bpe1marmrt.LENGTH default "0") as Number,
							measurementUnitCode : if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[e1bpe1marmrt.UNIT_DIM_ISO default ""])) vars.uomCodeMap.measurementUnitCodeMap[e1bpe1marmrt.UNIT_DIM_ISO] else e1bpe1marmrt.UNIT_DIM_ISO
						},
						height : {
							value : trim(e1bpe1marmrt.LENGTH default "0") as Number,
							measurementUnitCode : if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[e1bpe1marmrt.UNIT_DIM_ISO default ""])) vars.uomCodeMap.measurementUnitCodeMap[e1bpe1marmrt.UNIT_DIM_ISO] else e1bpe1marmrt.UNIT_DIM_ISO
						},
						width : {
							value : trim(e1bpe1marmrt.WIDTH default "0") as Number,
							measurementUnitCode : if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[e1bpe1marmrt.UNIT_DIM_ISO default ""])) vars.uomCodeMap.measurementUnitCodeMap[e1bpe1marmrt.UNIT_DIM_ISO] else e1bpe1marmrt.UNIT_DIM_ISO
						}
					},
					(grossVolume : {
						value : trim(e1bpe1marmrt.VOLUME default "") as Number,
						measurementUnitCode : if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[e1bpe1marmrt.VOLUMEUNIT_ISO default ""])) vars.uomCodeMap.measurementUnitCodeMap[e1bpe1marmrt.VOLUMEUNIT_ISO] else e1bpe1marmrt.VOLUMEUNIT_ISO
					}) if ((e1bpe1marmrt.VOLUME as Number default 0) > 0),
					isCaseEquivalent : if(e1bpe1marmrt.ALT_UNIT_ISO == "CS" or e1bpe1marmrt.ALT_UNIT_ISO == "CSE") true else false,
					isPackEquivalent : if(e1bpe1marmrt.ALT_UNIT_ISO == "PK") true else false,
					isPalletEquivalent : if(e1bpe1marmrt.ALT_UNIT_ISO == "PF") true else false
				})
			}],
			status : [{
				statusCode : if (upper($.E1BPE1MARART.DEL_FLAG default "") == "X") "INACTIVE" else "ACTIVE"
			}],
			classifications : {
				itemType : $.E1BPE1MATHEAD.MATL_TYPE,
				itemFamilyGroup : $.E1BPE1MATHEAD.MATL_GROUP,
				lineOfBusiness : $.E1BPE1MARART.DIVISION,
				handlingInstruction : [
					({
						handlingInstructionCode : "PER",
					}) if ((lower($.E1BPE1MATHEAD.MATL_TYPE default "")) == "frip"),
					({
						handlingInstructionCode : "TMC",
					}) if ($.E1BPE1MARART.TEMP_CONDS != null and $.E1BPE1MARART.TEMP_CONDS != ""),
					({
						handlingInstructionCode : "DAE",
						handlingInstructionText : {
							value : $.E1BPE1MARART.HAZ_MAT_NO,
							languageCode : "en"
						}
					}) if ($.E1BPE1MARART.HAZ_MAT_NO != null and $.E1BPE1MARART.HAZ_MAT_NO != "")
				]
			},
			tradeItemMeasurements : {
				tradeItemWeight : {
					(grossWeight : {
						value : trim($.E1BPE1MARMRTX.GROSS_WT default "0") as Number,
						measurementUnitCode : if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.E1BPE1MARMRTX.UNIT_OF_WT default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.E1BPE1MARMRTX.UNIT_OF_WT] else $.E1BPE1MARMRTX.UNIT_OF_WT
					}) if (($.E1BPE1MARMRTX.GROSS_WT as Number default 0) > 0),
					(netWeight : {
						value : trim($.E1BPE1MARART.NET_WEIGHT default "") as Number,
						measurementUnitCode : if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.E1BPE1MARMRT.UNIT_OF_WT default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.E1BPE1MARMRT.UNIT_OF_WT] else $.E1BPE1MARMRT.UNIT_OF_WT
					}) if (($.E1BPE1MARART.NET_WEIGHT as Number default 0) > 0)
				}
			},
			operationalRules : {
				trackingInformation : {
					trackLotNumbers : if (upper($.E1BPE1MARART.BATCH_MGMT default "") == "X") true else false
				},
				receiveInventoryStatus : "AVAILABLE_FOR_SALE"
			},
			measurementTypeConversion : ($.*E1BPE1MARMRT map (e1bpe1marmrt, Index) ->
				{
					sourceMeasurementUnitCode : {
						measurementUnitCode : if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.E1BPE1MARART.BASE_UOM default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.E1BPE1MARART.BASE_UOM] else $.E1BPE1MARART.BASE_UOM
					},
					targetMeasurementUnitCode : {
						measurementUnitCode : if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.E1BPE1MARART.BASE_UOM default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.E1BPE1MARART.BASE_UOM] else $.E1BPE1MARART.BASE_UOM
					},
				(ratioOfTargetPerSource : ((e1bpe1marmrt.NUMERATOR/e1bpe1marmrt.DENOMINATR default "0") as Number)) if (trim(e1bpe1marmrt.DENOMINATR default 0) > 0)
				})
})