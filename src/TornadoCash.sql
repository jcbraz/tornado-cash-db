-- Type defining


-- Reset
DROP TABLE Chain;
DROP TABLE LiquidityPool;
DROP TABLE Users;
DROP TABLE Transaction;
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
    encrypted_noteLP VARCHAR2(64),
    chain_idFK INTEGER NOT NULL,
    PRIMARY KEY (lp_address),
    FOREIGN KEY (chain_idFK) REFERENCES Chain(chain_id)
);

CREATE TABLE Users (
    user_address VARCHAR2(64) NOT NULL,
    valueOnWallet FLOAT NOT NULL,
    chain_idFK INTEGER NOT NULL,
    encrypted_noteUser VARCHAR2(64),
    lp_addressFK VARCHAR2(64),
    PRIMARY KEY (user_address),
    FOREIGN KEY (lp_addressFK) REFERENCES LiquidityPool(lp_address),
    FOREIGN KEY (chain_idFK) REFERENCES Chain(chain_id)
);


CREATE TABLE UsersToLP (
    transactionId NUMBER NOT NULL GENERATED ALWAYS AS IDENTITY,
    encrypted_note INTEGER,
    user_addressFK VARCHAR2(64) NOT NULL,
    lp_addressFK VARCHAR2(64)
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
