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
    chain_idFK INTEGER NOT NULL,
    PRIMARY KEY (user_address),
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
    Users
VALUES
    (
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba8',
        100,
        1
    );

INSERT INTO
    Users
VALUES
    (
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba4',
        4.2,
        1
    );

INSERT INTO
    LiquidityPool
VALUES
    (
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1',
        15,
        0.1,
        10,
        1
    );


INSERT INTO
    UsersToLP(ENCRYPTED_NOTE, USER_ADDRESSFK, LP_ADDRESSFK)
VALUES
    (
        'aaaa', '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba8', '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1'
    );

INSERT INTO
    USERSTOLP(USER_ADDRESSFK)
VALUES
    ('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba4');




-- Analytics

-- Users ranked by their valueOnWallet in a specific Chain
SELECT user_address, valueOnWallet, chain_idFK, 
    RANK() OVER (PARTITION BY user_address ORDER BY valueOnWallet) RANK
    FROM Users WHERE chain_idFK = 1
    ORDER BY RANK, chain_idFK;

-- Show users that currently are in a Liquidity Pool
CREATE OR REPLACE PROCEDURE printUsersInLPs IS

    CURSOR getUsersInLP IS
    SELECT user_addressFK, lp_addressFK
    FROM UsersToLP WHERE lp_addressFK <> NULL
    ORDER BY lp_addressFK;

    BEGIN
        FOR userInlp IN getUsersInLP LOOP
            DBMS_OUTPUT.PUT_LINE ('User: ' || userInlp.user_addressFK || ' '  || userInlp.lp_addressFK);
        END LOOP;
    END;

-- Testing printUsersInLPs (execute only the cursor down to get the print)
SET SERVEROUTPUT ON;
BEGIN
    PRINTUSERSPERLP;
END;


-- Organize Liquidity Pools in levels based on the value retained using recursive views
WITH RatioMaxUsersLP(ad, amount, retained, maxUsers, chain, ratio) AS 
(
    SELECT lp_address, expectedAmountPerUser. valueRetained, maxUsers, chain_idFK, 0 AS ratio FROM LiquidityPool
    UNION ALL
    SELECT new.lp_address, lp.expectedAmountPerUser, lp.valueRetained, lp.maxUsers, lp.chain_idFK, new.ratio + 1
    FROM LiquidityPool lp
    INNER JOIN RatioMaxUsersLP new
    ON lp.chain_idFK = new.chain_idFK
    WHERE (lp.valueRetained > new.valueRetained + 0.5)
)

SELECT lp_address, expectedAmountPerUser, valueRetained, maxUsers, chain_idFK, ratio FROM RatioMaxUsersLP

