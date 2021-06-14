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
// This transformation is being used to set avps data for acknowledgement message.
%dw 2.0
output application/json
---
{
	headerAvps : {
		originalMessageSender : vars.acknowledgement.sender,
		detailedResponseStatusCode :  vars.responseStatusCode,
		originSystemOfAcknowledgement : p('ack.sender')
	},
	documentAvps : {
		requestElementOrWorkflowIdentifier : vars.requestElementOrWorkflowIdentifier,
		requestIdentifier : vars.acknowledgement.messageId,
		requestTypeIdentifier : vars.acknowledgement.requestTypeIdentifier,
		messageStoreInformation : if (vars.bulkHeaderChildRef != null and vars.bulkHeaderChildRef != "") (vars.bulkHeaderChildRef.bulkReference splitBy "/")[5] else if (vars.bulkHeaderRef != null and vars.bulkHeaderRef != "") (vars.bulkHeaderRef.bulkReference splitBy "/")[5] else "NA : Either Message Store is disabled or Request failed before/inside message store flow"
	}
}