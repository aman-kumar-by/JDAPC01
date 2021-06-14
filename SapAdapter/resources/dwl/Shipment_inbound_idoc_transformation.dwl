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
import isNumeric from dw::core::Strings
import lookup_utils::globalDataweaveFunctions
output application/xml skipNullOn="everywhere", encoding="UTF-8"
---
root
: {
	(payload.transportLoad map using (stopsInfo = $.stop orderBy($.stopSequenceNumber), LoadPicks=flatten($.stop.pickupShipmentReference).primaryId) {
		IDOC @(BEGIN : "1") : {
			EDI_DC40 : {
				TABNAM : p('SAP.TABNAM'),
				MANDT : p('SAP.MANDT'),
				IDOCTYP : "SHPMNT06",
				MESTYP : "SHPMNT",
				SNDPOR : p('SAP.SNDPOR'),
				SNDPRT : p('SAP.SNDPRT'),
				SNDPRN : p('SAP.SNDPRN'),
				RCVPOR : p('SAP.RCVPOR'),
				RCVPRT : p("SAP.RCVPRT"),
				RCVPRN : p('SAP.RCVPRN'),
			},
			E1EDT20 @(SEGMENT : "1") : using(countryList = globalDataweaveFunctions::getCountries($.stop)) {
				TKNUM : if(isNumeric($.transportLoadId)) globalDataweaveFunctions::padFront($.transportLoadId,10) else $.transportLoadId,
				SIGNI : $.transportEquipment.assetId[0].primaryId,
				SHTYP : "0003",
				(if(($.documentActionCode) == "CHANGE_BY_REFRESH") {
						E1EDT18 @(SEGMENT : "1") : {
							QUALF : "CHA",
							PARAM : 1,
						},
						E1EDT18 : {
							QUALF : "PID",
							PARAM : "TKNUM",
						}
					}else if(($.documentActionCode) == "ADD") {
						E1EDT18 @(SEGMENT : "1") : {
							QUALF : "ORI",
							//PARAM : "",
						},
						E1EDT18 @(SEGMENT : "1") : {
							QUALF : "PID",
							PARAM : "TKNUM",
						}
					} else {}),
				(E1ADRM4 @(SEGMENT : "1") : {
					PARTNER_Q : "OTP",
					E1ADRE4 @(SEGMENT : "1") : {
						EXTEND_Q : "305",
						EXTEND_D : $.logisticServicesSeller.contact[0].departmentName
					}
				}) if(not isEmpty($.logisticServicesSeller.contact[0].departmentName)),
				(E1ADRM4 @(SEGMENT : "1") : {
					PARTNER_Q : "SP",
					PARTNER_ID : $.logisticServicesSeller.primaryId,
				}) if(not isEmpty($.logisticServicesSeller.primaryId)),
				E1EDT10 @(SEGMENT : "1") : {
					QUALF : "003",
					(NTANF : (($.loadStartDateTime splitBy "T")[0]) replace "-" with "")if(not isEmpty($.loadStartDateTime)),
					(NTANZ : ((($.loadStartDateTime splitBy "T")[1] splitBy ".")[0]) replace ":" with "")if(not isEmpty($.loadStartDateTime)),
					(NTEND : (($.loadEndDateTime splitBy "T")[0]) replace "-" with "")if(not isEmpty($.loadEndDateTime)),
					(NTENZ : ((($.loadEndDateTime splitBy "T")[1] splitBy ".")[0]) replace ":" with "")if(not isEmpty($.loadEndDateTime))
				},
				(stopsInfo filter((sizeOf(stopsInfo)-1) > $$) map (d1,v1)->using(picksD = (Mule::lookup('bydm_shipment_inboundFlow1', {pickData:(d1.pickupShipmentReference map ($.primaryId)) default [],transportIndex : $$,	dropData : (d1.dropoffShipmentReference map ($.primaryId)) default []}))) {
					E1EDK33 : {
						TSNUM : globalDataweaveFunctions::padFront((v1 + 1),4),//d1.stopIdentifier,
						TSRFO : d1.stopSequenceNumber,
						TSTYP : 1, //Default to 1,
						VSART : "01", //Default to TRUCK - 01 is truck in SAP
						E1EDT44 : {
							QUALI : "001",
							(KNOTE : d1.stopLocation.additionalLocationId[0]) if (("PORT" == upper(d1.stopLocationType default "")) or isEmpty(d1.stopLocationType)),
							(KUNNR : d1.stopLocation.additionalLocationId[0]) if (("CUSTOMER" == upper(d1.stopLocationType default ""))),
							(WERKS : d1.stopLocation.additionalLocationId[0]) if (("WAREHOUSE_AND_OR_DEPOT" == upper(d1.stopLocationType default "")) or ("MANUFACTURING_PLANT" == upper(d1.stopLocationType default "")) or ("STORE" == upper(d1.stopLocationType default ""))),
							(LIFNR : d1.stopLocation.additionalLocationId[0]) if (("SUPPLIER" == upper(d1.stopLocationType default ""))),
							(VSTEL : d1.stopLocation.additionalLocationId[0]) if (("DOCK_DOOR" == upper(d1.stopLocationType default ""))),
						},
						E1EDT44 : {
							QUALI : "002",
							(KNOTE : stopsInfo[v1 + 1].stopLocation.additionalLocationId[0]) if (("PORT" == upper(stopsInfo[v1 + 1].stopLocationType default "")) or isEmpty(stopsInfo[v1 + 1].stopLocationType)),
							(KUNNR : stopsInfo[v1 + 1].stopLocation.additionalLocationId[0]) if (("CUSTOMER" == upper(stopsInfo[v1 + 1].stopLocationType default ""))),
							(WERKS : stopsInfo[v1 + 1].stopLocation.additionalLocationId[0]) if (("WAREHOUSE_AND_OR_DEPOT" == upper(stopsInfo[v1 + 1].stopLocationType default "")) or ("MANUFACTURING_PLANT" == upper(stopsInfo[v1 + 1].stopLocationType default "")) or ("STORE" == upper(stopsInfo[v1 + 1].stopLocationType default ""))),
							(LIFNR : stopsInfo[v1 + 1].stopLocation.additionalLocationId[0]) if (("SUPPLIER" == upper(stopsInfo[v1 + 1].stopLocationType default ""))),
							(VSTEL : stopsInfo[v1 + 1].stopLocation.additionalLocationId[0]) if (("DOCK_DOOR" == upper(stopsInfo[v1 + 1].stopLocationType default ""))),
							
						},
						(picksD map (p1,v1)-> {
							E1EDT01 : {
								VBELN : p1
							},
						})
					}
				}),
				(LoadPicks map {
					E1EDL20 :{
						VBELN : $
					}
				})
				
			},
			
		}
	})
}
