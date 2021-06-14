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
output application/json encoding="UTF-8",skipNullOn="everywhere"

var uomCsv = vars.entityMap..uomCsv[0]

var dimidMap = {
	"MASS": "WEIGHT",
	"VOLUME": "VOLUME",
	"LENGTH" : "LENGTH",
	"AAAADL" : "PACKAGES",
	"TIME" : "TIME"
}
fun calValue(ZAEHL, NENNR, EXP10, ADDKO)= (((ZAEHL / NENNR) * (if ((EXP10<0)) (1/ (10 pow abs(EXP10))) else (10 pow EXP10))) + ADDKO)
---
{
	 	header : {
		sender :  p('sap.sender'),
		receiver : (p("sap.receiver.uom") splitBy ","),
		model : "BYDM",
		messageVersion : "BYDM 2021.2.0",
		messageId : uuid(),
		'type' : "measurement",
		creationDateAndTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"}
		//testMessage : false
		},
		measurement : using (varMeasurement = (payload groupBy ($.DIMID) pluck {
			(measurements: {
				creationDateTime : now() as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
				documentStatusCode: "ORIGINAL",
				documentActionCode: "CHANGE_BY_REFRESH",
			//added avpList Auto-Customization	
			  avpList: using( varAvpList = ($ map {
                   ($ mapObject (val, key) -> {
                       avpL:{
							(name: (key) as String) if((not isEmpty(uomCsv[(key) as String])) and (not isEmpty((val)))),
							(value :(val))if((not isEmpty(uomCsv[(key) as String])) and (not isEmpty((val))))
                       }
                   })
                })) varAvpList.*avpL,
				
				measurementTypeCategory : dimidMap[$[0].DIMID],
				measurementTypeDescription: {
						value: if (not isEmpty($[0].TXDIM)) $[0].TXDIM else dimidMap[$[0].DIMID],
						languageCode: if (not isEmpty($[0].SPRASDIM)) $[0].SPRASDIM else "en"
						//descriptionType: "_descriptionType_"
				},
				(measurementUnitCodeInformation: $ map (v,k) ->  {
					actionCode: "CHANGE",
					measurementUnitCode: {
						(measurementUnitCode: if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[v.ISOCODE default ""])) vars.uomCodeMap.measurementUnitCodeMap[v.ISOCODE] else v.ISOCODE) if (v.DIMID == "MASS" or v.DIMID == "VOLUME" or v.DIMID == "AAAADL" or v.DIMID == "LENGTH"),
						(timeMeasurementUnitCode: if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[v.ISOCODE default ""])) vars.uomCodeMap.measurementUnitCodeMap[v.ISOCODE] else v.ISOCODE) if (v.DIMID == "TIME"),
					},
					( isBaseMeasurementUnitCode: true ) if v.SIUOM == "X",
					measurementUnitCodeDescription: [ {
									value: if(not isEmpty(v.MSEHT)) v.MSEHT else (if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[v.ISOCODE default ""])) vars.uomCodeMap.measurementUnitCodeMap[v.ISOCODE] else v.ISOCODE),
									languageCode: lower(v.SPRASUOM default "en"),
									descriptionType: "SINGULAR_LABEL"
								}, 
								{
									value: if(not isEmpty(v.MSEHT)) v.MSEHT else if(not isEmpty(v.MSEHL)) v.MSEHL else (if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[v.ISOCODE default ""])) vars.uomCodeMap.measurementUnitCodeMap[v.ISOCODE] else v.ISOCODE),
									languageCode: lower(v.SPRASUOM default "en"),
									descriptionType: "SHORT_TEXT"
								}
									], 
					basesPerUnit: if(calValue(v.ZAEHL, v.NENNR, v.EXP10, v.ADDKO) == 1.0E-9 ) 0.0000000010 else  calValue(v.ZAEHL, v.NENNR, v.EXP10, v.ADDKO) as String {format:"#.############################"} as Number,
					unitsPerBase: (1 / calValue(v.ZAEHL, v.NENNR, v.EXP10, v.ADDKO)) as String {format:"#.############################"} as Number,
				})
			}) if ($[0].DIMID == "MASS" or $[0].DIMID == "VOLUME" or $[0].DIMID == "AAAADL" or $[0].DIMID == "LENGTH" or $[0].DIMID == "TIME")
		})
		
	)varMeasurement.*measurements
}
