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
(payload.*IDOC map {
			(creationDateTime: globalDataweaveFunctions::formatDateToDateTime(globalDataweaveFunctions::formatDate($.E1EDK02.DATUM default ""))) if(not isEmpty($.E1EDK02.DATUM)),
			documentStatusCode: "ORIGINAL",
			documentActionCode: "CHANGE_BY_REFRESH",
			senderDocumentId : $.EDI_DC40.DOCNUM,
			orderSubType : ($.*E1EDK14 filter(($.QUALF default "" as String) == "012") map (if($.ORGID == "TA") "Standard Order" else if($.ORGID == "SO") "Rush Order" else if($.ORGID == "BV") "Cash Sales" else ""))[0],
			purchaseOrder : {
				(entityId : $.E1EDP01.E1EDP02.BELNR) if(($.E1EDP01.E1EDP02.QUALF default "") == "001"),
				(creationDateTime : globalDataweaveFunctions::formatDateToDateTime(globalDataweaveFunctions::formatDate($.E1EDP01.E1EDP02.DATUM default ""))) if(($.E1EDP01.E1EDP02.QUALF default "") == "001")
			},
			demandChannel : ((($.*E1EDK14 filter ($.QUALF == "008"))[0].ORGID default "") ++ p('sap.demandChannel.delimiter') ++ (($.*E1EDK14 filter ($.QUALF == "007"))[0].ORGID default "")),
			deliveryBlock : $.E1EDK01.LIFSK,
			//salesOrganization : ($.*E1EDK14 filter(($.QUALF default "" as String) == "008") map ($.ORGID))[0],
			division : ($.*E1EDK14 filter(($.QUALF default "" as String) == "006") map ($.ORGID))[0],
			distributionChannel : ($.*E1EDK14 filter(($.QUALF default "" as String) == "007") map ($.ORGID))[0],
			buyerName : ($.*E1EDKA1 filter ($.PARVW == "AG"))[0].NAME1,
			orderId : $.E1EDK01.BELNR,
			orderTypeCode : ($.*E1EDK14 filter(($.QUALF default "" as String) == "012") map (if($.ORGID == "TA" or $.ORGID == "BV" or $.ORGID == "SO") "221" else ""))[0],
			($.*E1EDS01 filter(($.SUMID default "" as String) == "002") map {
				(if ($.SUMME != null and $.SUMME != "" and $.SUNIT != null and $.SUNIT != "") totalMonetaryAmountIncludingTaxes: {
				value: $.SUMME as Number,
				currencyCode: $.SUNIT
			} else {}),
			}),
			($.*E1EDKA1 filter(($.PARVW default "") == "AG") map {
				buyer : {
					primaryId : $.PARTN
				},
			}),
			supplier : {
				primaryId : $.E1EDP01.WERKS,
			},
			($.*E1EDKA1 filter(($.PARVW default "") == "RE") map {
				billTo : {
					primaryId : $.PARTN,
				},
			}),
			($.*E1EDKA1 filter(($.PARVW default "") == "WE") map {
				orderLogisticalInformation : {
					shipTo : {
						primaryId : $.PARTN,
						address : {
							city : $.ORT01,
							countryCode : $.LAND1,
							postalCode : $.PSTLZ,
							state : $.REGIO,
							streetAddressOne : $.STRAS,
							streetAddressTwo : $.STRS2
						}
					}
				}
			}),
			deliveryTerms : {
				incotermsCode : ($.*E1EDK17 filter(($.QUALF default "" as String) == "001") map ($.LKOND))[0],
			},
			lineItem : ( $.*E1EDP01 map ((k,v) -> using(meneeData = k.MENEE default "") {
					lineItemNumber : k.POSEX as Number,
					purchaseOrder : {
						(k.*E1EDP02 filter(($.QUALF default "") =="001") map {
							entityId : $.BELNR,
							(creationDateTime : globalDataweaveFunctions::formatDateToDateTime(globalDataweaveFunctions::formatDate($.DATUM default "")))if(not isEmpty($.DATUM)),
							lineItemNumber : $.ZEILE
						})
					},
					orderLogisticalInformation : {
						orderLogisticalDateInformation : {
							requestedDeliveryDateTime : {
								date : globalDataweaveFunctions::formatDate(($.*E1EDK03 filter(($.IDDAT default "") == "002") map ($.DATUM))[0] default ""),
								time : "23:59:00"
							}
						}
					},
					lineStatus : if(not isEmpty(k.ABGRU)) "INACTIVE" else "ACTIVE",
					itemFamily : k.MATKL,
					isReservedOrder : false,
					planningStatus : 1,
					requestedQuantity : {
						value : k.MENGE as Number,
						measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[meneeData])) vars.uomCodeMap.measurementUnitCodeMap[meneeData] else meneeData
					},
					(if ($.NETWR != null and $.NETWR != "") netAmount : {
						value : $.NETWR as Number,
						currencyCode : $.CURCY
					} else {
					}),
					(if ($.VPREI != null and $.VPREI != "") netPrice : {
						value : $.VPREI as Number,
						currencyCode : $.CURCY
					} else {
					}),
					transactionalTradeItem : {
						// gtin : "00000000000000",
						(k.*E1EDP19 filter(($.QUALF default "" as String) == "002") map {
							primaryId : $.IDTNR,
							tradeItemDescription : {
								value : $.KTEXT,
								languageCode : "en"
							}
						}),
					},
					lineItemDetail : (k.*E1EDP20 map (k1,v1) -> {
							requestedQuantity : {
								value : k1.WMENG as Number,
								measurementUnitCode : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[meneeData])) vars.uomCodeMap.measurementUnitCodeMap[meneeData] else meneeData
							},
							orderLogisticalInformation : {
								shipFrom : {
									primaryId : k.WERKS
								},
								shipTo : {
									primaryId : ($.*E1EDKA1 filter(($.PARVW default "") == "WE") map ($.PARTN))[0]
								},
								orderLogisticalDateInformation : {
									requestedDeliveryDateTime : {
										(date : globalDataweaveFunctions::formatDate(k1.EDATU default "")) if (not isEmpty(k1.EDATU)),
										time : if(not isEmpty(k1.EZEIT)) (globalDataweaveFunctions::timeConversion(k1.EZEIT)) else "23:59:00",
									}
								}
							}
					} ),
					avpList : [{
						name : "orderLinePriority",
						value : k.LPRIO
					}]
			}))
	})