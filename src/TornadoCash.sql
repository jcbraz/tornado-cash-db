-- Reset
DROP TABLE Chain;
DROP TABLE LiquidityPool;
DROP TABLE Users;
DROP TABLE UsersToLP;
DROP FUNCTION getNumberUserLP;
DROP FUNCTION getUserWalletBalance;
DROP PROCEDURE joinLiquidityPool;
DROP PROCEDURE leaveLiquidityPool;
DROP TRIGGER secureTransactionData;

-- Table struture creation

CREATE TABLE Chain (
    chain_id INT NOT NULL,
    chain_name VARCHAR2(45) NOT NULL,
    rpc_url VARCHAR2(100) NOT NULL,
    symbol VARCHAR2(10) NOT NULL,
    block_explorer_url VARCHAR2(100),
    PRIMARY KEY (chain_id)
);
CREATE TABLE LiquidityPool (

    lp_address VARCHAR2(64) NOT NULL,
    expectedAmountPerUser FLOAT NOT NULL,
    valueRetained FLOAT NOT NULL,
    maxUsers INTEGER NOT NULL,
    transaction_history VARCHAR2(32767),
    chain_idFK INTEGER NOT NULL,
    PRIMARY KEY (lp_address),
    CONSTRAINT ensure_json CHECK (transaction_history IS JSON),
    FOREIGN KEY (chain_idFK) REFERENCES Chain(chain_id)
);

CREATE TABLE Users (
    user_address VARCHAR2(64) NOT NULL,
    valueOnWallet FLOAT NOT NULL,
    transaction_history VARCHAR2(32767),
    chain_idFK INTEGER NOT NULL,
    PRIMARY KEY (user_address),
    CONSTRAINT ensure_json CHECK (transaction_history IS JSON),
    FOREIGN KEY (chain_idFK) REFERENCES Chain(chain_id)
);


CREATE TABLE LiquidityPool (
    lp_address VARCHAR2(64) NOT NULL,
    expectedAmountPerUser FLOAT NOT NULL,
    valueRetained FLOAT NOT NULL,
    maxUsers INTEGER NOT NULL,
    transaction_history VARCHAR2(32767),
    chain_idFK INTEGER NOT NULL,
    PRIMARY KEY (lp_address),
    CONSTRAINT ensure_json CHECK (transaction_history IS JSON),
    FOREIGN KEY (chain_idFK) REFERENCES Chain(chain_id)
);

CREATE TABLE UsersToLP (
    transactionId NUMBER GENERATED ALWAYS AS IDENTITY, 
    encrypted_note VARCHAR2(200),
    user_addressFK VARCHAR2(64) NOT NULL,
    lp_addressFK VARCHAR2(64)
);

-- PSM Section

-- FUNCTIONS

CREATE OR REPLACE FUNCTION getUserWalletBalance(address_to_verify IN VARCHAR2)
    RETURN NUMBER
    IS balance NUMBER(10,8);
    BEGIN
        SELECT valueOnWallet
        INTO balance
        FROM Users
        WHERE USERS_ADDRESS = address_to_verify;
        RETURN(balance);
    END;

SELECT GETUSERWALLETBALANCE('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba8') FROM DUAL;

-- CREATE OR REPLACE FUNCTION getNumberUserLP(lp_address_to_check IN VARCHAR2)
--     RETURN INTEGER
--     IS num_users INTEGER;
--     BEGIN
--         SELECT COUNT(*)
--         INTO num_users
--         FROM Users
--         WHERE lp_addressFK = lp_address_to_check;
--         RETURN(num_users);
--     END;

CREATE OR REPLACE FUNCTION getNumberUserLP(lp_address_to_check IN VARCHAR2)
    RETURN INTEGER
    IS num_users INTEGER;
    BEGIN
        SELECT COUNT(*)
        INTO num_users
        FROM UsersToLP
        WHERE lp_addressFK = lp_address_to_check;
        RETURN(num_users);
    END;

SELECT GETNUMBERUSERLP('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1') FROM DUAL;


-- PROCEDURES

