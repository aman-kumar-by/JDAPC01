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
output application/xml skipNullOn="everywhere", encoding="UTF-8"
import * from dw::core::Objects
fun extractValueSet(plantCompCodePurchOrgGrp : Object, plantKey : String) = valueSet((plantCompCodePurchOrgGrp) filterObject ((value, key, index) -> key startsWith plantKey))
---
{
	(p('inbound.planPurch.idocType')) : {
		(using(materialData = payload.plannedSupplyId.item.primaryId default "",
			plantData = payload.plannedSupplyId.shipTo.primaryId default "",
			quantityData = payload.plannedSupplyDetail.requestedQuantity.value default [],
			requestedDeliveryDate = payload.plannedSupplyDetail.requestedDeliveryDate default [],
			scheduledOnHandDate = payload.plannedSupplyDetail.scheduledOnHandDate default [],
			purchaseMethod = payload.plannedSupplyDetail.purchaseMethod default [],
			plantKey = payload.plannedSupplyId.shipTo.primaryId default "" ++ "-"
		) {
			(quantityData map
				 {
				IDOC @(BEGIN :"1") : {
					EDI_DC40 @(SEGMENT : "1") : {
						TABNAM : p('SAP.TABNAM'),
						MANDT : p('SAP.MANDT'),
						OUTMOD : p('SAP.OUTMOD'),
						IDOCTYP : p('SAP.IDOCTYP'),
						MESTYP : p('SAP.MESTYP'),
						SNDPOR : p('SAP.SNDPOR'),
						SNDPRT : p('SAP.SNDPRT'),
						SNDPRN : p('SAP.SNDPRN'),
						RCVPOR : p('SAP.RCVPOR'),
						RCVPRT : p('SAP.RCVPRT'),
						RCVPRN : p('SAP.RCVPRN')
					},
					E1BPEBANC @(SEGMENT : "1") : using(needDate = if(isEmpty(requestedDeliveryDate[$$])) 0 else requestedDeliveryDate[$$][0 to 3])  {
						DOC_TYPE: "NB",
						MATERIAL: materialData,
						PLANT: plantData,
						QUANTITY: $,
						DELIV_DATE: if(needDate as Number == 1970 or needDate as Number == 1900) scheduledOnHandDate[$$] as Date {format : "yyyy-MM-dd"} as String {format: "yyyyMMdd"} else requestedDeliveryDate[$$] as Date {format : "yyyy-MM-dd"} as String {format: "yyyyMMdd"},
						(DES_VENDOR: purchaseMethod[$$]) if (not isEmpty(purchaseMethod[$$])),
						(FIXED_VEND: purchaseMethod[$$]) if (not isEmpty(purchaseMethod[$$])),
						(PURCH_ORG : (extractValueSet(vars.plantCompCodePurchOrgGrp, plantKey)[0] splitBy ",")[0]) if (not isEmpty(extractValueSet(vars.plantCompCodePurchOrgGrp, plantKey))),
					}
				}
			})
		})
	}
}