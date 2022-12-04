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
    encrypted_note INTEGER,
    user_addressFK VARCHAR2(64) NOT NULL,
    lp_addressFK VARCHAR2(64)
);

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