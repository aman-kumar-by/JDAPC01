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
import lookup_utils::globalDataweaveFunctions
---
{
		header : {
		sender : "SAP." ++ ((read(payload[0],'application/xml').IDOC.EDI_DC40.SNDPRN) default ""),
		receiver : (p("sap.receiver.bom.idoc") splitBy ","),
		model : "BYDM",
		messageVersion : "BYDM 2021.2.0",
		messageId : uuid(),
		'type' : "billOfMaterial",
		creationDateAndTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"}
		//testMessage : false
		},
		billOfMaterial : (vars.payloadAsXml.root.pay.*IDOC map {
				creationDateTime : now() as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
				documentStatusCode : "ORIGINAL",
				documentActionCode : "CHANGE_BY_REFRESH",
				senderDocumentId : $.EDI_DC40.DOCNUM,
				billOfMaterialId : $.E1STZUM.STLNR,
				($.E1STZUM.*E1MASTM map (e1mastm, index) ->{
					item : {
						primaryId : e1mastm.MATNR
					},
					location : {
						primaryId : e1mastm.WERKS
					},
					(billOfMaterialNumber : (e1mastm.STLAL) as Number) if(e1mastm.STLAL != null and not isEmpty(e1mastm.STLAL)),
				}),
				billOfMaterialTypeCode: $.E1STZUM.STLAN,
				component:
				flatten([($..*E1STPOM filter ((e1stpom, idx) -> (e1stpom.ALPOS == "X" and ((e1stpom.MENGE_C endsWith "-") == false) and ((e1stpom.MENGE_C startsWith "-") == false))) orderBy ((e1stpom) -> e1stpom.ALPRF replace "00" with "n") groupBy ((e1stpom) -> e1stpom.ALPGR) mapObject (payload1, index) -> {
					root: {
						componentItem: {
							primaryId : payload1.IDNRK[0] 
						},
						componentLocation: {
							primaryId : $.E1STZUM.E1MASTM.WERKS
						},
						effectiveFromDate : globalDataweaveFunctions::formatDate(payload1.DATUV[0] default ""),
						effectiveUpToDate : globalDataweaveFunctions::formatDate(p('default.date.discontinueDate') default ""),
						(
							offset : {
								value : (if(payload1.NLFZT[0] contains "-") 
											("-" ++ (payload1.NLFZT[0][0 to ((sizeOf(payload1.NLFZT[0])) - 2)]) as Number)
										else
											payload1.NLFZT[0] as Number),
								timeMeasurementUnitCode : "DAY"
							}
						) if(payload1.NLFZT[0] != null and not isEmpty(payload1.NLFZT[0])),
						(
							drawQuantity : {
							value : trim(payload1.MENGE_C[0]) as Number,
							measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[payload1.MEINS[0] default ""])) vars.uomCodeMap.measurementUnitCodeMap[payload1.MEINS[0]] else payload1.MEINS[0]
							}
						) if(payload1.MENGE_C[0] != null and not isEmpty(payload1.MENGE_C[0])),
						yieldFactor : 100 - (payload1.AUSCH[0] as Number default 0),
						substituteComponent : (payload1 map (altComp,subCount) -> {
							(if (subCount != 0) ({
								(
									substituteItem : {
										primaryId : altComp.IDNRK
									}
								)if(altComp.IDNRK != null and not isEmpty(altComp.IDNRK)),
								(
									substituteLocation : {
										primaryId : $.E1STZUM.E1MASTM.WERKS
									}
								) if($.E1STZUM.E1MASTM.WERKS != null and not isEmpty($.E1STZUM.E1MASTM.WERKS)),
								effectiveFromDate : globalDataweaveFunctions::formatDate(altComp.DATUV default ""), //e1stpom.datuv
								effectiveUpToDate : globalDataweaveFunctions::formatDate(p('default.date.discontinueDate') default ""),
								(
									drawQuantity :{
										value : trim(altComp.MENGE_C) as Number,
										measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[altComp.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[altComp.MEINS] else altComp.MEINS 
									}
								) if(altComp.MENGE_C != null and not isEmpty(altComp.MENGE_C)),
								yieldFactor : 100 - (altComp.AUSCH as Number default 0)
							}) else {
							} )
						})
					}
				}).*root,
				($.E1STZUM.*E1STPOM filter ((e1stpom, idx) -> (e1stpom.ALPOS != "X" and ((e1stpom.MENGE_C endsWith "-") == false) and ((e1stpom.MENGE_C startsWith "-") == false))) map (e1stpom, index) -> using (offsetsize = sizeOf(e1stpom.NLFZT))  {
						componentItem: {
							primaryId : e1stpom.IDNRK 
						},
						componentLocation: {
							primaryId : $.E1STZUM.E1MASTM.WERKS
						},
						effectiveFromDate : globalDataweaveFunctions::formatDate($.E1STZUM.E1STKOM.DATUV default ""),
						effectiveUpToDate : globalDataweaveFunctions::formatDate(p('default.date.discontinueDate') default ""),
						((offset : {
							value : (if(e1stpom.NLFZT contains "-")
										("-" ++ (e1stpom.NLFZT[0 to ((sizeOf(e1stpom.NLFZT)) - 2)])) as Number
									else
										e1stpom.NLFZT) as Number,
							timeMeasurementUnitCode : "DAY"
							}
						)
						if(e1stpom.NLFZT != null and not isEmpty(e1stpom.NLFZT))),
						(
							drawQuantity : {
								value : trim(e1stpom.MENGE_C) as Number,
								measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[e1stpom.MEINS default ""])) vars.uomCodeMap.measurementUnitCodeMap[e1stpom.MEINS] else e1stpom.MEINS
							}
						)if(e1stpom.MENGE_C != null and not isEmpty(e1stpom.MENGE_C)),
						yieldFactor : 100 - (e1stpom.AUSCH as Number default 0),
				})
			])
		})
}
