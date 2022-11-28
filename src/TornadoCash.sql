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
    expectedAmountPerUsers FLOAT NOT NULL,
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
        FROM Users
        WHERE lp_addressFK = lp_address_to_check;
        RETURN(num_users);
    END;

SELECT GETNUMBERUSERLP('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1') FROM DUAL;


-- PROCEDURES

CREATE OR REPLACE PROCEDURE joinLiquidityPool(userToJoin Users.user_address%TYPE, lpToMix LiquidityPool.lp_address%TYPE)
    AS
        currentUsersInLP INTEGER;
        maxUsersLP LiquidityPool.maxUsers%TYPE;
        currentLPAssociated Users.lp_addressFK%TYPE;

        maxUsersReached EXCEPTION;

    BEGIN
        SELECT COUNT(*) INTO currentUsersInLP FROM Users ut WHERE ut.lp_addressFK = lpToMix;
        SELECT lp_addressFK INTO currentLPAssociated FROM Users ut WHERE ut.user_address = userToJoin;
        SELECT maxUsers INTO maxUsersLP FROM LiquidityPool lp WHERE lp.lp_address = lpToMix;

        IF maxUsersLP = currentUsersInLP THEN
            RAISE maxUsersReached;
        ELSE
            IF currentLPAssociated IS NULL THEN
                UPDATE Users SET lp_addressFK = lpToMix WHERE Users.user_address = userToJoin;
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
  JOINLIQUIDITYPOOL('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba8', '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1');
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
            UPDATE Users SET lp_addressFK = NULL WHERE lp_addressFK = lpMixed;
        END IF;
    EXCEPTION
        WHEN stillWaiting THEN
            raise_application_error(-20100, 'Pool still has not been mixed. Waiting for more users to join in.');

    END leaveLiquidityPool;

-- Testing leaveLiquidityPool

BEGIN
  LEAVELIQUIDITYPOOL('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1');
END;

SELECT * FROM USERS;



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