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
var csvCol = "itemId,demandChannel,locationId,transactionCode,startDate,quantity.value,quantity.measurementUnitCode" splitBy  ","
output application/csv encoding="UTF-8"
import lookup_utils::globalDataweaveFunctions
---
		
(payload pluck $$) map using (data1 = $ splitBy "_88_") {
    (csvCol[0]) : data1[1] default "",
    (csvCol[1]) : data1[6] as String default "",
    (csvCol[2]) : data1[3] default "",
    (csvCol[3]) : if (data1[2] == 'J') "142" else if(data1[2] == 'T') "141" else data1[2],
    (csvCol[4]) : globalDataweaveFunctions::formatDate(data1[4] default ""),
    (csvCol[5]) : payload[$].quantity default "",
    (csvCol[6]) : if(not isEmpty(vars.uomCodeMap.measurementUnitCodeMap[data1[5] default ""])) vars.uomCodeMap.measurementUnitCodeMap[data1[5]] else data1[5] default "",
}
	
