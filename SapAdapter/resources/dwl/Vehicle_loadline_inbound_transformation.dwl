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
output application/xml encoding="UTF-8", skipNullOn = "everywhere"
var loadDataList = (payload.plannedSupply groupBy($.plannedSupplyId.transportLoadId default "" ++ 
       $.plannedSupplyId.shipTo.primaryId default "")) pluck $$
var loadData = (payload.plannedSupply groupBy($.plannedSupplyId.transportLoadId default "" ++ 
       $.plannedSupplyId.shipTo.primaryId default ""))
---
{
	(p('inbound.vehicleLoad.idocType')) : {
		(loadDataList map 
using (shipToData = loadData[$][0].plannedSupplyId.shipTo.primaryId,
	   shipFromData = loadData[$][0].plannedSupplyId.shipFrom.primaryId,
	   plantkey = loadData[$][0].plannedSupplyId.shipTo.primaryId default "" ++ '-' ++ loadData[$][0].plannedSupplyId.shipFrom.primaryId default "",
	   docType = (vars.plantCompCodePurchOrgGrp[plantkey] splitBy ",")[3]
	   	   
) {
			IDOC @(BEGIN : "1") : {
				EDI_DC40 @(SEGMENT : "1") : {
					TABNAM : p('SAP.TABNAM'),
					MANDT : p('SAP.MANDT'),
					OUTMOD : p('SAP.OUTMOD'),
					IDOCTYP : p('SAP.PA.IDOCTYP'),
					MESTYP : p('SAP.PA.MESTYP'),
					SNDPOR : p('SAP.SNDPOR'),
					SNDPRT : p('SAP.SNDPRT'),
					SNDPRN : p('SAP.SNDPRN'),
					RCVPOR : p('SAP.RCVPOR'),
					RCVPRT : p('SAP.RCVPRT'),
					RCVPRN : p('SAP.RCVPRN')
				},
				E1PORDCR1 @(SEGMENT : "1") : {
					E1BPMEPOHEADER @(SEGMENT : "1") : {
						COMP_CODE : (vars.plantCompCodePurchOrgGrp[plantkey] splitBy ",")[0],
						DOC_TYPE : docType,
						SUPPL_PLNT : shipFromData,
						PURCH_ORG : (vars.plantCompCodePurchOrgGrp[plantkey] splitBy ",")[1],
						PUR_GROUP : (vars.plantCompCodePurchOrgGrp[plantkey] splitBy ",")[2],
						((VENDOR : (vars.plantCompCodePurchOrgGrp[plantkey] splitBy ",")[4]) if(docType == 'NB'))
					},
					E1BPMEPOHEADERX @(SEGMENT : "1") : {
						COMP_CODE : "X",
						DOC_TYPE : "X",
						PURCH_ORG : "X",
						PUR_GROUP : "X",
						((SUPPL_PLNT : "X") if(not isEmpty(shipFromData))),
						((VENDOR : "X") if(docType == 'NB'))
					},
					(loadData[$] map (ldv, ldi) -> using (groupRecord = ldv) {
						(ldv.*plannedSupplyDetail map using (poitem = (((ldi + 1)*10) as String {format: "00000"})) {
							E1BPMEPOITEM @(SEGMENT : "1") : {
								PO_ITEM : poitem,
								MATERIAL : groupRecord.plannedSupplyId.item.primaryId,
								PLANT : shipToData,
								TRACKINGNO : groupRecord.plannedSupplyId.transportLoadId,
								QUANTITY : $.requestedQuantity.value,
								((ITEM_CAT : p('SAP.PA.ITEMCAT')) if(docType == 'UB'))
							},
							E1BPMEPOITEMX @(SEGMENT : "1") : {
								PO_ITEM : poitem,
								PO_ITEMX : "X",
								((MATERIAL : "X") if(not isEmpty(groupRecord.plannedSupplyId.item.primaryId))),
								((PLANT : "X") if(not isEmpty(shipToData))),
								TRACKINGNO : "X",
								QUANTITY : "X",
								((ITEM_CAT : "X") if(docType == 'UB'))
							},
							E1BPMEPOSCHEDULE @(SEGMENT : "1") : {
								PO_ITEM : poitem,
								SCHED_LINE : "0001",
								((DELIVERY_DATE : $.requestedDeliveryDate as Date {format: 'yyyy-MM-dd'} as String {format: 'yyyyMMdd'}) if(not isEmpty($.requestedDeliveryDate))),
								QUANTITY : $.requestedQuantity.value
							},
							E1BPMEPOSCHEDULX @(SEGMENT : "1") : {
								PO_ITEM : poitem,
								SCHED_LINE : "0001",
								PO_ITEMX : "X",
								((DELIVERY_DATE : "X") if(not isEmpty($.requestedDeliveryDate))),
								QUANTITY : "X"
							}
						})
					})
				}
			}
		})
	}
}