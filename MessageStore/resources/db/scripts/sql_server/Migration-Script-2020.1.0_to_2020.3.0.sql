/*
 * Changes:
 * 1. Created tagging tables which will be used to support message playback.
 * 2. Add the current message store schema version
 */


/*
* ************** 1. Create message tagging related schema ****************
*/

CREATE TABLE MS_TAG
(
    TAG_ID      NUMERIC(16) NOT NULL IDENTITY(1,1),
	TAG_NAME    VARCHAR(255) NOT NULL,
    CREATED_AT  DATETIME   NOT NULL

)

EXEC sp_addextendedproperty 'MS_Description' , 'Table that maintains tags for grouping messages' , 'USER' , 'dbo' , 'TABLE' , 'MS_TAG'

ALTER TABLE MS_TAG ADD CONSTRAINT TAG_ID_PK PRIMARY KEY ( TAG_ID )

ALTER TABLE MS_TAG ADD CONSTRAINT TAG_UK UNIQUE ( TAG_NAME )

CREATE TABLE MS_MSG_TAG
(
    MS_TAG_ID       NUMERIC(16) NOT NULL IDENTITY(1,1),
	TAG_ID          NUMERIC(16) NOT NULL,
	MSG_HDR_ID      NUMERIC(16) NOT NULL,
    CREATED_AT      DATETIME   NOT NULL
)

EXEC sp_addextendedproperty 'MS_Description' , 'Table that assigns messages to tag' , 'USER' , 'dbo' , 'TABLE' , 'MS_MSG_TAG'

ALTER TABLE MS_MSG_TAG ADD CONSTRAINT MS_TAG_ID_PK PRIMARY KEY ( MS_TAG_ID )

ALTER TABLE MS_MSG_TAG ADD CONSTRAINT MSG_TAG_UK UNIQUE ( TAG_ID, MSG_HDR_ID )

ALTER TABLE MS_MSG_TAG ADD CONSTRAINT TAG_FK FOREIGN KEY ( TAG_ID ) REFERENCES MS_TAG ( TAG_ID ) ON DELETE CASCADE

ALTER TABLE MS_MSG_TAG ADD CONSTRAINT MSG_HDR_FK FOREIGN KEY (MSG_HDR_ID ) REFERENCES MS_MSG_HDR ( MSG_HDR_ID ) ON DELETE CASCADE

/*
* ************** 2. Add the current message store schema version. ****************
*/
INSERT INTO MS_VER(VER, CRTD_AT) VALUES('2020.3.0', CURRENT_TIMESTAMP);

