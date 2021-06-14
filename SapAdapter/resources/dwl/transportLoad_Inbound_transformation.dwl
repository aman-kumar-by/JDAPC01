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
output application/xml
import * from dw::core::Strings
var noTLFlag = ((payload.despatchAdvice.load.logisticServiceRequirementCode)[0] == "4")
var desAdvLine = {
	"deapatchLine": {
		(payload.despatchAdvice.*despatchAdviceLogisticUnit map(despatchAdvice, DAIndex) -> {
			(despatchAdvice filter ($.levelId == 4) map (d,s) -> using (
    primId = d.parentLogisticUnitId
    ) {
				(flatten(d.*lineItem) groupBy ($.customerReference.entityId) mapObject (l,m) -> using (
        lined = (l.customerReference.lineItemNumber)[0] as String,
        entityd = (l.customerReference.entityId)[0] as String,
        tagg = primId ++ lined ++ entityd,
        qty = sum(l.despatchedQuantity.value)
    ) {
					(despatchAdvice filter ($.levelId == 3 and ($.logisticUnitId.primaryId == d.parentLogisticUnitId)) map (l3, ss) -> {
						(despatchAdvice distinctBy ($.logisticUnitId.primaryId) filter ($.levelId == 2 and ($.logisticUnitId.primaryId == l3.parentLogisticUnitId)) map (l2, sks) -> {
							record : {
								level4id : primId,
								level3id : l3.logisticUnitId.primaryId,
								level3id : l2.logisticUnitId.primaryId,
								line : lined,
								VBELN : entityd,
								Quantity : qty,
								tag : l2.logisticUnitId.primaryId ++ lined ++ entityd,
								E1EDL24 : {
									MATNR : (l.transactionalTradeItem.primaryId),
									POSNR : lined,
									ent : entityd,
									CHARG : l.transactionalTradeItem.transactionalItemData.lotNumber,
									LGMNG : (l.despatchedQuantity.value)[0],
									E1EDL19 : {
										QUALF : (if ((l.despatchedQuantity.value default 0) != 0) "QUA" else "DEL"),
									}
								}
							}
						})
					})
				})
			})
		})
	}
}
var desAdvLinenoTL = {
	"deapatchLine": {
		(payload.despatchAdvice.*despatchAdviceLogisticUnit map(despatchAdvice, DAIndex) -> {
			(despatchAdvice filter ($.levelId == 4) map (d,s) -> using (
    primId = d.parentLogisticUnitId
    ) {
				(flatten(d.*lineItem) groupBy ($.customerReference.entityId) mapObject (l,m) -> using (
        lined = (l.customerReference.lineItemNumber)[0] as String,
        entityd = (l.customerReference.entityId)[0] as String,
        tagg = primId ++ lined ++ entityd,
        qty = sum(l.despatchedQuantity.value)
    ) {
					(despatchAdvice filter ($.levelId == 3 and ($.logisticUnitId.primaryId == d.parentLogisticUnitId)) map (l3, ss) -> {
							record : {
								level4id : primId,
								level3id : l3.logisticUnitId.primaryId,
								//level2id : l2.logisticUnitId.primaryId,
								line : lined,
								VBELN : entityd,
								Quantity : qty,
								tag : l3.logisticUnitId.primaryId ++ lined ++ entityd,
								E1EDL24 : {
									MATNR : (l.transactionalTradeItem.primaryId),
									POSNR : lined,
									ent : entityd,
									CHARG : l.transactionalTradeItem.transactionalItemData.lotNumber,
									LGMNG : (l.despatchedQuantity.value)[0]
								}
							}
					})
				})
			})
		})
	}
}
var desLPN = {
	"despatchLPN": {
		(payload.despatchAdvice.*despatchAdviceLogisticUnit map(despatchAdvice, DAIndex) -> {
			(despatchAdvice filter ($.levelId == 4) map (d,s) -> using (
    primId = d.parentLogisticUnitId
    ) {
				(flatten(d.*lineItem) groupBy ($.customerReference.entityId) mapObject (l,m) -> using (
        lined = (l.customerReference.lineItemNumber)[0],
        entityd = (l.customerReference.entityId)[0],
        tagg = primId ++ lined ++ entityd,
        qty = sum(l.despatchedQuantity.value)
    ) {
					(despatchAdvice filter ($.levelId == 3 and ($.logisticUnitId.primaryId == d.parentLogisticUnitId)) map (l3, ss) -> {
						(despatchAdvice distinctBy ($.logisticUnitId.primaryId) filter ($.levelId == 2 and ($.logisticUnitId.primaryId == l3.parentLogisticUnitId)) map (l2, sks) -> {
							details : {
								level4id : primId,
								level3id : l3.logisticUnitId.primaryId,
								level2id : l2.logisticUnitId.primaryId,
								line : lined,
								entity : entityd,
								Quantity : qty,
								tag : l2.logisticUnitId.primaryId ++ lined ++ entityd,
								MATNR : (l.transactionalTradeItem.primaryId)[0]
							}
						})
					})
				})
			})
		})
	}
}
var desLPNnoTL = {
	"despatchLPN": {
		(payload.despatchAdvice.*despatchAdviceLogisticUnit map(despatchAdvice, DAIndex) -> {
			(despatchAdvice filter ($.levelId == 4) map (d,s) -> using (
    primId = d.parentLogisticUnitId
    ) {
				(flatten(d.*lineItem) groupBy ($.customerReference.entityId) mapObject (l,m) -> using (
        lined = (l.customerReference.lineItemNumber)[0],
        entityd = (l.customerReference.entityId)[0],
        tagg = primId ++ lined ++ entityd,
        qty = sum(l.despatchedQuantity.value)
    ) {
					(despatchAdvice distinctBy ($.logisticUnitId.primaryId) filter ($.levelId == 3 and ($.logisticUnitId.primaryId == d.parentLogisticUnitId)) map (l3, ss) -> {
							details : {
								level4id : primId,
								packTrackingNumber : l3.packageTrackingNumber,
								level3id : l3.logisticUnitId.primaryId,
								//level2id : l2.logisticUnitId.primaryId,
								line : lined,
								entity : entityd,
								Quantity : qty,
								tag : l3.logisticUnitId.primaryId ++ lined ++ entityd,
								MATNR : (l.transactionalTradeItem.primaryId)[0]
							}
					})
				})
			})
		})
	}
}
var desAdvQty = despatchAdvQty : {
	(desLPN.despatchLPN.*details groupBy ($.level2id) mapObject(f,v) -> using (l2Id = f.level2id) {
		E1EDT37 : {
			levPrimId : l2Id,
			(f groupBy($.tag) mapObject (g,l) -> {
				E1EDL44 : {
					Quant : sum(g.Quantity),
					tag : (g.tag)[0],
					line : g.line,
					levelid2 : (g.level2id),
					entity : (g.entity)[0],
					MATNR : (g.MATNR)[0]
				}
			})
		}
	})
}
var desAdvQtynoTL = despatchAdvQty : {
	(desLPNnoTL.despatchLPN.*details groupBy ($.level3id) mapObject(f,v) -> using (l2Id = f.level3id, packTraNum = f.packTrackingNumber) {
		E1EDT37 : {
			levPrimId : l2Id,
			trackNum : packTraNum,
			(f groupBy($.tag) mapObject (g,l) -> {
				E1EDL44 : {
					Quant : sum(g.Quantity),
					tag : (g.tag)[0],
					line : g.line,
					levelid3 : (g.level3id),
					entity : (g.entity)[0],
					MATNR : (g.MATNR)[0]
				}
			})
		}
	})
}
---
{
	
	(if (noTLFlag == true) (p('SAP.TLINB.IDOCTYP')) : {
			IDOC : {
				EDI_DC40: {
					IDOCTYP: p('SAP.TLINB.IDOCTYP'),
					MESTYP: p('SAP.TLINB.MESTYP'),
					SNDPOR: p('SAP.SNDPOR'),
					SNDPRT: p('SAP.SNDPRT'),
					SNDPRN: p('SAP.SNDPRN'),
					RCVPOR: p('SAP.RCVPOR'),
					RCVPRT: p('SAP.RCVPRT'),
					RCVPRN: p('SAP.RCVPRN'),
					DIRECT: 2
				},
				E1EDT20 : {
					TKNUM : (payload.despatchAdvice.despatchAdviceTransportInformation.transportLoadId)[0],
					EXTI1 : (payload.despatchAdvice.shipment.shipmentId)[0],
					EXTI2 : (payload.despatchAdvice.despatchAdviceLogisticUnit)[0].packageTrackingNumber,
					E1EDT18 : {
						QUALF : "PID",
						PARAM : "TKNUM"
					},
					E1EDT18 : {
						QUALF : "CHA"
					},
					E1ADRM4 : {
						PARTNER_Q : "OTP",
						E1ADRE4 : {
						EXTEND_Q : "305",
						EXTEND_D : vars.transportCodeMap[(((payload.despatchAdvice.despatchAdviceLogisticUnit)[0].lineItem)[0].itemOwner.primaryId)[0]]
						}
					},
					E1EDT10 : {
					QUALF : "004",
					ISDD : (payload.despatchAdvice.despatchInformation.actualShipDateTime)[0] as DateTime  as String {format : "yyyy-MM-dd"},
					ISDZ : (payload.despatchAdvice.despatchInformation.actualShipDateTime)[0] as DateTime  as String {format : "hh:mm:ss"}
					},
					(flatten(desAdvLinenoTL.deapatchLine.*record) groupBy($.VBELN) mapObject (v,b) -> using (
            fTag = v.tag
        ) {
					((desAdvQtynoTL.despatchAdvQty.*E1EDT37 map (z,u) -> {
						(E1EDT37 : {
							EXIDV : '\$' ++ (u + 1),
							VHILM : (((payload.despatchAdvice.avpList)[0] filter ($.name == "packagingMaterial")).value)[0],
							EXIDV2 : (z.levPrimId)[0],
							VHILM_KU : (z.trackNum)[0],
							(z.*E1EDL44 map (ds,dc) -> {
								(fTag distinctBy ($) filter ($ == ds.tag) map (ff,gg) -> {
									E1EDT43 : {
										VELIN : "1",
										VBELN : leftPad(ds.entity,10,0),
										POSNR : leftPad((ds.line)[0],6,0),
										EXIDV : '\$' ++ (u + 1),
										VEMNG : ds.Quant,
										MATNR : ds.MATNR
									}
								})
							})
						}) 
					}) map (e3,e4) -> {
						(e3.*E1EDT37 filter ($.E1EDT43 != null) map (e33,e44) -> {
							E1EDT37 : (e33)
						})
					})
					})
				}
			}
		
	} else {
	(p('SAP.TLINB.IDOCTYP')) : {
		
			IDOC : {
				EDI_DC40: {
					IDOCTYP: p('SAP.TLINB.IDOCTYP'),
					MESTYP: p('SAP.TLINB.MESTYP'),
					SNDPOR: p('SAP.SNDPOR'),
					SNDPRT: p('SAP.SNDPRT'),
					SNDPRN: p('SAP.SNDPRN'),
					RCVPOR: p('SAP.RCVPOR'),
					RCVPRT: p('SAP.RCVPRT'),
					RCVPRN: p('SAP.RCVPRN'),
					DIRECT: 2
				},
				E1EDT20 : {
					TKNUM : (payload.despatchAdvice.despatchAdviceTransportInformation.transportLoadId)[0],
					EXTI1 : (payload.despatchAdvice.shipment.shipmentId)[0],
					EXTI2 : (payload.despatchAdvice.despatchAdviceLogisticUnit)[0].packageTrackingNumber,
					E1EDT18 : {
						QUALF : "PID",
						PARAM : "TKNUM"
					},
					E1EDT18 : {
						QUALF : "CHA"
					},
					E1ADRM4 : {
						PARTNER_Q : "OTP",
						E1ADRE4 : {
						EXTEND_Q : "305",
						EXTEND_D : vars.transportCodeMap[(((payload.despatchAdvice.despatchAdviceLogisticUnit)[0].lineItem)[0].itemOwner.primaryId)[0]]
						}
					},
					E1EDT10 : {
					QUALF : "004",
					ISDD : (payload.despatchAdvice.despatchInformation.actualShipDateTime)[0] as DateTime  as String {format : "yyyy-MM-dd"},
					ISDZ : (payload.despatchAdvice.despatchInformation.actualShipDateTime)[0] as DateTime  as String {format : "hh:mm:ss"}
					},
					(flatten(desAdvLine.deapatchLine.*record) groupBy($.VBELN) mapObject (v,b) -> using (fTag = v.tag
        ) {
					((desAdvQty.despatchAdvQty.*E1EDT37 map (z,u) -> {
						(E1EDT37 : {
							EXIDV : '\$' ++ (u + 1),
							VHILM : (((payload.despatchAdvice.avpList)[0] filter ($.name == "packagingMaterial")).value)[0],
							EXIDV2 : (z.levPrimId)[0],
							VHILM_KU : payload.despatchAdvice.shipment.proNumber.entityId,
							(z.*E1EDL44 map (ds,dc) -> {
								(fTag distinctBy ($) filter ($ == ds.tag) map (ff,gg) -> {
									E1EDT43 : {
										VELIN : "1",
										VBELN : leftPad(ds.entity,10,0),
										POSNR : leftPad((ds.line)[0],6,0),
										EXIDV : '\$' ++ (u + 1),
										VEMNG : ds.Quant,
										MATNR : ds.MATNR
									}
								})
							})
						}) 
					}) map (e3,e4) -> {
						(e3.*E1EDT37 filter ($.E1EDT43 != null) map (e33,e44) -> {
							E1EDT37 : (e33)
						})
					})})
					
				}
			}
	
	}
	})
}

