%dw 2.0
fun transportType(t: String) = if(t == '01') 30 else if(t=='02') 50 else if(t=='03') 20 else if(t=='04') 10 else if(t=='05') 40 else 30
fun timeConversion (time: String) = if(time != "" and time != null) time[0 to 1] ++ ":" ++ time[2 to 3] ++ ":" ++ time[4 to 5] else ""
fun formatDate(dateString: String) = if (dateString != "" and dateString != "00000000" and dateString != null) dateString as Date {format : "yyyyMMdd"} as Date {format : "yyyy-MM-dd"} else ""
fun isDateNull(dateString: String) = dateString == "" or dateString == "00000000" or dateString == null
fun formatInfo(formatData: String) = formatData replace /^0+/ with ""
output application/json
---
flatten(payload.*IDOC map {
   ($.*E1EDT20 map (v1,i1)-> using(sortData = v1.*E1EDK33 orderBy($.TSRFO), dateSet = v1.*E1EDT10 filter($.QUALF == "003")) {
			creationDateTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
			documentStatusCode : "ORIGINAL",
			documentActionCode : if(v1.E1EDT18.QUALF == "ORI") "ADD" else if (v1.E1EDT18.QUALF == "CHA") "CHANGE_BY_REFRESH" else "",
			transportLoadId : v1.TKNUM,
			logisticServicesSeller : {
	            primaryId : if (not isEmpty((v1.*E1ADRM4 filter ($.PARTNER_Q == "SP")).PARTNER_ID[0])) ((v1.*E1ADRM4 filter ($.PARTNER_Q == "SP")).PARTNER_ID[0] replace /^0+/ with "") else "*UNKNOWN"
        	},
        	logisticServicesBuyer : {
	            primaryId : "*UNKNOWN"
        	},
        	transportModeCode : (transportType(v1.VSART default '0')) as String,
        	transportCargoCharacteristics : {
        		cargoTypeCode : "12"
        	},
        	transportServiceCategoryType : (transportType(v1.VSART default '0')) as String,
        	carrier : {
        		primaryId : if (not isEmpty((v1.*E1ADRM4 filter ($.PARTNER_Q == "SP")).PARTNER_ID[0])) ((v1.*E1ADRM4 filter ($.PARTNER_Q == "SP")).PARTNER_ID[0] replace /^0+/ with "") else "*UNKNOWN"
        	},
			
			loadStartDateTime :  (formatDate(dateSet.NTANF[0] default "") ++ timeConversion(dateSet.NTANZ[0] default "")),
			loadEndDateTime : (formatDate(dateSet.NTEND[0] default "") ++ timeConversion(dateSet.NTENZ[0] default "")),
            (stop : (sortData map (v2,i2) -> using(dataSet = (Mule::lookup('bydm_transportLoadSubFlow', {pickData:(v2.*E1EDT01.VBELN) default []}))) {
                (v2.*E1EDT44 filter ($.QUALI == "001") map (v3,i3) -> {
                        stopSequenceNumber : (i2 as Number) + 1,
                        stopLocation : {
                            additionalLocationId : [if(v3.WERKS?) formatInfo(v3.WERKS) else if(v3.KUNNR?) formatInfo(v3.KUNNR) else if(v3.VSTEL?) formatInfo(v3.VSTEL) else if(v3.LIFNR?) formatInfo(v3.LIFNR) else if(v3.KNOTE?) formatInfo(v3.KNOTE) else if(v3.LGNUM?) formatInfo(v3.LGNUM) else ""],
                            sublocationId : vars.plantCodeMap[v3.VSTEL default ""]
                        },
                        stopLocationType : "", //We need condition to update this field
                        stopLogisticEvent : [{
                            logisticEventTypeCode : "TERMINAL_ARRIVAL",
                            logisticEventDateTime : {
                                (date : if(!isDateNull(v2.E1EDT45.ISDD default "")) formatDate(v2.E1EDT45.ISDD) else formatDate(v2.E1EDT45.NTANF)) if((v2.E1EDT45.QUALF) =="005"),
                                (time : if(timeConversion(v2.E1EDT45.ISDZ default "")!="") timeConversion(v2.E1EDT45.ISDZ) else timeConversion(v2.E1EDT45.NTANZ)) if((v2.E1EDT45.QUALF) =="005")
                                
                            }
                        },{
                            logisticEventTypeCode : "TERMINAL_DEPARTURE",
                            logisticEventDateTime : {
                                (date : if(!isDateNull(v2.E1EDT45.IEDD default "")) formatDate(v2.E1EDT45.IEDD) else formatDate(v2.E1EDT45.NTEND)) if((v2.E1EDT45.QUALF) =="005"),
                                (time : if(timeConversion(v2.E1EDT45.IEDZ default "")!="") timeConversion(v2.E1EDT45.IEDZ) else timeConversion(v2.E1EDT45.NTENZ)) if((v2.E1EDT45.QUALF) =="005")
                                
                            }
                        }],
                        (dataSet.*picksData default [] map {
                        	 pickupShipmentReference : ($ map {
                        		 primaryId : $
                        	})
                        }),
                        pickupShipmentCount : sizeOf(dataSet.picksData),
                        (dataSet.*dropsData default [] map {
                            "dropoffShipmentReference": ($ map {
                        		 primaryId : $
                        	})
                        }),
                        dropoffShipmentCount : sizeOf(dataSet.dropsData),

                })
            })
            ++
            (sortData filter ((sizeOf(sortData)-1) == $$) map (v2,i2) -> using(dataSet = (Mule::lookup('bydm_transportLoadSubFlow', {pickData:["finalSet"]})))  {
                (v2.*E1EDT44 filter ($.QUALI == "002" ) map (v3,i3) -> {
                        stopSequenceNumber : sizeOf(sortData) + 1,
                        stopLocation : {
                            additionalLocationId : [if(v3.WERKS?) formatInfo(v3.WERKS) else if(v3.KUNNR?) formatInfo(v3.KUNNR) else if(v3.VSTEL?) formatInfo(v3.VSTEL) else if(v3.LIFNR?) formatInfo(v3.LIFNR) else if(v3.KNOTE?) formatInfo(v3.KNOTE) else if(v3.LGNUM?) formatInfo(v3.LGNUM) else ""],
                        	//formatInfo
                        	sublocationId : vars.plantCodeMap[v3.VSTEL default ""]
                        },
                        stopLocationType : "",
                        stopLogisticEvent : [{
                            logisticEventTypeCode : "TERMINAL_ARRIVAL",
                            logisticEventDateTime : {
                                (date : if(!isDateNull(v2.E1EDT45.ISDD default "")) formatDate(v2.E1EDT45.ISDD) else formatDate(v2.E1EDT45.NTANF)) if((v2.E1EDT45.QUALF) =="005"),
                                (time : if(timeConversion(v2.E1EDT45.ISDZ default "")!="") timeConversion(v2.E1EDT45.ISDZ) else timeConversion(v2.E1EDT45.NTANZ)) if((v2.E1EDT45.QUALF) =="005")
                                
                            }
                        },{
                            logisticEventTypeCode : "TERMINAL_DEPARTURE",
                            logisticEventDateTime : {
                                (date : if(!isDateNull(v2.E1EDT45.IEDD default "")) formatDate(v2.E1EDT45.IEDD) else formatDate(v2.E1EDT45.NTEND)) if((v2.E1EDT45.QUALF) =="005"),
                                (time : if(timeConversion(v2.E1EDT45.IEDZ default "")!="") timeConversion(v2.E1EDT45.IEDZ) else timeConversion(v2.E1EDT45.NTENZ)) if((v2.E1EDT45.QUALF) =="005")
                                
                            }
                        }],
                        (dataSet.*picksData default [] map {
                        	 pickupShipmentReference : ($ map {
                        		 primaryId : $
                        	})
                        }),
                        pickupShipmentCount : sizeOf(dataSet.picksData),
                        (dataSet.*dropsData default [] map {
                            "dropoffShipmentReference": ($ map {
                        		 primaryId : $
                        	})
                        }),
                        dropoffShipmentCount : sizeOf(dataSet.dropsData),

                
                })
            })) if(not isEmpty(sortData)),
			shipment : (v1.*E1EDL20 map (v4,i4) -> {
        			"primaryId" : v4.VBELN,
					(v4.*E1ADRM1 filter($.PARTNER_Q == "WE") map (v5,i5)-> {
						receiver : {
							primaryId : (v5.PARTNER_ID replace /^0+/ with ""),
							//"additionalPartyId": [{
							//		"value": "0000000000000",
							//		"typeCode": "GLN"
							//	}],
						}
					}),        			
					"shipper": {
						"primaryId" : ((v4.*E1ADRM1 filter ($.PARTNER_Q == "OSP")).PARTNER_ID[0] replace /^0+/ with ""),
						(additionalPartyId : [{
        					value : v4.E1EDL24.WERKS,
        					typeCode : "FOR_INTERNAL_USE_1",
        				}]) if(not isEmpty(v4.E1EDL24))
					  },
					shipTo : {
        				primaryId : ((v4.*E1ADRM1 filter($.PARTNER_Q == "WE")).PARTNER_ID[0] replace /^0+/ with ""),
        				additionalPartyId : [{
        					//value : if (not isEmpty(vars.plantCodeMap[((v4.*E1ADRM1 filter($.PARTNER_Q == "WE")).PARTNER_ID[0] replace /^0+/ with "") default ""])) vars.plantCodeMap[((v4.*E1ADRM1 filter($.PARTNER_Q == "WE")).PARTNER_ID[0] replace /^0+/ with "") default ""] else ((v4.*E1ADRM1 filter($.PARTNER_Q == "WE")).PARTNER_ID[0] replace /^0+/ with ""),
        					value : if(isEmpty(vars.plantCodeMap[if(((v4.*E1ADRM1 filter($.PARTNER_Q == "WE")).PARTNER_ID[0] replace /^0+/ with "") == v4.E1EDL24.WERKS) v4.E1EDL24.WERKS else ""])) ((v4.*E1ADRM1 filter($.PARTNER_Q == "WE")).PARTNER_ID[0] replace /^0+/ with "") else "",
        					typeCode : "FOR_INTERNAL_USE_1",
        				}]
        			},
        			shipFrom : {
        				primaryId : v4.E1EDL24.WERKS,
        				additionalPartyId : [{
        					//value : if (not isEmpty(vars.plantCodeMap.[v4.E1EDL24.WERKS default ""])) vars.plantCodeMap[v4.E1EDL24.WERKS] else v4.E1EDL24.WERKS,
        					value : vars.plantCodeMap[v4.E1EDL24.WERKS],
        					typeCode : "FOR_INTERNAL_USE_1",
        				}]
        			},
        			logisticServiceRequirementCode : "2",
        			transportServiceCategoryType : "30", //"30" represents "Road Transport"
        			transportCargoCharacteristics : {
        				cargoTypeCode : "12", // "12" represents "General Cargo"
        			},
					"plannedDelivery": {
						"logisticEventPeriod": {
						  //date : "1900-01-01"
						  "beginDate": "1900-01-01"
						}
					  },
        			(transportReference : [{
        				entityId : v4.BOLNR default "",
        				typeCode : "BM"
        			}])if(not isEmpty(v4.BOLNR)),
        			(shipmentItem : (v4.*E1EDL24 map {
        				lineItemNumber : ($.POSNR default 0) as Number,
        				transactionalTradeItem : [{
        					"primaryId": $.MATNR,
							//"additionalTradeItemId": [{
							//	"value": "00000000000000",
							//	"typeCode": "GTIN"
							//}],
							"tradeItemQuantity": {
								"value": $.LGMNG as Number, //$.LFIMG as Number,
								"measurementUnitCode": if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.VRKME default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.VRKME] else $.VRKME
							},
        				}],
        				transportCargoCharacteristics : {
							cargoTypeCode : "12",
        					("totalGrossVolume": {
								"value": ($.VOLUM default 0) as Number,
								"measurementUnitCode": if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.VOLEH default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.VOLEH] else $.VOLEH
							})if(($.VOLUM as Number) > 0),
							("totalGrossWeight": {
								"value": ($.BRGEW default 0) as Number,
								"measurementUnitCode": if (not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[$.GEWEI default ""])) vars.uomCodeMap.measurementUnitCodeMap[$.GEWEI] else $.GEWEI
							})if(($.BRGEW as Number) > 0),
							cargoTypeCode : "12"
        				},
        				transportReference : [{
							"entityId": v4.VBELN,
							"lineItemNumber": $.POSNR as Number,
							"typeCode": "ON"
						}],
        			})) if(not isEmpty(v4.E1EDL24))
					
        	})

    })
})