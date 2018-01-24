USE testliquibase
DROP PROCEDURE IF EXISTS initializeDatabaseLockTable;
DROP PROCEDURE IF EXISTS lockDatabaseLockTable;
DROP PROCEDURE IF EXISTS releaseDatabaseLockTable;
DROP PROCEDURE IF EXISTS checkIfMigrationExists;
DROP PROCEDURE IF EXISTS saveMigrationLog;

--  Create Database Lock Table
CREATE TABLE IF NOT EXISTS testliquibase.DATABASECHANGELOGLOCK (
    ID INT NOT NULL,
    LOCKED BIT(1) NOT NULL,
    LOCKGRANTED datetime NULL,
    LOCKEDBY VARCHAR(255) NULL,
    CONSTRAINT PK_DATABASECHANGELOGLOCK PRIMARY KEY (ID)
);

--  Create Database Change Log Table
CREATE TABLE IF NOT EXISTS testliquibase.DATABASECHANGELOG (
    ID VARCHAR(255) NOT NULL,
    AUTHOR VARCHAR(255) NOT NULL,
    FILENAME VARCHAR(255) NOT NULL,
    DATEEXECUTED datetime NOT NULL,
    ORDEREXECUTED INT NOT NULL,
    EXECTYPE VARCHAR(10) NOT NULL,
    MD5SUM VARCHAR(35) NULL,
    DESCRIPTION VARCHAR(255) NULL,
    COMMENTS VARCHAR(255) NULL,
    TAG VARCHAR(255) NULL,
    LIQUIBASE VARCHAR(20) NULL,
    CONTEXTS VARCHAR(255) NULL,
    LABELS VARCHAR(255) NULL
);


DELIMITER //
CREATE PROCEDURE initializeDatabaseLockTable()
    BEGIN
        DELETE FROM testliquibase.DATABASECHANGELOGLOCK;
        INSERT INTO testliquibase.DATABASECHANGELOGLOCK (ID, LOCKED) VALUES (1, 0);
    END;
//
DELIMITER //


DELIMITER //
CREATE PROCEDURE lockDatabaseLockTable()
    BEGIN
        UPDATE testliquibase.DATABASECHANGELOGLOCK SET LOCKED = 1, LOCKEDBY = 'aom', LOCKGRANTED = NOW()
            WHERE ID = 1 AND LOCKED = 0;
    END;
//
DELIMITER //


DELIMITER //
CREATE PROCEDURE releaseDatabaseLockTable()
    BEGIN
        UPDATE testliquibase.DATABASECHANGELOGLOCK SET LOCKED = 0, LOCKEDBY = NULL, LOCKGRANTED = NULL WHERE ID = 1;
    END;
//
DELIMITER //


DELIMITER //
CREATE PROCEDURE checkIfMigrationExists(IN migrationId VARCHAR(64), INOUT result INT)
    BEGIN
        SET result = (SELECT COUNT(id) FROM testliquibase.databasechangelog WHERE id=migrationId);
    END;
//
DELIMITER //


DELIMITER //
CREATE PROCEDURE saveMigrationLog(IN migrationId VARCHAR(255), IN filename VARCHAR(255), IN md5sum VARCHAR(255),
        IN description VARCHAR(255), IN comments VARCHAR(255))

    BEGIN
        INSERT INTO testliquibase.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM,
            DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE)
            VALUES (migrationId, 'aom', filename, NOW(), 1, md5sum, description, comments, 'EXECUTED', NULL,
            NULL, '3.4.2');
    END;
//
DELIMITER //