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

-- Triggers done

-- Trigger made to ensure there is a monetary system where money cannot be less then 0 on the User side.
CREATE OR REPLACE TRIGGER secureValueIntegrityUser
    BEFORE INSERT OR UPDATE OF valueOnWallet
    ON Users
    FOR EACH ROW
    BEGIN
        IF :new.valueOnWallet < 0 THEN
            raise_application_error(-20100, 'Unsuficient balance to go through with the transaction');
        END IF;
    END;


-- Trigger made to ensure there is a monetary system where money cannot be less then 0 on the Liquidity Pool side.
CREATE OR REPLACE TRIGGER secureValueIntegrityLP
    BEFORE INSERT OR UPDATE OF valueRetained
    ON LiquidityPool
    FOR EACH ROW
    BEGIN
        IF :new.valueRetained < 0 THEN
            raise_application_error(-20100, 'Something went wrong related to the Liquidity Pool balance retained');
        END IF;
    END;

-- Trigger made to ensure that the values on the UsersToLP table cannot be inserted manually and the a procedure must be envocked to change them.
CREATE OR REPLACE TRIGGER secureIntegrityUsersToLP
    INSTEAD OF INSERT OR UPDATE OF user_addressFK
    ON UsersToLP
    FOR EACH ROW
    BEGIN
            INSERT INTO UserToLP(encrypted_note, user_addressFK, lp_addressFK) VALUES (NULL, :new.user_addressFK, NULL);
    END;

-- Trigger made to secure that an association between a User and a Liquidity Pool cannot be made artificially and only with the procedures meant to do it.
CREATE OR REPLACE TRIGGER secureIntegrityDeposits
    BEFORE INSERT OR DELETE OF lp_addressFK
    ON UsersToLP
    FOR EACH ROW
        BEGIN
            raise_application_error(-20100, 'This action is not allow and must be done through the tools available!');
        END;

-- Trigger made to ensure that the encrypted note given to the user cannot be artificially changed and only the procedure which executes the attribution of the key does it.
CREATE OR REPLACE TRIGGER secureIntegrityEncryptedNote
    BEFORE INSERT OR DELETE OF encrypted_note
    ON UsersToLP
    FOR EACH ROW
        BEGIN
            raise_application_error(-20100, 'This action is not allow and must be done through the tools available!');
        END;

-- Trigger made to secure the normal inflow and outflow of money in the LiquidityPool.
-- If a User join a Liquidity Pool, he make a deposit which means the money has to come out of his wallet and enter the value retained on the Liquidity Pool treasury. Same case as if a User leaves the LP and takes out his money. The value deposited previously must return to the user balance sheet and leave the LP treasury.
-- The use of this trigger can be a bit unnecessary due to the fact that this conditions can be perfectly placed in the procedures made to join and leave the LP, reducing the complexity however for the purpose of the evaluation, this mechanism is also an option.

CREATE OR REPLACE TRIGGER transactionsLPControl
    AFTER UPDATE OF lp_addressFK 
    ON UsersToLP
    FOR EACH ROW
DECLARE
    expected_amount LiquidityPool.expectedAmountPerUser%TYPE;
    BEGIN
        IF :new.lp_addressFK <> NULL THEN
            SELECT expectedAmountPerUser INTO expected_amount FROM LiquidityPool
            WHERE lp_address = :new.lp_addressFK;

            UPDATE Users SET valueOnWallet = valueOnWallet - expected_amount 
            WHERE user_address = :old.user_addressFK;

            UPDATE LiquidityPool SET valueRetained = valueRetained + expected_amount
            WHERE lp_address = :new.lp_addressFK;
        ELSE
            SELECT expectedAmountPerUser INTO expected_amount FROM LiquidityPool
            WHERE lp_address = :old.lp_addressFK;

            UPDATE Users SET valueOnWallet = valueOnWallet + expected_amount
            WHERE user_address = :old.user_addressFK;

            UPDATE LiquidityPool SET valueRetained = valueRetained - expected_amount
            WHERE lp_address = :old.lp_addressFK;
        END IF;
    END;




-- Testing trigger transactionsLPControl

CREATE OR REPLACE TRIGGER transactionsLPControl
    AFTER UPDATE OF lp_addressFK
    ON UsersToLP
    FOR EACH ROW
DECLARE
    expected_amount LiquidityPool.expectedAmountPerUsers%TYPE;
    BEGIN
        IF :new.lp_addressFK <> NULL THEN
            SELECT expectedAmountPerUsers INTO expected_amount FROM LiquidityPool
            WHERE lp_address = :new.lp_addressFK;

            UPDATE Users SET valueOnWallet = valueOnWallet - expected_amount 
            WHERE user_address = :new.user_addressFK;

            UPDATE LiquidityPool SET valueRetained = valueRetained + expected_amount
            WHERE lp_address = :new.lp_addressFK;
        ELSE
            SELECT expectedAmountPerUsers INTO expected_amount FROM LiquidityPool
            WHERE lp_address = :old.lp_addressFK;

            UPDATE Users SET valueOnWallet = valueOnWallet + expected_amount
            WHERE user_address = :new.user_addressFK;

            UPDATE LiquidityPool SET valueRetained = valueRetained - expected_amount
            WHERE lp_address = :old.lp_addressFK;
        END IF;
    END;

drop TRIGGER transactionsLPControl;

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


DROP TRIGGER transactionsLPControl;

BEGIN
  JOINLIQUIDITYPOOL('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba4', '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1');
END;


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


BEGIN
  LEAVELIQUIDITYPOOL('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1');
END;

SELECT * FROM USERS;