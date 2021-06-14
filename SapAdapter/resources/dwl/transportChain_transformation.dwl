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
((payload.*IDOC map {
			creationDateTime : now() as DateTime {format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"}, // "SOM",
			documentStatusCode : "ORIGINAL",
			documentActionCode : "CHANGE_BY_REFRESH", // SOM
			lastUpdateDateTime : (globalDataweaveFunctions::formatDate($.EDI_DC40.CREDAT default "")) ++ "T" ++ globalDataweaveFunctions::timeConversion($.EDI_DC40.CRETIM default "") ++ ".000+00:00",
			senderDocumentId : $.EDI_DC40.DOCNUM,
			transportChainId : $.E1EDT20.TKNUM,
			parties : {
				freightForwarder : {
					primaryId : (($.E1EDT20.*E1ADRM4 filter ($.PARTNER_Q == "SP")).PARTNER_ID)[0]
				}
			},
			transportChainCharacteristics : {
				shipmentType : if (($.E1EDT20.E1EDL20.E1EDL24.*E1EDL43.*QUALF default "") contains "H") "inboundShipment" else "outboundShipment",
				processType : if (($.E1EDT20.E1EDL20.E1EDL24.*E1EDL43.*QUALF default "") contains "H") "supply" else "demand"
			},
			transportChainShipment : $.E1EDT20.*E1EDL20 map (transportChain, index) -> {
				shipmentId : {
					primaryId : transportChain.VBELN
				},
				shipmentParties : {
					supplier : {
						primaryId : ((transportChain.*E1ADRM1 filter ($.PARTNER_Q == "OSO")).PARTNER_ID)[0],
						name : ((transportChain.*E1ADRM1 filter ($.PARTNER_Q == "OSO")).NAME1)[0]
					},
					buyer : {
						primaryId : ((transportChain.*E1ADRM1 filter ($.PARTNER_Q == "AG")).PARTNER_ID)[0],
						name : ((transportChain.*E1ADRM1 filter ($.PARTNER_Q == "AG")).NAME1)[0]
					}
				},
				shipmentLocations : {
					shipFrom : {
						primaryId : if ((transportChain.E1EDL24.*E1EDL43.*QUALF default "") contains "H") ((transportChain.*E1ADRM1 filter ($.PARTNER_Q == "WE")).PARTNER_ID)[0] else ((transportChain.*E1ADRM1 filter ($.PARTNER_Q == "OSP")).PARTNER_ID)[0],
						name : if ((transportChain.E1EDL24.*E1EDL43.*QUALF default "") contains "H") ((transportChain.*E1ADRM1 filter ($.PARTNER_Q == "WE")).NAME1)[0] else ((transportChain.*E1ADRM1 filter ($.PARTNER_Q == "OSP")).NAME1)[0]
					},
					shipTo : {
						primaryId : if ((transportChain.E1EDL24.*E1EDL43.*QUALF default "") contains "H") ((transportChain.*E1ADRM1 filter ($.PARTNER_Q == "OSP")).PARTNER_ID)[0] else ((transportChain.*E1ADRM1 filter ($.PARTNER_Q == "WE")).PARTNER_ID)[0],
						name : if ((transportChain.E1EDL24.*E1EDL43.*QUALF default "") contains "H") ((transportChain.*E1ADRM1 filter ($.PARTNER_Q == "OSP")).NAME1)[0] else ((transportChain.*E1ADRM1 filter ($.PARTNER_Q == "WE")).NAME1)[0]
					}
				},
				shipmentDates : {
					actualDepartureDateTime : if ((((transportChain.*E1EDT13 filter ($.QUALF == "006")).ISDD)[0] default "") != "" and (((transportChain.*E1EDT13 filter ($.QUALF == "006")).ISDD)[0] default "") != null and (((transportChain.*E1EDT13 filter ($.QUALF == "006")).ISDD)[0] default "") != "00000000") (globalDataweaveFunctions::formatDate(((transportChain.*E1EDT13 filter ($.QUALF == "006")).ISDD)[0] default "")) ++ "T" ++ globalDataweaveFunctions::timeConversion(((transportChain.*E1EDT13 filter ($.QUALF == "006")).ISDZ)[0] default "") ++ ".000+00:00" else "",
					estimatedDeliveryDateTime : if ((((transportChain.*E1EDT13 filter ($.QUALF == "007")).NTEND)[0] default "") != "" and (((transportChain.*E1EDT13 filter ($.QUALF == "007")).NTEND)[0] default "") != null and (((transportChain.*E1EDT13 filter ($.QUALF == "007")).NTEND)[0] default "") != "00000000") (globalDataweaveFunctions::formatDate(((transportChain.*E1EDT13 filter ($.QUALF == "007")).NTEND)[0] default "")) ++ "T" ++ globalDataweaveFunctions::timeConversion(((transportChain.*E1EDT13 filter ($.QUALF == "007")).NTENZ)[0] default "") ++ ".000+00:00" else "",
					actualDeliveryDateTime : if ((((transportChain.*E1EDT13 filter ($.QUALF == "007")).ISDD)[0] default "") != "" and (((transportChain.*E1EDT13 filter ($.QUALF == "007")).ISDD)[0] default "") != null and (((transportChain.*E1EDT13 filter ($.QUALF == "007")).ISDD)[0] default "") != "00000000") (globalDataweaveFunctions::formatDate(((transportChain.*E1EDT13 filter ($.QUALF == "007")).ISDD)[0] default "")) ++ "T" ++ globalDataweaveFunctions::timeConversion(((transportChain.*E1EDT13 filter ($.QUALF == "007")).ISDZ)[0] default "") ++ ".000+00:00" else "",
				},
				(if (transportChain.BTGEW != null) shipmentCharacteristics : {
					totalGrossWeight : {
					value : transportChain.BTGEW as Number,
					measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[transportChain.GEWEI default ""])) vars.uomCodeMap.measurementUnitCodeMap[transportChain.GEWEI] else transportChain.GEWEI
				}} else {}),
				(if (transportChain.BOLNR != null and transportChain.BOLNR != "") tmReferenceNumber : [{
					referenceNumberName : "BILL_OF_LADING",
					referenceNumberValue : transportChain.BOLNR
				}] else {}),
				movementReference : (payload.IDOC.E1EDT20.*E1EDK33 map (mref, mindex) -> {
						(mref.*E1EDT01 filter ($.*VBELN default "" contains transportChain.VBELN default "") map(checkMatch,checkIndex) -> {
							sequenceNumber : mref.TSRFO as Number,
							movementId : mref.TSNUM,
							loadId : payload.IDOC.E1EDT20.TKNUM,
							freightTerms : transportChain.INCO1
						})
					})
			},
			transportMovement : (payload.IDOC.E1EDT20.*E1EDK33 map(tmov, tmovindex) -> {
				movementId : tmov.TSNUM,
				legIndicator : if (tmov.LAUFK == "1") "PRELIMINARY" else if (tmov.LAUFK == "2") "MAIN" else if (tmov.LAUFK == "3") "SUBSEQUENT" else if (tmov.LAUFK == "4") "DIRECT" else if (tmov.LAUFK == "5") "RETURN" else "",
				movementLocations : {
					departure : {
						primaryId : ((tmov.*E1EDT44 filter ($.QUALI == "001")).WERKS)[0],
						primaryId : ((tmov.*E1EDT44 filter ($.QUALI == "001")).KUNNR)[0],
						primaryId : ((tmov.*E1EDT44 filter ($.QUALI == "001")).VSTEL)[0],
						primaryId : ((tmov.*E1EDT44 filter ($.QUALI == "001")).LIFNR)[0],
						primaryId : ((tmov.*E1EDT44 filter ($.QUALI == "001")).KNOTE)[0],
						primaryId : ((tmov.*E1EDT44 filter ($.QUALI == "001")).LGNUM)[0],
						name : ((tmov.*E1EDT44 filter ($.*QUALI contains "001")).E1ADRM6.NAME1)[0]
					},
					arrival : {
						primaryId : ((tmov.*E1EDT44 filter ($.QUALI == "002")).WERKS)[0],
						primaryId : ((tmov.*E1EDT44 filter ($.QUALI == "002")).KUNNR)[0],
						primaryId : ((tmov.*E1EDT44 filter ($.QUALI == "002")).VSTEL)[0],
						primaryId : ((tmov.*E1EDT44 filter ($.QUALI == "002")).LIFNR)[0],
						primaryId : ((tmov.*E1EDT44 filter ($.QUALI == "002")).KNOTE)[0],
						primaryId : ((tmov.*E1EDT44 filter ($.QUALI == "002")).LGNUM)[0],
						name : ((tmov.*E1EDT44 filter ($.*QUALI contains "002")).E1ADRM6.NAME1)[0]
					}
				},
				carrier : {
					primaryId : ((tmov.*E1ADRM7 filter ($.*PARTNER_Q default "" contains "SP")).PARTNER_ID)[0],
				(if (((tmov.*E1ADRM7.*E1ADRE7 filter ((tmov.*E1ADRM7.*PARTNER_Q default "" contains "SP") and ($.*EXTEND_Q contains "304"))).EXTEND_D)[0] != "" and ((tmov.*E1ADRM7.*E1ADRE7 filter ((tmov.*E1ADRM7.*PARTNER_Q default "" contains "SP") and ($.*EXTEND_Q contains "304"))).EXTEND_D)[0] != null) additionalPartyId : [
							{
								value : ((tmov.*E1ADRM7.*E1ADRE7 filter ((tmov.*E1ADRM7.*PARTNER_Q default "" contains "SP") and ($.*EXTEND_Q contains "304"))).EXTEND_D)[0],
								typeCode : "SCAC"
							}
						] else {}),
					name : ((tmov.*E1ADRM7 filter ($.*PARTNER_Q default "" contains "SP")).NAME1)[0]
				},
				movementDates : {
					estimatedDepartureDateTime : if ((((tmov.*E1EDT45 filter ($.*QUALF default "" contains "005")).NTANF)[0] default "") != "" and (((tmov.*E1EDT45 filter ($.*QUALF default "" contains "005")).NTANF)[0] default "") != null and (((tmov.*E1EDT45 filter ($.*QUALF default "" contains "005")).NTANF)[0] default "") != "00000000") (globalDataweaveFunctions::formatDate(((tmov.*E1EDT45 filter ($.*QUALF default "" contains "005")).NTANF)[0] default "")) ++ "T" ++ globalDataweaveFunctions::timeConversion(((tmov.*E1EDT45 filter ($.*QUALF default "" contains "005")).NTANZ)[0] default "") ++ ".000+00:00" else "",
					actualDepartureDateTime : if ((((tmov.*E1EDT45 filter ($.*QUALF default "" contains "005")).ISDD)[0] default "") != "" and (((tmov.*E1EDT45 filter ($.*QUALF default "" contains "005")).ISDD)[0] default "") != null and (((tmov.*E1EDT45 filter ($.*QUALF default "" contains "005")).ISDD)[0] default "") != "00000000") (globalDataweaveFunctions::formatDate(((tmov.*E1EDT45 filter ($.*QUALF default "" contains "005")).ISDD)[0] default "")) ++ "T" ++ globalDataweaveFunctions::timeConversion(((tmov.*E1EDT45 filter ($.*QUALF default "" contains "005")).ISDZ)[0] default "") ++ ".000+00:00" else "",
					estimatedDeliveryDateTime : if ((((tmov.*E1EDT45 filter ($.*QUALF default "" contains "005")).NTEND)[0] default "") != "" and (((tmov.*E1EDT45 filter ($.*QUALF default "" contains "005")).NTEND)[0] default "") != null and (((tmov.*E1EDT45 filter ($.*QUALF default "" contains "005")).NTEND)[0] default "") != "00000000") (globalDataweaveFunctions::formatDate(((tmov.*E1EDT45 filter ($.*QUALF default "" contains "005")).NTEND)[0] default "")) ++ "T" ++ globalDataweaveFunctions::timeConversion(((tmov.*E1EDT45 filter ($.*QUALF default "" contains "005")).NTENZ)[0] default "") ++ ".000+00:00" else "",
					actualDeliveryDateTime : if ((((tmov.*E1EDT45 filter ($.*QUALF default "" contains "005")).IEDD)[0] default "") != "" and (((tmov.*E1EDT45 filter ($.*QUALF default "" contains "005")).IEDD)[0] default "") != null and (((tmov.*E1EDT45 filter ($.*QUALF default "" contains "005")).IEDD)[0] default "") != "00000000") (globalDataweaveFunctions::formatDate(((tmov.*E1EDT45 filter ($.*QUALF default "" contains "005")).IEDD)[0] default "")) ++ "T" ++ globalDataweaveFunctions::timeConversion(((tmov.*E1EDT45 filter ($.*QUALF default "" contains "005")).IEDZ)[0] default "") ++ ".000+00:00" else ""
				},
				transportInformation : {
					transportModeCode : if (tmov.VSART == "01") "30" else if (tmov.VSART == "02") "50" else if (tmov.VSART == "03") "20" else if (tmov.VSART == "04") "10" else if (tmov.VSART == "05") "40" else ""
				}
			}
			)
	}))