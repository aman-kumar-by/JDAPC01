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
output application/json encoding="UTF-8", skipNullOn="everywhere"
import lookup_utils::globalDataweaveFunctions
---
 {      (payload default [] map (dmdGroupFileds, index) -> {
            creationDateTime :  now() as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
            documentStatusCode : "ORIGINAL", 
            documentActionCode : "CHANGE_BY_REFRESH", 
            demandChannelId : globalDataweaveFunctions::demandChannelChk(dmdGroupFileds.VKORG default "" ++ p('sap.demandChannel.delimiter') ++ dmdGroupFileds.VTWEG default ""),        
			description : {
				value: dmdGroupFileds.VTEXT_SO ++ p('sap.demandChannel.delimiter') ++ dmdGroupFileds.VTEXT_DC
			},
            demandChannelIdComponents :"VKORG,VTWEG",  
			componentDelimiter : p('sap.demandChannel.delimiter'), 
            }
 
      )
}