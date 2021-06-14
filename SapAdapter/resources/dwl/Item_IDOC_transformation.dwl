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
(payload.*IDOC default [] map using (hierarchyInfo = $.E1MARAM.PRDHA, e1marmmArray = $.E1MARAM.*E1MARMM) {
			creationDateTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
			documentStatusCode : "ORIGINAL",
			documentActionCode : if (upper($.E1MARAM.LVORM default "") == "X") "DELETE" else if ($.E1MARAM.MSGFN == "009") "ADD" else "CHANGE_BY_REFRESH",
			senderDocumentId : $.EDI_DC40.DOCNUM,
			itemId : {
				primaryId : if (not isEmpty ($.E1MARAM.MATNR_LONG)) $.E1MARAM.MATNR_LONG else $.E1MARAM.MATNR,
				itemName : (if ((($.E1MARAM.*E1MAKTM filter ($.SPRAS_ISO == "EN")).MAKTX) != null) (($.E1MARAM.*E1MAKTM filter ($.SPRAS_ISO == "EN")).MAKTX)[0] else ($.E1MARAM.*E1MAKTM.MAKTX)[0])
			},
			description : (($.E1MARAM.*E1MAKTM) filter (upper($.SPRAS_ISO default "") == "EN") map {
					value : $.MAKTX,
					languageCode: if (not isEmpty ($.SPRAS_ISO)) lower($.SPRAS_ISO) else "en",
					descriptionType : "ITEM_NAME"					
			}),
			specificLocations : {
					location : (payload.*IDOC.E1MARAM.*E1MARCM distinctBy($.WERKS) map {
				
						primaryId : $.WERKS
				})
			},
			countryOfOrigin : [ $.E1MARAM.E1MARA1.HERKL ],
			tradeItemBaseUnitOfMeasure : if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.E1MARAM.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.E1MARAM.MEINS] else $.E1MARAM.MEINS,
			(itemHierarchyInformation : {
				ancestry : [{
					hierarchyLevelId : "3",
					memberId : hierarchyInfo
				}]
			}) if (not isEmpty(hierarchyInfo)),
			itemLogisticUnitInformation : [{
					actionCode : if ($.E1MARAM.MSGFN == "009") "ADD" else "CHANGE",
					//isDefaultLogisticUnitConfiguration : if ($.E1MARAM.MEINS == e1marmmValue.MEINH) true else false,
					itemLogisticUnit : 
					(e1marmmArray map (e1marmmValue, e1marmmIndex) -> {
						logisticUnitName : if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[e1marmmValue.MEINH default ""])) vars.uomCodeMap.measurementUnitCodeMap[e1marmmValue.MEINH] else e1marmmValue.MEINH,
						actionCode : if (e1marmmValue.MSGFN == "009") "ADD" else "CHANGE",
						(tradeItemQuantity : {
							value : (((trim(e1marmmValue.UMREZ default "0") as Number) / trim(e1marmmValue.UMREN)) as Number),
							measurementUnitCode: if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.E1MARAM.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.E1MARAM.MEINS] else $.E1MARAM.MEINS
						}) if (((((trim(e1marmmValue.UMREZ default "0") as Number) / trim(e1marmmValue.UMREN)) as Number) > 0) and (trim((e1marmmValue.UMREN default "0") as Number) > 0)),
						tradeItemQuantityPerLayer: {
							value: 1
						},
						packageLevelNumber : (e1marmmIndex + 1),
						(grossWeight : {
							value : if ((trim(e1marmmValue.BRGEW default "0") as Number) > 0) (trim(e1marmmValue.BRGEW default "0") as Number) else ((trim($.E1MARAM.BRGEW default "0") as Number) * (((trim(e1marmmValue.UMREZ default "0") as Number) / trim(e1marmmValue.UMREN)) as Number)),
							measurementUnitCode : if (not (isEmpty(e1marmmValue.GEWEI))) (if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[e1marmmValue.GEWEI default ""])) vars.uomCodeMap.measurementUnitCodeMap[e1marmmValue.GEWEI] else e1marmmValue.GEWEI) else (if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.E1MARAM.GEWEI default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.E1MARAM.GEWEI] else $.E1MARAM.GEWEI)
						}) if (((trim(e1marmmValue.BRGEW default "0") as Number) > 0) or ((((trim($.E1MARAM.BRGEW default "0") as Number) * (((trim(e1marmmValue.UMREZ default "0") as Number) / trim(e1marmmValue.UMREN)) as Number)) > 0) and (trim((e1marmmValue.UMREN default "0") as Number) > 0))),
						(netWeight : {
							value : ((trim($.E1MARAM.NTGEW default "0") as Number) * (((trim(e1marmmValue.UMREZ default "0") as Number) / trim(e1marmmValue.UMREN)) as Number)),
							measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.E1MARAM.GEWEI default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.E1MARAM.GEWEI] else $.E1MARAM.GEWEI
						}) if ((($.E1MARAM.NTGEW as Number default 0) > 0) and (trim((e1marmmValue.UMREN default "0") as Number) > 0)),
						dimensionsOfLogisticUnit : {
							(depth : {
								value : e1marmmValue.LAENG as Number,
								measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[e1marmmValue.MEABM default ""])) vars.uomCodeMap.measurementUnitCodeMap[e1marmmValue.MEABM] else e1marmmValue.MEABM
							}) if (not (isEmpty(e1marmmValue.LAENG))),
							(height : {
								value : e1marmmValue.HOEHE as Number,
								measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[e1marmmValue.MEABM default ""])) vars.uomCodeMap.measurementUnitCodeMap[e1marmmValue.MEABM] else e1marmmValue.MEABM
							}) if (not (isEmpty(e1marmmValue.HOEHE))),
							(width : {
								value : e1marmmValue.BREIT as Number,
								measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[e1marmmValue.MEABM default ""])) vars.uomCodeMap.measurementUnitCodeMap[e1marmmValue.MEABM] else e1marmmValue.MEABM
							}) if (not (isEmpty(e1marmmValue.BREIT))),
						},
						(grossVolume : {
							value : if ((trim(e1marmmValue.VOLUM default "0") as Number) > 0) (trim(e1marmmValue.VOLUM default "0") as Number) else ((trim($.E1MARAM.VOLUM default "0") as Number) * (((trim(e1marmmValue.UMREZ default "0") as Number) / trim(e1marmmValue.UMREN)) as Number)),
							measurementUnitCode : if (not (isEmpty(e1marmmValue.VOLEH))) (if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[e1marmmValue.VOLEH default ""])) vars.uomCodeMap.measurementUnitCodeMap[e1marmmValue.VOLEH] else e1marmmValue.VOLEH) else (if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.E1MARAM.VOLEH default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.E1MARAM.VOLEH] else $.E1MARAM.VOLEH)
						}) if (((trim(e1marmmValue.VOLUM default "0") as Number) > 0) or ((((trim($.E1MARAM.VOLUM default "0") as Number) * (((trim(e1marmmValue.UMREZ default "0") as Number) / trim(e1marmmValue.UMREN)) as Number)) > 0) and (trim((e1marmmValue.UMREN default "0") as Number) > 0))),
						isCaseEquivalent : if ((e1marmmValue.MEINH == "CS") or (e1marmmValue.MEINH == "CSE")) true else false,
						isPackEquivalent : if (e1marmmValue.MEINH == "PK") true else false,
						isPalletEquivalent : if (e1marmmValue.MEINH == "PF") true else false
					})
				}],
			status : [{
				statusCode : if(($.E1MARAM.LVORM default "") == "X") "INACTIVE" else "ACTIVE"
			}],
			classifications : {
				itemType : $.E1MARAM.MTART,
				itemFamilyGroup : $.E1MARAM.MATKL default "",
				lineOfBusiness : $.E1MARAM.SPART,
				handlingInstruction : [
					({
						handlingInstructionCode : "PER",
					}) if ((lower($.E1MARAM.MTART default ""))=="frip"),
					({
						handlingInstructionCode : "TMC",
					}) if (not isEmpty($.E1MARAM.TEMPB)),
					({
						handlingInstructionCode : "DAE",
						handlingInstructionText : {
							value : $.E1MARAM.STOFF,
							languageCode : "en"
						}
					}) if (not isEmpty($.E1MARAM.STOFF))
				]
			},
			tradeItemMeasurements : {
				(inBoxCubeDimension :{
					value : $.E1MARAM.VOLUM as Number,
					measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.E1MARAM.VOLEH default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.E1MARAM.VOLEH] else $.E1MARAM.VOLEH
				}) if (($.E1MARAM.VOLUM as Number default 0) > 0),
				tradeItemWeight : {
					(grossWeight : {
						value : trim($.E1MARAM.BRGEW default "0") as Number,
						measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.E1MARAM.GEWEI default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.E1MARAM.GEWEI] else $.E1MARAM.GEWEI
					}) if (($.E1MARAM.BRGEW as Number default 0) > 0),
					(netWeight : {
						value : trim($.E1MARAM.NTGEW default "0") as Number,
						measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.E1MARAM.GEWEI default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.E1MARAM.GEWEI] else $.E1MARAM.GEWEI
					}) if (($.E1MARAM.NTGEW as Number default 0) > 0)
				}
			},
			operationalRules : {
				trackingInformation : {
					trackLotNumbers : if(upper($.E1MARAM.XCHPF default "o") == "X") true else false
				},
				receiveInventoryStatus : "AVAILABLE_FOR_SALE",
				(shelfLife : {
					value : $.E1MARAM.MHDHB as Number,
					timeMeasurementUnitCode : if (isEmpty($.E1MARAM.IPRKZ)) "DAY" else if($.E1MARAM.IPRKZ as Number == 1) "WEE" else if($.E1MARAM.IPRKZ as Number == 2) "MON" else if($.E1MARAM.IPRKZ as Number == 3) "ANN" else "DAY"
				})  if ($.E1MARAM.MHDHB != null and $.E1MARAM.MHDHB != "" and $.E1MARAM.MHDHB != "0")
			},
			measurementTypeConversion : 
				(e1marmmArray map (k,v) -> {
					sourceMeasurementUnitCode : {
						measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[k.MEINH default ""])) vars.uomCodeMap.measurementUnitCodeMap[k.MEINH] else k.MEINH
					},
					targetMeasurementUnitCode : {
						measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.E1MARAM.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.E1MARAM.MEINS] else $.E1MARAM.MEINS
					},
					(ratioOfTargetPerSource : (((trim(k.UMREZ default "0") as Number) / (trim(k.UMREN) as Number)) as String {format : "#.###############"}) as Number) if ((trim(k.UMREN default "0") as Number) > 0)
				})
		})