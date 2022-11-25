-- Type defining


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
    maxUsers INTEGER NOT NULL,
    chain_idFK INTEGER NOT NULL,
    PRIMARY KEY (lp_address),
    FOREIGN KEY (chain_idFK) REFERENCES Chain(chain_id)
);

CREATE TABLE User (
    user_address VARCHAR2(64) NOT NULL,
    valueOnWallet FLOAT NOT NULL,
    chain_idFK INTEGER NOT NULL,
    lp_addressFK VARCHAR2(64),
    PRIMARY KEY (user_address),
    FOREIGN KEY (lp_addressFK) REFERENCES LiquidityPool(lp_address),
    FOREIGN KEY (chain_idFK) REFERENCES Chain(chain_id)
);

CREATE TABLE Transaction (
    transaction_id INTEGER NOT NULL UNIQUE,
    transaction_amount FLOAT NOT NULL,
    User_encrypted_note VARCHAR2(200) NOT NULL UNIQUE
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
    User
VALUES
    (
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba8',
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
    User
VALUES
    (
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ca6',
        'SOL',
        10,
        2,
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A490b'
    );

INSERT INTO
    User
VALUES
    (
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba8',
        'AVAX',
        100,
        3,
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4aa8'
    );

INSERT INTO
    User
VALUES
    (
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba4',
        'ETH',
        4.2,
        1,
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1'
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

CREATE OR REPLACE FUNCTION getNumberUserLP(lp_address_to_check IN VARCHAR2)
    RETURN INTEGER
    IS num_users INTEGER;
    BEGIN
        SELECT COUNT(*)
        INTO num_users
        FROM User
        WHERE lp_addressFK = lp_address_to_check;
        RETURN(num_users);
    END;

SELECT GETNUMBERUSERLP('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1') FROM DUAL;

-- CREATE OR REPLACE FUNCTION verifyAddressFormat(address_to_verify IN VARCHAR2)
--     RETURN INTEGER
--     IS checked INTEGER;
--     BEGIN
--         IF (address_to_verify <> '' AND address_to_verify NOT LIKE '0x_%')


-- PROCEDURES

CREATE OR REPLACE PROCEDURE leaveLiquidityPool(LiquidityPool.lp_address%TYPE lpMixed)
    BEGIN
        IF (getNumberUserLP(lpMixed) != lpMixed.maxUsers)
            raise_application_error(-20100, "Pool still has not been mixed. Waiting for more users to join in.");
        END IF;
        DELETE lp_addressFK
        FROM User
        WHERE (lp_addressFK == lpMixed);
    END;


-- Triggers done (Need to be checked!)

CREATE OR REPLACE TRIGGER verify_network
    AFTER INSERT OR UPDATE OF address_network_Users
    ON User
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