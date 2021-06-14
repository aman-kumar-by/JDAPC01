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
output application/json encoding="UTF-8",skipNullOn="everywhere"
import lookup_utils::globalDataweaveFunctions
---
(payload.*IDOC default [] map (idoc, index) -> {
			creationDateTime: now() as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"},
			documentStatusCode: "ORIGINAL",
			documentActionCode : "CHANGE_BY_REFRESH",
			senderDocumentId : idoc.EDI_DC40.IDOCTYP ++ '-' ++ idoc.EDI_DC40.DOCNUM,
			itemId : {
				primaryId : idoc.E1KOMG.MATNR
			},
			financialInformation : {
				(unitCost : {
					value : (idoc.E1KOMG.E1KONH.E1KONP.KBETR default 0) as Number,
					currencyCode : idoc.E1KOMG.E1KONH.E1KONP.KONWA
				}) if (((now() as Date {format: "yyyy-MM-dd"}) >= globalDataweaveFunctions::formatDate(idoc.E1KOMG.E1KONH.DATAB default '')) and ((now() as Date {format: "yyyy-MM-dd"}) <= globalDataweaveFunctions::formatDate(idoc.E1KOMG.E1KONH.DATBI default '')) and (idoc.E1KOMG.E1KONH.E1KONP.KSCHL == 'VKP2')),
				(unitRetailPrice : {
					value : (idoc.E1KOMG.E1KONH.E1KONP.KBETR default 0) as Number,
					currencyCode : idoc.E1KOMG.E1KONH.E1KONP.KONWA
				}) if (((now() as Date {format: "yyyy-MM-dd"}) >= globalDataweaveFunctions::formatDate(idoc.E1KOMG.E1KONH.DATAB default '')) and ((now() as Date {format: "yyyy-MM-dd"}) <= globalDataweaveFunctions::formatDate(idoc.E1KOMG.E1KONH.DATBI default '')) and (idoc.E1KOMG.E1KONH.E1KONP.KSCHL == 'VKP0'))
			}
})