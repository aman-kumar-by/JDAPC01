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
var csvCol = "PO_NUMBER,COMP_CODE,DOC_TYPE,CREAT_DATE,VENDOR,PURCH_ORG,PUR_GROUP,CURRENCY,DOC_DATE,REF_1,PO_ITEM,SHORT_TEXT,PLANT,MATL_GROUP,QUANTITY,PO_UNIT_ISO,NET_PRICE,PRICE_UNIT,ACCTASSCAT,COSTCENTER" splitBy  ","
output application/csv
import * from dw::core::Strings
---
payload.generalLedger map (record,index) -> {
	(csvCol[0]) : (if (record.generalLedgerTransaction.transactionCategory[0] default "" contains "REVERSED") "REVERSED" else ""),
	(csvCol[1]) : (if (record.generalLedgerTransaction.organisationName[0] != "" and record.generalLedgerTransaction.organisationName[0] != null) record.generalLedgerTransaction.organisationName[0] else "1000"),
	(csvCol[2]) : "NB",
	(csvCol[3]) : record.creationDateTime  as DateTime  as String {format : "dd.MM.yyyy"},
	(csvCol[4]) : leftPad(record.generalLedgerTransaction.accountParty.primaryId[0],10,0),
	(csvCol[5]) : "1000",
	(csvCol[6]) : "001",
	(csvCol[7]) : record.generalLedgerTransaction.amount.currencyCode[0],
	(csvCol[8]) : record.creationDateTime as DateTime  as String {format : "dd.MM.yyyy"},
	(csvCol[9]) : record.generalLedgerTransaction.generalLedgerTransactionId[0],
	(csvCol[10]) : "00010",
	(csvCol[11]) : "FREIGHT SETTLEMENT",
	(csvCol[12]) : "1000",
	(csvCol[13]) : "007",
	(csvCol[14]) : "1",
	(csvCol[15]) : "PCE",
	(csvCol[16]) : record.generalLedgerTransaction.amount.value[0],
	(csvCol[17]) : "1",
	(csvCol[18]) : "K",
	(csvCol[19]) : "1000"
	
}