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
---
{
	(p('inbound.planArrival.idocType')) : using (supplyPlant = payload.plannedSupplyId.shipFrom.primaryId default "",
              		material = payload.plannedSupplyId.item.primaryId default "",
                    plant = payload.plannedSupplyId.shipTo.primaryId default "",
                    plantkey = payload.plannedSupplyId.shipTo.primaryId default "" ++ '-' ++ payload.plannedSupplyId.shipFrom.primaryId default "",
                    quantityData = payload.plannedSupplyDetail[0].requestedQuantity.value,
                    deliveryDate = payload.plannedSupplyDetail[0].requestedDeliveryDate default ""
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
					DOC_TYPE : (vars.plantCompCodePurchOrgGrp[plantkey] splitBy ",")[3],
					SUPPL_PLNT : supplyPlant,
					PURCH_ORG : (vars.plantCompCodePurchOrgGrp[plantkey] splitBy ",")[1],
					PUR_GROUP : (vars.plantCompCodePurchOrgGrp[plantkey] splitBy ",")[2],
					((VENDOR : (vars.plantCompCodePurchOrgGrp[plantkey] splitBy ",")[4]) if ((vars.plantCompCodePurchOrgGrp[plantkey] splitBy ",")[3] == 'NB'))
				},
				E1BPMEPOHEADERX @(SEGMENT : "1") : {
					COMP_CODE : "X",
					DOC_TYPE : "X",
					PURCH_ORG : "X",
					PUR_GROUP : "X",
					((SUPPL_PLNT : "X") if (not isEmpty(supplyPlant))),
					((VENDOR : "X") if ((vars.plantCompCodePurchOrgGrp[plantkey] splitBy ",")[3] == 'NB'))
				},
				E1BPMEPOITEM @(SEGMENT : "1") : {
					PO_ITEM : p('SAP.PA.POITEM'),
					MATERIAL : material,
					PLANT : plant,
					TRACKINGNO : if (not isEmpty(payload.additionalReferenceInformation)) payload.additionalReferenceInformation else ("BY" ++ ((floor(random() * 10000000) as String {format: "########"}) as Number) + 10000000),
					QUANTITY : quantityData,
					((ITEM_CAT : p('SAP.PA.ITEMCAT')) if ((vars.plantCompCodePurchOrgGrp[plantkey] splitBy ",")[3] == 'UB'))
				},
				E1BPMEPOITEMX @(SEGMENT : "1") : {
					PO_ITEM : p('SAP.PA.POITEM'),
					PO_ITEMX : "X",
					((MATERIAL : "X") if (not isEmpty(material))),
					((PLANT : "X") if (not isEmpty(plant))),
					TRACKINGNO : "X",
					((QUANTITY : "X") if (not isEmpty(quantityData))),
					((ITEM_CAT : "X") if ((vars.plantCompCodePurchOrgGrp[plantkey] splitBy ",")[3] == 'UB'))
				},
				E1BPMEPOSCHEDULE @(SEGMENT : "1") : {
					PO_ITEM : p('SAP.PA.POITEM'),
					SCHED_LINE : p('SAP.PA.SCHEDLINE'),
					((DELIVERY_DATE : deliveryDate as Date {format: 'yyyy-MM-dd'} as String {format: 'yyyyMMdd'}) if (not isEmpty(deliveryDate))),
					QUANTITY : quantityData
				},
				E1BPMEPOSCHEDULX @(SEGMENT : "1") : {
					PO_ITEM : p('SAP.PA.POITEM'),
					SCHED_LINE : p('SAP.PA.SCHEDLINE'),
					PO_ITEMX : "X",
					((DELIVERY_DATE : "X") if (not isEmpty(deliveryDate))),
					((QUANTITY : "X") if (not isEmpty(quantityData)))
				}
			}
		}
	}
}