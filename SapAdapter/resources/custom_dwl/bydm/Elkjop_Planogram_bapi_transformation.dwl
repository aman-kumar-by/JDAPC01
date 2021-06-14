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
    (
        (p('inbound.planogram.bapiType')) : {
            (payload.planogram default [] map {
                (LIST_CHECK:  "X") if ($.dBStatus == "2"),
                (LISTING_EXECUTE: "X") if ($.dBStatus == "2"),
                LIST_ST_FR: $.dBDateTimeEffectiveFrom,
                PLACEMENT_DATA: 'X',
                MATERIAL_MEASURES: '',
                LAYOUT_CHECK: 'X',
                bapi_fix_asgmt : {
                    LAYMOD_MOD: $.avpList[?($.name == "DESC1")].value[0],
                    LAYMOD_VER: $.avpList[?($.name == "DESC2")].value[0]
                },
                MATERIAL : $.planogramProduct[0].productIdentification as Number,
                UNIT : $.planogramProduct[0].avpList[?($.name == "DESC3")].value[0],
                SHELF_BOARD_NUMBER : "0",
                SHORT_SEQ : "0",
                FIXTURE  : $.planogramFixture[0].dBKey,
                FIX_CAPACITY  : $.planogramFixture[0].cubicSpace,
                DIM_FIX_CAPACITY  : "cm3",
                FIXTURE_SEQUENCE : $.planogramFixture[0].locationIdentification,
                SHELF_QUANTITY_MAX  : $.planogramPerformance[0].maximumReplenishmentUnits,
                PRES_QNT : $.planogramPerformance[0].minimumReplenishmentUnits
            })
        }
    )
}