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
---
root : {
	(payload.plannedSupply default [] map 
              using(materialData = $.plannedSupplyId.item.primaryId default "",
                     plantData = $.plannedSupplyId.shipTo.primaryId default "",
                     plannedSupplyDetail = $.plannedSupplyDetail                    
              ) {
		(plannedSupplyDetail map {
			(p('inbound.plannedOrder.bapiType')) : {
				"import" : {
					HEADERDATA : {
						PLDORD_PROFILE: "LA",
						MATERIAL: materialData,
						PLAN_PLANT: plantData,
						PROD_PLANT: plantData,
						TOTAL_PLORD_QTY: $.requestedQuantity.value,
						ORDER_START_DATE: $.productionInformation.productionStartDate,
						ORDER_FIN_DATE: $.scheduledOnHandDate,
						FIRMING_IND: $.isFirmPlannedSupply default "",
						(VERSION : if (sizeOf($.productionInformation.productionRoutingId) >= 4) $.productionInformation.productionRoutingId[0 to 3] else $.productionInformation.productionRoutingId) if (not isEmpty ($.productionInformation.productionRoutingId))
					}
				},
				/*tables : {
					COMPONENTSDATA : {
						row : {
							PLANT: plantData,
							MATERIAL: materialData,
							ENTRY_QTY: $.requestedQuantity.value
						}
					}
				}*/
			}
		})
	})
}