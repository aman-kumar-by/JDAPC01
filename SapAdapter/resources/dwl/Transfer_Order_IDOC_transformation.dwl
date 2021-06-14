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
output application/json skipNullOn = "everywhere", encoding = "UTF-8"
import lookup_utils::globalDataweaveFunctions
---
(payload.*IDOC map {
	creationDateTime: globalDataweaveFunctions::formatDateToDateTime(globalDataweaveFunctions::formatDate(($.*E1EDK03 filter ($.IDDAT == "012") map ($.DATUM))[0] default "")),
	documentStatusCode: "ORIGINAL",
	documentActionCode: "CHANGE_BY_REFRESH",
	senderDocumentId: $.EDI_DC40.DOCNUM,
	buyerName: ($.*E1EDKA1 filter(($.PARVW  default "") == "AG") map ($.ORGTX))[0],
	(supplierName: ($.*E1EDKA1 filter(($.PARVW  default "") == "LF") map ($.NAME1))[0]) if(($.E1EDK01.BSART default "") == "NB"),
	orderSubType: "Stock Transfer",
	processType: "Supply",
	orderId: $.E1EDK01.BELNR,
	orderTypeCode: (if ( ($.E1EDK01.BSART default "") == "NB" ) "220" else if ( ($.E1EDK01.BSART default "") == "UB" ) "150" else ""),
	($.*E1EDS01 filter(($.SUMID default "" as String) == "002") map {
		totalMonetaryAmountIncludingTaxes: {
			value: $.SUMME as Number,
			currencyCode: $.SUNIT
		}
	}),
	($.*E1EDKA1 filter(($.PARVW default "") == "AG") map {
		buyer: {
			primaryId: $.PARTN
		},
	}),
	supplier: {
		(primaryId: ($.*E1EDKA1 filter(($.PARVW default "") == "LF") map ($.PARTN))[0]) if(($.E1EDK01.BSART default "") == "NB"),
		(primaryId: ($.*E1EDKA1 filter(($.PARVW default "") == "LS") map ($.PARTN))[0]) if(($.E1EDK01.BSART default "") == "UB")
	},
	orderLogisticalInformation: {
		shipFrom: {
			(primaryId: ($.*E1EDKA1 filter(($.PARVW default "") == "LF") map ($.PARTN))[0]) if(($.E1EDK01.BSART default "") == "NB"),
			(primaryId: ($.*E1EDKA1 filter(($.PARVW default "") == "LS") map ($.PARTN))[0]) if(($.E1EDK01.BSART default "") == "UB"),
			(organisationName: ($.*E1EDKA1 filter(($.PARVW default "") == "LF") map ($.BNAME))[0])if(($.E1EDK01.BSART default "") == "NB")
		},
		($.*E1EDKA1 filter(($.PARVW default "") == "WE") map {
			shipTo: {
				primaryId: $.LIFNR,
				organisationName: $.NAME1
			}
		}),
	},
	deliveryTerms: {
		incotermsCode: ($.*E1EDK17 filter(($.QUALF default "" as String) == "001") map ($.LKOND))[0],
	},
	lineItem: ($.*E1EDP01 map ((k,v) -> using ( meneeData = k.MENEE default "" ) {
		lineItemNumber: k.POSEX as Number, // TBD
		requestedQuantity: {
			value: k.MENGE as Number,
			measurementUnitCode: if ( not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[meneeData]) ) vars.uomCodeMap.measurementUnitCodeMap[meneeData] else meneeData
		},
		(if ( k.ACTION == "001" ) actionCode: "ADDITION" else if ( k.ACTION == "002" ) actionCode: "CHANGED" else actionCode: "DELETED"),
		(if ( k.NETWR != null ) netAmount: {
			value: k.NETWR as Number,
			(currencyCode: ($.*E1EDS01 filter(($.SUMID  default "") == "002") map ($.SUNIT))[0])
		} else {
		}),
		(if ( k.VPREI != null ) netPrice: {
			value: k.VPREI as Number,
			(currencyCode: ($.*E1EDS01 filter(($.SUMID  default "") == "002") map ($.SUNIT))[0])
		} else {
		}),
		salesOrder: {
			entityId: "UNKNOWN",
			needByDate: globalDataweaveFunctions::formatDate(k.E1EDP20.EDATU default "")
		},
		(if ( k.ACTION == "001" or k.ACTION == "002" ) lineStatus: "ACTIVE" else if ( k.ACTION == "003" ) lineStatus: "INACTIVE" else lineStatus: "ACTIVE"),
		lastUpdateDateTime: (globalDataweaveFunctions::formatDate($.EDI_DC40.CREDAT default "")) ++ "T" ++ globalDataweaveFunctions::timeConversion($.EDI_DC40.CRETIM default "") ++ ".000+00:00",
		itemFamily: k.MATKL,
		commodityCode: (k.*E1EDP19 filter(($.QUALF default "") == "001") map ($.IDTNR))[0],
		lotSize: k.PEINH as Number,
		($.*E1EDK14 filter(($.QUALF default "") == "014") map {
			purchasingOrg: $.ORGID
		}),
		($.*E1EDK14 filter(($.QUALF default "") == "009") map {
			purchasingGroup: $.ORGID
		}),
		($.*E1EDK14 filter(($.QUALF default "") == "011") map {
			companyCode: $.ORGID
		}),
		orderLogisticalInformation: {
			(shipFrom: {
				($.*E1EDKA1 filter(($.PARVW  default "") == "LF") map {
					primaryId: $.PARTN
				}),
			})if(($.E1EDK01.BSART default "") == "NB"),
			(shipFrom: {
				($.*E1EDKA1 filter(($.PARVW  default "") == "LS") map {
					primaryId: $.PARTN
				}),
			})if(($.E1EDK01.BSART default "") == "UB"),
			shipTo: {
				($.*E1EDKA1 filter(($.PARVW  default "") == "WE") map {
					primaryId: $.LIFNR
				}),
			},
			orderLogisticalDateInformation: {
				requestedDeliveryDateTime: {
					date: globalDataweaveFunctions::formatDate(k.E1EDP20.EDATU default "")
				}
			}
		},
		transactionalTradeItem: {
			// gtin : "00000000000000",
			(k.*E1EDP19 filter(($.QUALF default "" as String) == "001") map {
				primaryId: $.IDTNR,
				tradeItemDescription: {
					value: $.KTEXT,
					languageCode: "en"
				}
			}),
		},
		lineItemDetail: (k.*E1EDP20 map (k1,v1) -> {
				requestedQuantity: {
					value: k1.WMENG as Number,
					measurementUnitCode: if ( not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[meneeData]) ) vars.uomCodeMap.measurementUnitCodeMap[meneeData] else meneeData
				},
				orderLogisticalInformation: {
					shipTo: {
						primaryId: k.WERKS
					},
					orderLogisticalDateInformation: {
						requestedDeliveryDateTime: {
							date: globalDataweaveFunctions::formatDate(k1.EDATU default ""),
							time: if ( not isEmpty(k1.EZEIT) ) k1.EZEIT else "23:59:00"
						}
					}
				}
		})
	}))
})