/*
 * Changes:
 * 1. Added a table MS_USER_DATA. This will store the Message Store UI application related user data.
 * 2. Created bulk ingestion tables which will be used to support water marking.
 * 3. Added a column CONNECT_ERR to MS_MSG_EVNT, MS_BLK_EVNT and MS_RCRD_EVNT Tables. this will store the connect error.
 * 4. Created tagging tables which will be used to support message playback.
 */


/*
* ************** 1. Added a table MS_USER_DATA. This will store the Message Store UI application related user data. ****************
*/

CREATE TABLE MS_USER_DATA
(
	USER_ID		VARCHAR(255)	PRIMARY KEY ,
	USER_DATA	VARCHAR(4000)	NOT NULL ,
	CREATED_AT	DATETIME		NOT NULL
)

/*
   ************** 2. Create bulk ingestion related schema 
*/
CREATE TABLE MS_INGSTN_RCRD 
(
    INGSTN_RCRD_ID  NUMERIC(16) NOT NULL IDENTITY(1,1),
    CRTD_AT        DATETIME NOT NULL,
    SRVC_NAME      VARCHAR(255) NOT NULL,
    SRVC_INST      VARCHAR(255),
	BULK_ID		   VARCHAR(255) NOT NULL,
    BLK_LOC        VARCHAR(255) NOT NULL    
);

EXEC sp_addextendedproperty 'MS_Description' , 'Table that saves bulk ingestion records' , 'USER' , 'dbo' , 'TABLE' , 'MS_INGSTN_RCRD'	

ALTER TABLE MS_INGSTN_RCRD ADD CONSTRAINT INGSTN_RCRD_ID_PK PRIMARY KEY ( INGSTN_RCRD_ID );

ALTER TABLE MS_INGSTN_RCRD ADD CONSTRAINT INGSTN_RCRD_UK UNIQUE ( SRVC_NAME, BULK_ID );

CREATE TABLE MS_BLK_INGSTN 
(
    BLK_INGSTN_ID  NUMERIC(16) NOT NULL IDENTITY(1,1),
    LST_INGSTD_AT  DATETIME NOT NULL,
    BLK_INGSTN_RCRD_ID        NUMERIC(16) NOT NULL,
    ING_SRVC_NAME      VARCHAR(255) NOT NULL,
    CUR_POS            NUMERIC(16) NOT NULL    
);

EXEC sp_addextendedproperty 'MS_Description' , 'Table that keeps track of the bulk ingestions' , 'USER' , 'dbo' , 'TABLE' , 'MS_BLK_INGSTN'	

ALTER TABLE MS_BLK_INGSTN ADD CONSTRAINT BLK_INGSTN_ID_PK PRIMARY KEY ( BLK_INGSTN_ID );

ALTER TABLE MS_BLK_INGSTN ADD CONSTRAINT BLK_INGSTN_UK UNIQUE ( BLK_INGSTN_RCRD_ID, ING_SRVC_NAME );

ALTER TABLE MS_BLK_INGSTN ADD CONSTRAINT MS_BULK_INGSTN_FK FOREIGN KEY ( BLK_INGSTN_RCRD_ID ) REFERENCES MS_INGSTN_RCRD ( INGSTN_RCRD_ID ) ON DELETE CASCADE;

CREATE TABLE MS_BLK_INGSTN_EVNT 
(
    BLK_INGSTN_EVNT_ID        NUMERIC(16) NOT NULL IDENTITY(1,1),
	BLK_INGSTN_ID        NUMERIC(16) NOT NULL,
    INGSTD_AT  DATETIME NOT NULL,
    ING_SRVC_INST      VARCHAR(255),    
    STRT_POS       NUMERIC(16) NOT NULL,
    END_POS       NUMERIC(16) NOT NULL
);

EXEC sp_addextendedproperty 'MS_Description' , 'Table that captures the ingestion events of a service' , 'USER' , 'dbo' , 'TABLE' , 'MS_BLK_INGSTN_EVNT'		

ALTER TABLE MS_BLK_INGSTN_EVNT ADD CONSTRAINT MS_BULK_INGSTN_EVNT_FK FOREIGN KEY ( BLK_INGSTN_ID ) REFERENCES MS_BLK_INGSTN ( BLK_INGSTN_ID ) ON DELETE CASCADE;


/********* Adding CONNECT_ERR column to MS_MSG_EVNT *********/

ALTER TABLE MS_MSG_EVNT ADD CONNECT_ERR NVARCHAR (MAX);

/********* Adding CONNECT_ERR column to MS_BLK_EVNT *********/

ALTER TABLE MS_BLK_EVNT ADD CONNECT_ERR NVARCHAR (MAX);

/********* Adding CONNECT_ERR column to MS_RCRD_EVNT *********/

ALTER TABLE MS_RCRD_EVNT ADD CONNECT_ERR NVARCHAR (MAX);

/*
* ************** 3. Create message tagging related schema ****************
*/

CREATE TABLE MS_TAG
(
    TAG_ID      NUMERIC(16) NOT NULL IDENTITY(1,1),
	TAG_NAME    VARCHAR(255) NOT NULL
)

EXEC sp_addextendedproperty 'MS_Description' , 'Table that maintains tags for grouping messages' , 'USER' , 'dbo' , 'TABLE' , 'MS_TAG'

ALTER TABLE MS_TAG ADD CONSTRAINT TAG_ID_PK PRIMARY KEY ( TAG_ID )

ALTER TABLE MS_TAG ADD CONSTRAINT TAG_UK UNIQUE ( TAG_NAME )

CREATE TABLE MS_MSG_TAG
(
    MS_TAG_ID       NUMERIC(16) NOT NULL IDENTITY(1,1),
	TAG_ID          NUMERIC(16) NOT NULL,
	MSG_HDR_ID      NUMERIC(16) NOT NULL
)

EXEC sp_addextendedproperty 'MS_Description' , 'Table that assigns messages to tag' , 'USER' , 'dbo' , 'TABLE' , 'MS_MSG_TAG'

ALTER TABLE MS_MSG_TAG ADD CONSTRAINT MS_TAG_ID_PK PRIMARY KEY ( MS_TAG_ID )

ALTER TABLE MS_MSG_TAG ADD CONSTRAINT MSG_TAG_UK UNIQUE ( TAG_ID, MSG_HDR_ID )

ALTER TABLE MS_MSG_TAG ADD CONSTRAINT TAG_FK FOREIGN KEY ( TAG_ID ) REFERENCES MS_TAG ( TAG_ID ) ON DELETE CASCADE

ALTER TABLE MS_MSG_TAG ADD CONSTRAINT MSG_HDR_FK FOREIGN KEY (MSG_HDR_ID ) REFERENCES MS_MSG_HDR ( MSG_HDR_ID ) ON DELETE CASCADE

/*
* ************** 4. Add the current message store schema version. ****************
*/
INSERT INTO MS_VER(VER, CRTD_AT) VALUES('2020.3.0', CURRENT_TIMESTAMP);

