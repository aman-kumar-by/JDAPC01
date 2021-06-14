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
output application/json encoding = "UTF-8",skipNullOn = "everywhere"
import lookup_utils::globalDataweaveFunctions
---
(payload.*IDOC default [] map {
	(($.E1EDL20.*E1EDT13) filter ($.QUALF == "015") map {
		creationDateTime: globalDataweaveFunctions::formatDate($.NTANF default "") ++ "T" ++ globalDataweaveFunctions::timeConversion($.NTANZ default "")
	}),
	documentStatusCode: "ORIGINAL",
	documentActionCode: if ( $.E1EDL20.E1EDL18.QUALF == "ORI" ) "ADD" else "CHANGE_BY_REFRESH",
	senderDocumentId: $.EDI_DC40.DOCNUM,
	transportInstructionId: $.E1EDL20.VBELN,
	transportInstructionFunction: "SHIPMENT",
	logisticServicesSeller: {
		(if ( ($.E1EDL20.E1EDL21.LFART == "LF") or ($.E1EDL20.E1EDL21.LFART == "NL") or ($.E1EDL20.E1EDL21.LFART == "NLCC") ) primaryId: $.E1EDL20.VKORG
					else if ( $.E1EDL20.E1EDL21.LFART == "EL" ) (($.E1EDL20.*E1ADRM1) filter ($.PARTNER_Q == "LF") map {
			primaryId: $.PARTNER_ID default ""
		})else 	primaryId: null)
	},
	logisticServicesBuyer: {
		(if ( $.E1EDL20.E1EDL21.LFART == "LF" ) (($.E1EDL20.*E1ADRM1) filter ($.PARTNER_Q == "AG") map {
			primaryId: $.PARTNER_ID default ""
		})else if ( ($.E1EDL20.E1EDL21.LFART == "NL") or ($.E1EDL20.E1EDL21.LFART == "NLCC") ) (($.E1EDL20.*E1ADRM1) filter ($.PARTNER_Q == "WE") map {
			primaryId: $.PARTNER_ID default ""
		})else if ( $.E1EDL20.E1EDL21.LFART == "EL" ) primaryId: $.E1EDL20.*E1EDL24[0].WERKS default ""
					  else  primaryId: null)
	},
	shipment: [{
		primaryId: $.E1EDL20.VBELN,
		deliveryTypeCode: if ( $.E1EDL20.E1EDL21.LFART == "LF" ) "CUSTOMER_ORDER" else if ( $.E1EDL20.E1EDL21.LFART == "NL" or $.E1EDL20.E1EDL21.LFART == "NLCC" ) "TRANSFER_ORDER" else if ( $.E1EDL20.E1EDL21.LFART == "EL" ) "PURCHASE_ORDER" else null,
		(if ( $.E1EDL20.E1EDL21.LFART == "LF" ) (($.E1EDL20.*E1ADRM1) filter ($.PARTNER_Q == "AG") map {
			customerCode: $.PARTNER_ID default ""
		})
					else if ( ($.E1EDL20.E1EDL21.LFART == "NL") or ($.E1EDL20.E1EDL21.LFART == "NLCC") ) (($.E1EDL20.*E1ADRM1) filter ($.PARTNER_Q == "WE") map {
			customerCode: $.PARTNER_ID default ""
		})
					else if ( $.E1EDL20.E1EDL21.LFART == "EL" ) customerCode: $.E1EDL20.*E1EDL24[0].WERKS default ""
					else 
						customerCode: null),
		(if ( ($.E1EDL20.E1EDL21.LFART == "LF") or ($.E1EDL20.E1EDL21.LFART == "NL") or ($.E1EDL20.E1EDL21.LFART == "NLCC") ) shipperName: $.E1EDL20.E1EDL22.VKORG_BEZ
					else if ( $.E1EDL20.E1EDL21.LFART == "EL" ) (($.E1EDL20.*E1ADRM1) filter ($.PARTNER_Q == "LF") map {
			shipperName: $.NAME1
		})
					else null),
		(if ( $.E1EDL20.E1EDL21.LFART == "LF" ) (($.E1EDL20.*E1ADRM1) filter ($.PARTNER_Q == "AG") map {
			receiverName: $.NAME1 default ""
		})
					else if ( ($.E1EDL20.E1EDL21.LFART == "NL") or ($.E1EDL20.E1EDL21.LFART == "NLCC") ) (($.E1EDL20.*E1ADRM1) filter ($.PARTNER_Q == "WE") map {
			receiverName: $.NAME1 default ""
		})
					else if ( $.E1EDL20.E1EDL21.LFART == "EL" ) receiverName: $.E1EDL20.*E1EDL24[0].E1EDL26.E1EDL27.WERKS_BEZ default ""
					else 
						receiverName: null),
		(($.E1EDL20.*E1EDT13) filter ($.QUALF == "006") map {
			(if ( $.ISDD != "00000000" and $.ISDZ != "000000" ) actualShipDateTime: $.ISDD default "" ++ $.ISDZ default "" else {
			})
		}),
		shippingInformation: {
			shipmentSplitMethod: if ( $.E1EDL20.E1EDL21.AUTLF == "X" ) "NO_SPLIT" else "DETAIL_LEVEL",
			holdShipment: if ( $.E1EDL20.E1EDL21.LIFSK != null and $.E1EDL20.E1EDL21.LIFSK != "" ) true else false
		},
		tmReferenceNumber: [{
			(referenceNumberName: "DISTCH") if ($.E1EDL20.*E1EDL24[0].VTWEG != null and $.E1EDL20.*E1EDL24[0].VTWEG != ""),
			referenceNumberValue: $.E1EDL20.*E1EDL24[0].VTWEG
		},{
			(referenceNumberName: "SAPDIV") if ($.E1EDL20.*E1EDL24[0].SPART != null and $.E1EDL20.*E1EDL24[0].SPART != ""),
			referenceNumberValue: $.E1EDL20.*E1EDL24[0].SPART
		},{
			(referenceNumberName: "PO") if (not isEmpty(($.E1EDL20.*E1EDL24.*E1EDL41) filter ($.QUALI == "001"))),
			referenceNumberValue: (($.E1EDL20.*E1EDL24.*E1EDL41) filter ($.QUALI == "001"))[0].BSTNR
		},{
			(referenceNumberName: "INCO1") if ($.E1EDL20.INCO1 != null and $.E1EDL20.INCO1 != ""),
			referenceNumberValue: $.E1EDL20.INCO1
		},{
			(referenceNumberName: "INCO2") if ($.E1EDL20.INCO2 != null and $.E1EDL20.INCO2 != ""),
			referenceNumberValue: $.E1EDL20.INCO2
		},{
			referenceNumberName: "RUSH",
			referenceNumberValue: if ( $.E1EDL20.VSBED == "10" ) "Y" else "N"
		},{
			(referenceNumberName: "SHCOND") if ($.E1EDL20.VSBED != null and $.E1EDL20.VSBED != ""),
			referenceNumberValue: $.E1EDL20.VSBED
		},{
			(referenceNumberName: "PIDT") if (not isEmpty(($.E1EDL20.*E1EDT13) filter ($.QUALF == "007"))),
			(($.E1EDL20.*E1EDT13) filter ($.QUALF == "007") map {
				referenceNumberValue: $.NTANF default "" ++ $.NTANZ default ""
			})
		},{
			(referenceNumberName: "AIDT") if (not isEmpty(($.E1EDL20.*E1EDT13) filter ($.QUALF == "006"))),
			(($.E1EDL20.*E1EDT13) filter ($.QUALF == "006") map {
				referenceNumberValue: $.ISDD default "" ++ $.ISDZ default ""
			})
		}],
		shipmentItem: flatten([(($.E1EDL20.*E1EDL24) map (transportInstructionShipmentItem, indexOfTransportInstructionShipmentItem) -> {
			lineItemNumber: transportInstructionShipmentItem.POSNR as Number,
			itemName: transportInstructionShipmentItem.ARKTX,
			commodityTypeCode: [{
				value: transportInstructionShipmentItem.E1EDL35.STAWN,
				codeListName: "CommodityCode"
			}],
			transportModeCode: if ( $.E1EDL20.E1EDL28.VSART == "01" ) "30" else if ( $.E1EDL20.E1EDL28.VSART == "02" ) "100" else if ( $.E1EDL20.E1EDL28.VSART == "03" ) "20" else if ( $.E1EDL20.E1EDL28.VSART == "04" ) "10" else if ( $.E1EDL20.E1EDL28.VSART == "05" ) "40" else "50",
			tmReferenceNumber: [{
				(referenceNumberName: "SUNIT") if (transportInstructionShipmentItem.VRKME != null and transportInstructionShipmentItem.VRKME != ""),
				referenceNumberValue: transportInstructionShipmentItem.VRKME
			},
									 {
				(referenceNumberName: "ITYPE") if (transportInstructionShipmentItem.MATKL != null and transportInstructionShipmentItem.MATKL != ""),
				referenceNumberValue: transportInstructionShipmentItem.MATKL
			}]
		}),
			(($.E1EDL20.*E1EDL24) filter (isEmpty($.HIPOS)) map (transportInstructionShipmentItemValue, transportInstructionShipmentItemIndex) -> using ( transportInstructionShipmentItemBatches = (($.E1EDL20.*E1EDL24) filter ($.HIPOS == transportInstructionShipmentItemValue.POSNR)) default [] ) {
			lineItemNumber: transportInstructionShipmentItemValue.POSNR as Number,
			transactionalTradeItem: [{
				primaryId: transportInstructionShipmentItemValue.MATNR,
				additionalTradeItemId: [{
					value: transportInstructionShipmentItemValue.MATNR,
					typeCode: "00000000000000"
				}],
				(if ( isEmpty (transportInstructionShipmentItemBatches) ) tradeItemQuantity: {
					value: transportInstructionShipmentItemValue.LFIMG as Number,
					measurementUnitCode: if ( not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[transportInstructionShipmentItemValue.VRKME default ""]) ) vars.uomCodeMap.measurementUnitCodeMap[transportInstructionShipmentItemValue.VRKME] else transportInstructionShipmentItemValue.VRKME
				}
								else 
									tradeItemQuantity: {
					value: sum (transportInstructionShipmentItemBatches.LFIMG) as Number,
					measurementUnitCode: if ( not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[(transportInstructionShipmentItemBatches.VRKME[0]) default ""]) ) vars.uomCodeMap.measurementUnitCodeMap[(transportInstructionShipmentItemBatches.VRKME[0])] else (transportInstructionShipmentItemBatches.VRKME[0])
				}),
				tradeItemDescription: {
					value: transportInstructionShipmentItemValue.ARKTX,
					languageCode: "en"
				},
				(if ( isEmpty (transportInstructionShipmentItemBatches) ) transactionalItemData: [{
					batchNumber: transportInstructionShipmentItemValue.CHARG,
					countryOfOrigin: transportInstructionShipmentItemValue.E1EDL35.HERKL
				}]
								else 
									(transportInstructionShipmentItemBatches map {
					transactionalItemData: [{
						batchNumber: $.CHARG,
						countryOfOrigin: $.E1EDL35.HERKL
					}]
				}))
			}],
			transportCargoCharacteristics: {
				cargoTypeCode: "12",
				(if ( isEmpty (transportInstructionShipmentItemBatches) ) totalGrossWeight: {
					value: transportInstructionShipmentItemValue.BRGEW as Number,
					measurementUnitCode: if ( not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[transportInstructionShipmentItemValue.GEWEI default ""]) ) vars.uomCodeMap.measurementUnitCodeMap[transportInstructionShipmentItemValue.GEWEI] else transportInstructionShipmentItemValue.GEWEI
				}
								else 
									totalGrossWeight: {
					value: sum (transportInstructionShipmentItemBatches.BRGEW) as Number,
					measurementUnitCode: if ( not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[(transportInstructionShipmentItemBatches.GEWEI[0]) default ""]) ) vars.uomCodeMap.measurementUnitCodeMap[(transportInstructionShipmentItemBatches.GEWEI[0])] else (transportInstructionShipmentItemBatches.GEWEI[0])
				})
			},
			transportReference: flatten([
					((transportInstructionShipmentItemValue.*E1EDL43) filter ($.QUALF == "V") map {
				entityId: $.BELNR,
				lineItemNumber: $.POSNR as Number,
				(typeCode: "PW") if (not isEmpty(((transportInstructionShipmentItemValue.*E1EDL43) filter ($.QUALF == "V"))))
			}),
					((transportInstructionShipmentItemValue.*E1EDL43) filter ($.QUALF == "C") map {
				entityId: $.BELNR,
				lineItemNumber: $.POSNR as Number,
				(typeCode: "ON") if (not isEmpty(((transportInstructionShipmentItemValue.*E1EDL43) filter ($.QUALF == "C"))))
			})
				])
		})]),
		receiver: {
			(if ( ($.E1EDL20.E1EDL21.LFART == "LF") or ($.E1EDL20.E1EDL21.LFART == "NL") or ($.E1EDL20.E1EDL21.LFART == "NLCC") ) (($.E1EDL20.*E1ADRM1) filter ($.PARTNER_Q == "WE") map {
				primaryId: $.PARTNER_ID default ""
			})else if ( $.E1EDL20.E1EDL21.LFART == "EL" ) primaryId: $.E1EDL20.*E1EDL24[0].WERKS default ""
						else primaryId: null)
		},
		shipper: {
			(if ( ($.E1EDL20.E1EDL21.LFART == "LF") or ($.E1EDL20.E1EDL21.LFART == "NL") or ($.E1EDL20.E1EDL21.LFART == "NLCC") ) primaryId: $.E1EDL20.VKORG
						else if ( $.E1EDL20.E1EDL21.LFART == "EL" ) (($.E1EDL20.*E1ADRM1) filter ($.PARTNER_Q == "LF") map {
				primaryId: $.PARTNER_ID default ""
			})
						else primaryId: null),
			contact: [{
				contactTypeCode: "CZL"
			}],
			(if ( ($.E1EDL20.E1EDL21.LFART == "LF") or ($.E1EDL20.E1EDL21.LFART == "NL") or ($.E1EDL20.E1EDL21.LFART == "NLCC") ) organisationName: $.E1EDL20.VKORG
						else if ( $.E1EDL20.E1EDL21.LFART == "EL" ) (($.E1EDL20.*E1ADRM1) filter ($.PARTNER_Q == "LF") map {
				organisationName: $.PARTNER_ID default ""
			})
						else organisationName: null)
		},
		carrier: {
			(($.E1EDL20.*E1ADRM1) filter ($.PARTNER_Q == "SP") map {
				primaryId: $.PARTNER_ID default ""
			})
		},
		shipTo: {
			(if ( ($.E1EDL20.E1EDL21.LFART == "LF") or ($.E1EDL20.E1EDL21.LFART == "NL") or ($.E1EDL20.E1EDL21.LFART == "NLCC") ) (($.E1EDL20.*E1ADRM1) filter ($.PARTNER_Q == "WE") map {
				primaryId: $.PARTNER_ID default ""
			})else if ( $.E1EDL20.E1EDL21.LFART == "EL" ) primaryId: $.E1EDL20.VSTEL default ""
						else primaryId: $.E1EDL20.VSTEL default "")
		},
		shipFrom: {
			(if ( ($.E1EDL20.E1EDL21.LFART == "LF") or ($.E1EDL20.E1EDL21.LFART == "NL") or ($.E1EDL20.E1EDL21.LFART == "NLCC") ) primaryId: $.E1EDL20.VSTEL default ""
						else if ( $.E1EDL20.E1EDL21.LFART == "EL" ) (($.E1EDL20.*E1ADRM1) filter ($.PARTNER_Q == "LF") map {
				primaryId: $.PARTNER_ID default ""
			})
						else 	primaryId: null)
		},
		transportInstructionTerms: {
			transportServiceCategoryType: "30"
		},
		transportCargoCharacteristics: {
			cargoTypeCode: "12"
		},
		plannedDelivery: {
			logisticEventPeriod: {
				(($.E1EDL20.*E1EDT13) filter ($.QUALF == "007") map {
					beginDate: globalDataweaveFunctions::formatDate($.NTANF default "")
				}),
				beginTime: "00:01:00",
				(($.E1EDL20.*E1EDT13) filter ($.QUALF == "007") map {
					endDate: globalDataweaveFunctions::formatDate($.NTANF default "")
				}),
				endTime: "23:59:00"
			},
			logisticEventDateTime: {
				(($.E1EDL20.*E1EDT13) filter ($.QUALF == "007") map {
					date: globalDataweaveFunctions::formatDate($.NTANF default ""),
					time: globalDataweaveFunctions::timeConversion($.NTANZ default "")
				})
			}
		},
		plannedDespatch: (if ( ($.E1EDL20.*E1EDT13 filter ($.QUALF == "006" and $.NTANF != "00000000"))[0] != null and ($.E1EDL20.*E1EDT13 filter ($.QUALF == "006" and $.NTANF != "00000000"))[0] != "" ) {
			logisticEventPeriod: {
				(($.E1EDL20.*E1EDT13) filter ($.QUALF == "006") map {
					beginDate: globalDataweaveFunctions::formatDate($.NTANF default "")
				}),
				beginTime: "00:00:00",
				(($.E1EDL20.*E1EDT13) filter ($.QUALF == "006") map {
					endDate: globalDataweaveFunctions::formatDate($.NTANF default "")
				}),
				endTime: "23:58:00"
			},
			logisticEventDateTime: {
				(($.E1EDL20.*E1EDT13) filter ($.QUALF == "006") map {
					date: globalDataweaveFunctions::formatDate($.NTANF default ""),
					time: globalDataweaveFunctions::timeConversion($.NTANZ default "")
				})
			}
		} else {
		}),
		deliveryTerms: {
			incotermsCode: $.E1EDL20.INCO1
		},
		transportReference: [{
			entityId: $.E1EDL20.BOLNR,
			(typeCode: "BM") if ($.E1EDL20.BOLNR != null and $.E1EDL20.BOLNR != "")
		}]
	}]
})