CREATE OR REPLACE PROCEDURE joinLiquidityPool(userToJoin Users.user_address%TYPE, lpToMix LiquidityPool.lp_address%TYPE)
    AS
        currentUsersInLP INTEGER;
        maxUsersLP LiquidityPool.maxUsers%TYPE;
        currentLPAssociated UsersToLP.lp_addressFK%TYPE;
        generatedKey INTEGER;

        maxUsersReached EXCEPTION;

    BEGIN

        SELECT COUNT(*) INTO currentUsersInLP FROM UsersToLP ulp WHERE ulp.lp_addressFK = lpToMix;
        SELECT maxUsers INTO maxUsersLP FROM LiquidityPool lp WHERE lp.lp_address = lpToMix;
        SELECT lp_addressFK INTO currentLPAssociated FROM UsersToLP ulp WHERE ulp.user_addressFK = userToJoin;

        IF maxUsersLP = currentUsersInLP THEN
            RAISE maxUsersReached;
        ELSE
            IF currentLPAssociated IS NULL THEN
                UPDATE UsersToLP SET encrypted_note = DBMS_RANDOM.VALUE WHERE UsersToLP.user_addressFK = userToJoin;
                UPDATE UsersToLP SET lp_addressFK = lpToMix WHERE UsersToLP.user_addressFK = userToJoin;
            ELSE
                raise_application_error(-20100, 'User given was already associated with another Liquidity Pool!');
            END IF;
        END IF;
    EXCEPTION
        WHEN maxUsersReached THEN
            raise_application_error(-20001, 'The Liquidity Pool is full. Please try join another one or try again later.');
            
    END joinLiquidityPool;

-- Testing joinLiquidityPool

BEGIN
  JOINLIQUIDITYPOOL('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba4', '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1');
END;

SELECT * FROM USERS;


CREATE OR REPLACE PROCEDURE leaveLiquidityPool(lpMixed LiquidityPool.lp_address%TYPE)
    AS
        maxUsersMixed LiquidityPool.maxUsers%TYPE;

        stillWaiting EXCEPTION;

    BEGIN
        SELECT maxUsers INTO maxUsersMixed FROM LiquidityPool lp WHERE lp.lp_address = lpMixed;

        IF (GETNUMBERUSERLP(lpMixed) <> maxUsersMixed) THEN
            RAISE stillWaiting;
        ELSE
            UPDATE UsersToLP SET encrypted_note = NULL WHERE lp_addressFK = lpMixed;
            UPDATE UsersToLP SET lp_addressFK = NULL WHERE lp_addressFK = lpMixed;
        END IF;
    EXCEPTION
        WHEN stillWaiting THEN
            raise_application_error(-20100, 'Pool still has not been mixed. Waiting for more users to join in.');

    END leaveLiquidityPool;

-- Testing leaveLiquidityPool

UPDATE LIQUIDITYPOOL SET maxUsers = 1 WHERE LP_ADDRESS = '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1';

BEGIN
  LEAVELIQUIDITYPOOL('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1');
END;

SELECT * FROM USERSTOLP;

-- JSON 

-- Trigger to test JSON views and to grant integrity on the historical data inserted (User Table)
CREATE OR REPLACE TRIGGER secureTransactionDataUser
    BEFORE INSERT OR UPDATE OF transaction_history
    ON Users
    FOR EACH ROW
    DECLARE new_source VARCHAR2(64);
    BEGIN
        SELECT ut.transaction_history.Source INTO new_source FROM Users ut WHERE ut.USER_ADDRESS = :old.user_address;
        IF :old.user_address <> new_source THEN
            raise_application_error(-20100, 'The data being inserted is not coerent with the existing data');
        END IF;
    END;

-- Trigger to test JSON views and to grant integrity on the historical data inserted (Liquidity Pool Table)
CREATE OR REPLACE TRIGGER secureTransactionDataLP
    BEFORE INSERT OR UPDATE OF transaction_history
    ON LiquidityPool
    FOR EACH ROW
    DECLARE new_source VARCHAR2(64);
    BEGIN
        SELECT lp.transaction_history.Source INTO new_source FROM LiquidityPool lp WHERE lp.lp_address = :old.lp_address;
        IF :old.lp_address <> new_source THEN
            raise_application_error(-20100, 'The data being inserted is not coerent with the existing data');
        END IF;
    END;

-- Test JSON views
SELECT ut.transaction_history.Source FROM Users ut;
SELECT lp.transaction_history.Source FROM LiquidityPool lp;


--  OBJECT EXTENSION SECTION

-- Type defining
CREATE TYPE rated_user AS OBJECT (
    rated_user_address VARCHAR2(64),
    analysed VARCHAR2(5)
);

CREATE TYPE rated_users AS TABLE OF rated_user;

-- Applying types
CREATE TABLE Rating (
    rating_time DATE,
    unbanned_users rated_users,
    banned_users rated_users)
NESTED TABLE unbanned_users STORE AS unbanned_users_nt,
NESTED TABLE banned_users STORE AS banned_users_nt;

CREATE INDEX unbanned_users_idx ON unbanned_users_nt(rated_user_address);
CREATE INDEX banned_users_idx ON banned_users_nt(rated_user_address);

