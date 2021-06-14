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
var csvCol = "DOC_TYPE,SALES_ORG,DISTR_CHAN,DIVISION,PURCH_NO_C,REF_DOC,ITM_NUMBER,MATERIAL,TARGET_QTY,PARTN_ROLE,PARTN_NUMB,SCHED_LINE,REQ_DATE,REQ_QTY,PLANT,PRICE,CURRENCY" splitBy  ","
output application/csv
import * from dw::core::Strings
---
		
payload.generalLedger map (record,index) -> {
    (csvCol[0]) : "OR",
    (csvCol[1]) : (if (record.generalLedgerTransaction.organisationName[0] != "" and record.generalLedgerTransaction.organisationName[0] != null) record.generalLedgerTransaction.organisationName[0] else "1000"),
    (csvCol[2]) : "10",
    (csvCol[3]) : "00",
    (csvCol[4]) : record.generalLedgerTransaction.generalLedgerTransactionId[0],
	(csvCol[5]) : (if (record.generalLedgerTransaction.transactionCategory[0]default "" contains "REVERSED") "REVERSED" else ""),
    (csvCol[6]) : "000010",
	(csvCol[7]) : "AD_MAT",
    (csvCol[8]) : "1",
	(csvCol[9]) : "SP",
	(csvCol[10]) : leftPad(record.generalLedgerTransaction.accountParty.primaryId[0],10,0),
	(csvCol[11]) : "0001",
	(csvCol[12]) : record.creationDateTime  as DateTime  as String {format : "dd.MM.yyyy"},
	(csvCol[13]) : "1",
	(csvCol[14]) : "1000",
	(csvCol[15]) : record.generalLedgerTransaction.amount.value[0],
	(csvCol[16]) : record.generalLedgerTransaction.amount.currencyCode[0]
}
