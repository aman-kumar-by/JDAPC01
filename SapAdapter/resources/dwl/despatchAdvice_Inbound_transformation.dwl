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
					(despatchAdvice distinctBy ($.logisticUnitId.primaryId) filter ($.levelId == 3 and ($.logisticUnitId.primaryId == d.parentLogisticUnitId)) map (l3, ss) -> {
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
								level3id : l3.logisticUnitId.primaryId,
								packTrackingNumber : l3.packageTrackingNumber,
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
		E1EDL37 : {
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
		E1EDL37 : {
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
	(if (noTLFlag == true) (p('SAP.DESADV.IDOCTYP')) : {
		(flatten(desAdvLinenoTL.deapatchLine.*record) groupBy($.VBELN) mapObject (v,b) -> using (
            fTag = v.tag
        ) {
			IDOC : {
				EDI_DC40: {
					IDOCTYP: p('SAP.DESADV.IDOCTYP'),
					MESTYP: p('SAP.DESADV.MESTYP'),
					SNDPOR: p('SAP.SNDPOR'),
					SNDPRT: p('SAP.SNDPRT'),
					SNDPRN: p('SAP.SNDPRN'),
					RCVPOR: p('SAP.RCVPOR'),
					RCVPRT: p('SAP.RCVPRT'),
					RCVPRN: p('SAP.RCVPRN'),
					DIRECT: 2
				},
				E1EDL20 : {
					VBELN : leftPad((v.VBELN)[0],10,0),
					BOLNR : (payload.despatchAdvice.despatchAdviceTransportInformation.billOfLadingNumber.entityId),
					TRAID : (payload.despatchAdvice.despatchAdviceTransportInformation.transportLoadId)[0],
					E1EDL18 : {
						QUALF : "CHG"
					},
					E1EDL18 : {
						QUALF : "PIC"
					},
					(v.*E1EDL24 distinctBy ($.POSNR as String ++ $.ent as String) map (c,v) -> {
						E1EDL24 : {
							POSNR : leftPad(c.POSNR,6,0),
							MATNR : (c.MATNR)[0],
							CHARG : c.CHARG,
							(payload.despatchAdvice.shipment.*lineItem map (shipLine, shipLineIndx) -> {
								(shipLine map(shipQty,shipQtyIndx) -> using (shipLine = shipQty.customerReference.lineItemNumber as String,
                      shipId = shipQty.customerReference.entityId) {
									(if ((shipLine == c.POSNR as String) and (shipId == c.ent)) {
										LGMNG : shipQty.despatchedQuantity.value,
										E1EDL19 : {
											QUALF : (if ((shipQty.despatchedQuantity.value default 0) != 0) "QUA" else "DEL")
										}
									} else {
									})
								})
							})
						}
					}),
					((desAdvQtynoTL.despatchAdvQty.*E1EDL37 map (z,u) -> {
						(E1EDL37 : {
							EXIDV : '\$' ++ (u + 1),
							VHILM : (((payload.despatchAdvice.avpList)[0] filter ($.name == "packagingMaterial")).value)[0],
							EXIDV2 : (z.levPrimId)[0],
							VHILM_KU : (z.trackNum)[0],
							(z.*E1EDL44 map (ds,dc) -> {
								(fTag distinctBy ($) filter ($ == ds.tag) map (ff,gg) -> {
									E1EDL44 : {
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
						(e3.*E1EDL37 filter ($.E1EDL44 != null) map (e33,e44) -> {
							E1EDL37 : (e33)
						})
					})
				}
			}
		})
	} else (p('SAP.DESADV.IDOCTYP')) : {
		(flatten(desAdvLine.deapatchLine.*record) groupBy($.VBELN) mapObject (v,b) -> using (
            fTag = v.tag
        ) {
			IDOC : {
				EDI_DC40: {
					IDOCTYP: p('SAP.DESADV.IDOCTYP'),
					MESTYP: p('SAP.DESADV.MESTYP'),
					SNDPOR: p('SAP.SNDPOR'),
					SNDPRT: p('SAP.SNDPRT'),
					SNDPRN: p('SAP.SNDPRN'),
					RCVPOR: p('SAP.RCVPOR'),
					RCVPRT: p('SAP.RCVPRT'),
					RCVPRN: p('SAP.RCVPRN'),
					DIRECT: 2
				},
				E1EDL20 : {
					VBELN : leftPad((v.VBELN)[0],10,0),
					BOLNR : (payload.despatchAdvice.despatchAdviceTransportInformation.billOfLadingNumber.entityId),
					TRAID : (payload.despatchAdvice.despatchAdviceTransportInformation.transportLoadId)[0],
					E1EDL18 : {
						QUALF : "CHG"
					},
					E1EDL18 : {
						QUALF : "PIC"
					},
					(v.*E1EDL24 distinctBy ($.POSNR as String ++ $.ent as String) map (c,v) -> {
						E1EDL24 : {
							POSNR : leftPad(c.POSNR,6,0),
							MATNR : (c.MATNR)[0],
							CHARG : c.CHARG,
							(payload.despatchAdvice.shipment.*lineItem map (shipLine, shipLineIndx) -> {
								(shipLine map(shipQty,shipQtyIndx) -> using (shipLine = shipQty.customerReference.lineItemNumber as String,
                      shipId = shipQty.customerReference.entityId) {
									(if ((shipLine == c.POSNR as String) and (shipId == c.ent)) {
										LGMNG : shipQty.despatchedQuantity.value,
										E1EDL19 : {
											QUALF : (if ((shipQty.despatchedQuantity.value default 0) != 0) "QUA" else "DEL")
										}
									} else {
									})
								})
							})
						}
					}),
					((desAdvQty.despatchAdvQty.*E1EDL37 map (z,u) -> {
						(E1EDL37 : {
							EXIDV : '\$' ++ (u + 1),
							VHILM : (((payload.despatchAdvice.avpList)[0] filter ($.name == "packagingMaterial")).value)[0],
							EXIDV2 : (z.levPrimId)[0],
							VHILM_KU : payload.despatchAdvice.shipment.proNumber.entityId,
							(z.*E1EDL44 map (ds,dc) -> {
								(fTag distinctBy ($) filter ($ == ds.tag) map (ff,gg) -> {
									E1EDL44 : {
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
						(e3.*E1EDL37 filter ($.E1EDL44 != null) map (e33,e44) -> {
							E1EDL37 : (e33)
						})
					})
				}
			}
		})
	} )
}
