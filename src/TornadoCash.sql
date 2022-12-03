-- Type defining


-- Reset
DROP TABLE Chain;
DROP TABLE LiquidityPool;
DROP TABLE Users;
DROP TABLE UsersToLP;
DROP FUNCTION getNumberUserLP;
DROP FUNCTION getUserWalletBalance;
DROP PROCEDURE joinLiquidityPool;
DROP PROCEDURE leaveLiquidityPool;

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
    chain_idFK INTEGER NOT NULL,
    PRIMARY KEY (lp_address),
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


CREATE TABLE UsersToLP (
    transactionId NUMBER GENERATED ALWAYS AS IDENTITY,
    encrypted_note INTEGER,
    user_addressFK VARCHAR2(64) NOT NULL,
    lp_addressFK VARCHAR2(64)
);

-- Trigger to test JSON views and to grant integrity on the historical data inserted
CREATE OR REPLACE TRIGGER secureTransactionData
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

-- Test JSON views
SELECT ut.transaction_history.Source FROM Users ut;
--