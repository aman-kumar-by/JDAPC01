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
/* This lookup is used to get custom dwl path dynamically.
 * Use "ENTITY" name as key and custom dwl path as value.
 * If custom dwl path is not set here, core dwl be executed.
 */
%dw 2.0
output application/json
---
customBYDMDwlPath : {
	"CUSMASLOCIDOC": "custom_dwl/bydm/Elkjop_Stores_Site_Location_IDOC_transformation.dwl",
	"RETITEMIDOC" : "custom_dwl/bydm/Elkjop_Items_Retail_Article_IDOC_transformation.dwl",
	"PRODHIERIDOC": "custom_dwl/bydm/Elkjop_ItemHierarchy_IDOC_transformation.dwl",
	"ITEMPRICEIDOC" : "custom_dwl/bydm/Elkjop_ItemPrice_IDOC_transformation.dwl",
	"PLANOGRAM" : "custom_dwl/bydm/Elkjop_Planogram_bapi_transformation.dwl"
}