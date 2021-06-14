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
---
{ 
  (payload map {
	creationDateTime: now() as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
	documentStatusCode: "ORIGINAL",
	documentActionCode: "CHANGE_BY_REFRESH",
	purchaseMethodId : {
		item : {
			primaryId : $.MATNR
		},
		location : {
			primaryId : $.WERKS
		},
		purchaseMethod : $.LIFNR
	},
	purchaseGroup : $.EKGRP,
	isSupplierApproved : (($.VENAPR default "") == "X"),
	(if ($.WAERS != "" and $.WAERS != null) purchaseCost : {
		value : $.NETPR as Number,
		currencyCode : $.WAERS
	} else {
	}),
	incrementalOrderQuantity: {
		(value: (trim($.BSTRF)) as Number) if ($.BSTRF != null)
	// measurementUnitCode: GRM
	},
	(if ($.MEINS != "" and $.MEINS != null) maximumOrderQuantity : {
		value : (trim($.BSTMA)) as Number,
		measurementUnitCode : vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""]
	} else {
	}),
	(if ($.MEINS != "" and $.MEINS != null) minimumOrderQuantity : {
		value : (trim($.MINBM)) as Number,
		measurementUnitCode : vars.uomCodeMap.measurementUnitCodeMap[$.MEINS default ""]
	} else {
	}),
	replenishLeadDuration: {
		value: $.APLFZ as Number,
		timeMeasurementUnitCode : "DAY"
	},
	purchaseMethodPercentage : {
		effectiveFromDate : ((if ((!isEmpty($.VDATU)) and (sizeOf($.VDATU) == 8) and $.VDATU !='00000000') $.VDATU 
					else if ((!isEmpty($.SVDATU)) and (sizeOf($.SVDATU ) == 8) and $.SVDATU !='00000000' ) $.SVDATU
					else if ((!isEmpty($.PVDATU)) and (sizeOf($.PVDATU ) == 8) and $.PVDATU !='00000000') $.PVDATU
					else p('default.date.effectiveDate')) as Date {format: 'yyyyMMdd'} as String {format: 'yyyy-MM-dd'}),
		effectiveUpToDate : ((if ((!isEmpty($.BDATU)) and (sizeOf($.BDATU) == 8) and $.BDATU !='00000000') (if ($.BDATU == '99991231') $.BDATU as Date {format : "yyyyMMdd"} else $.BDATU as Date {format : "yyyyMMdd"} + |P1D|)
					else if ((!isEmpty($.SBDATU)) and (sizeOf($.SBDATU) == 8) and $.SBDATU !='00000000') (if ($.SBDATU == '99991231') $.SBDATU as Date {format : "yyyyMMdd"} else $.SBDATU as Date {format : "yyyyMMdd"} + |P1D|)
					else if ((!isEmpty($.PBDATU)) and (sizeOf($.PBDATU) == 8) and $.PBDATU !='00000000') (if ($.PBDATU == '99991231') $.PBDATU as Date {format : "yyyyMMdd"} else $.PBDATU as Date {format : "yyyyMMdd"} + |P1D|)
					else p('default.date.effectiveDate')) as Date {format: 'yyyyMMdd'} as String {format: 'yyyy-MM-dd'}),
		priority: $.PREIH as Number,
		demandPercentage : trim($.QUOTE) as Number
	}
  })
}