-- Table reset

DROP TABLE Chain;
DROP TABLE LiquidityPool;
DROP TABLE Users;
DROP TABLE Transaction;

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
    num_users INTEGER NOT NULL,
    expectedAmountPerUsers FLOAT NOT NULL,
    valueRetained FLOAT NOT NULL,
    address_network_LP VARCHAR2(8) NOT NULL,
    chain_idFK INTEGER NOT NULL,
    PRIMARY KEY (lp_address),
    FOREIGN KEY (chain_idFK) REFERENCES Chain(chain_id)
);

CREATE TABLE Users (
    users_address VARCHAR2(64) NOT NULL,
    address_network_USERs VARCHAR2(8) NOT NULL,
    valueOnWallet FLOAT NOT NULL,
    chain_idFK INTEGER NOT NULL,
    lp_addressFK VARCHAR2(64) NOT NULL,
    PRIMARY KEY (users_address),
    FOREIGN KEY (lp_addressFK) REFERENCES LiquidityPool(lp_address),
    FOREIGN KEY (chain_idFK) REFERENCES Chain(chain_id)
);

CREATE TABLE Transaction (
    transaction_id INTEGER NOT NULL UNIQUE,
    transaction_amount FLOAT NOT NULL,
    users_encrypted_note VARCHAR2(200) NOT NULL UNIQUE
);

-- Insertion of values (testing purposes)

INSERT INTO
    Chain
VALUES
    (
        1,
        'ETHEREUM',
        'https://mainnet.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161',
        'ETH',
        'https://etherscan.io'
    );

INSERT INTO
    Transaction
VALUES
    (1, 0.1, '0xm345z');

INSERT INTO
    Chain
VALUES
    (
        1,
        'ETHEREUM',
        'https://mainnet.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161',
        'ETH',
        'https://etherscan.io'
    );

INSERT INTO
    Users
VALUES
    (
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba8',
        'ETH',
        1.2,
        1,
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1'
    );

INSERT INTO
    LiquidityPool
VALUES
    (
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1',
        15,
        0.1,
        10,
        'ETHEREUM',
        1
    );

INSERT INTO
    Users
VALUES
    (
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ca6',
        'SOL',
        10,
        2,
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A490b'
    );

INSERT INTO
    Users
VALUES
    (
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba8',
        'AVAX',
        100,
        3,
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4aa8'
    );

INSERT INTO
    Users
VALUES
    (
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba4',
        'ETH',
        4.2,
        1,
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1'
    );


-- PSM Section

CREATE OR REPLACE FUNCTION getLQPoolBalance(lpAddress IN VARCHAR2)
    RETURN NUMBER
    IS balance NUMBER(10,2);
    BEGIN
        SELECT valueRetained
        INTO balance
        FROM LIQUIDITYPOOL lp
        WHERE lp.LP_ADDRESS = lpAddress;
        RETURN(balance);
    END;

SELECT GETLQPOOLBALANCE('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1') FROM DUAL;

-- Triggers done (Need to be checked!)

CREATE OR REPLACE TRIGGER verify_network
    AFTER INSERT OR UPDATE OF address_network_Users
    ON Users
    FOR EACH ROW
    PRECEDES verify_amount
DECLARE
    l_user_address VARCHAR2(64) := EXTRACT(address_network_USERs FROM Users);
    l_lp_address VARCHAR2(64) := EXTRACT(address_network_LP FROM LIQUIDITYPOOL);
BEGIN
    IF l_user_address <> l_lp_address THEN
        raise_application_error(-20100, 'Cannot execute transaction with addresses from different networks');
    END IF;
END;

CREATE OR REPLACE TRIGGER verify_amount
    AFTER INSERT OR UPDATE OF transaction_amount
    ON Transaction
    FOR EACH ROW
    FOLLOWS verify_network
DECLARE
    l_transaction_amount FLOAT := EXTRACT(transaction_amount FROM Transaction);
    l_expected_amount FLOAT := EXTRACT(expectedAmountPerUser FROM LIQUIDITYPOOL); 
BEGIN
    IF l_transaction_amount <> l_expected_amount THEN
        raise_application_error(-20100, 'Cannot execute transaction with addresses from different networks');
    END IF;
END;