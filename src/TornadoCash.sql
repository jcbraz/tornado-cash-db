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
    CONSTRAINT ensure_jsonLP CHECK (transaction_history IS JSON),
    FOREIGN KEY (chain_idFK) REFERENCES Chain(chain_id)
);

CREATE TABLE Users (
    user_address VARCHAR2(64) NOT NULL,
    valueOnWallet FLOAT NOT NULL,
    transaction_history VARCHAR2(32767),
    chain_idFK INTEGER NOT NULL,
    PRIMARY KEY (user_address),
    CONSTRAINT ensure_jsonUser CHECK (transaction_history IS JSON),
    FOREIGN KEY (chain_idFK) REFERENCES Chain(chain_id)
);


CREATE TABLE UsersToLP (
    transactionId NUMBER GENERATED ALWAYS AS IDENTITY, 
    encrypted_note VARCHAR2(200),
    user_addressFK VARCHAR2(64) NOT NULL,
    lp_addressFK VARCHAR2(64)
);


-- PSM Section

-- Functions

-- Function to get the balance of a user
CREATE OR REPLACE FUNCTION getUserWalletBalance(address_to_verify IN VARCHAR2)
    RETURN NUMBER
    IS balance NUMBER(20,8);
    BEGIN
        SELECT valueOnWallet
        INTO balance
        FROM Users
        WHERE user_address = address_to_verify;
        RETURN(balance);
    END;

-- Function to get the number of users in a LP
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
-- Create a view for the UsersToLP table
CREATE VIEW UsersToLPView AS
    SELECT * FROM UsersToLP;

-- Create an INSTEAD OF trigger on the view
CREATE OR REPLACE TRIGGER secureIntegrityUsersToLP
INSTEAD OF INSERT
ON UsersToLPView
FOR EACH ROW
BEGIN
    INSERT INTO UsersToLP(encrypted_note, user_addressFK, lp_addressFK) 
    VALUES (NULL, :new.user_addressFK, NULL);
END;


-- Trigger made to secure that an association between a User and a Liquidity Pool cannot be made artificially and only with the procedures meant to do it.
CREATE OR REPLACE TRIGGER secureIntegrityDeposits
    BEFORE INSERT OR DELETE ON UsersToLP
    REFERENCING OLD AS old_lp_addressFK NEW AS new_lp_addressFK
    FOR EACH ROW
    BEGIN
        -- check if the old or new value of lp_addressFK is being inserted or deleted
        IF inserting OR deleting THEN
            DBMS_OUTPUT.PUT_LINE('This action is not allowed and must be done through the tools available!');
        END IF;
    END;

-- Trigger made to ensure that the encrypted note given to the user cannot be artificially changed and only the procedure which executes the attribution of the key does it.
CREATE OR REPLACE TRIGGER secureIntegrityEncryptedNote
    BEFORE INSERT OR DELETE ON UsersToLP
    REFERENCING OLD AS old_encrypted_note NEW AS new_encrypted_note
    FOR EACH ROW
    BEGIN
        -- check if the old or new value of encrypted_note is being inserted or deleted
        IF inserting OR deleting THEN
            DBMS_OUTPUT.PUT_LINE('This action is not allowed and must be done through the tools available!');
        END IF;
    END;


-- Trigger made to secure the normal inflow and outflow of money in the LiquidityPool.
-- If a User join a Liquidity Pool, he make a deposit which means the money has to come out of his wallet and enter the value retained on the Liquidity Pool treasury. Same case as if a User leaves the LP and takes out his money. The value deposited previously must return to the user balance sheet and leave the LP treasury.
-- The use of this trigger can be a bit unnecessary due to the fact that this conditions can be perfectly placed in the procedures made to join and leave the LP, reducing the complexity however for the purpose of the evaluation, this mechanism is also an option.

CREATE OR REPLACE TRIGGER transactionsLPControl
    AFTER UPDATE OF lp_addressFK 
    ON UsersToLP
    FOR EACH ROW
DECLARE
    expected_amount LiquidityPool.expectedAmountPerUsers%TYPE;
    BEGIN
        -- Check if the value has changed
        IF :new.lp_addressFK != :old.lp_addressFK THEN
            -- If the user is associated with a liquidity pool
            IF :new.lp_addressFK IS NOT NULL THEN
                SELECT expectedAmountPerUsers INTO expected_amount FROM LiquidityPool
                WHERE lp_address = :new.lp_addressFK;

                UPDATE Users SET valueOnWallet = valueOnWallet - expected_amount 
                WHERE user_address = :new.user_addressFK;

                UPDATE LiquidityPool SET valueRetained = valueRetained + expected_amount
                WHERE lp_address = :new.lp_addressFK;
            ELSE
                -- If the user is not associated with a liquidity pool
                SELECT expectedAmountPerUsers INTO expected_amount FROM LiquidityPool
                WHERE lp_address = :old.lp_addressFK;

                UPDATE Users SET valueOnWallet = valueOnWallet + expected_amount
                WHERE user_address = :new.user_addressFK;

                UPDATE LiquidityPool SET valueRetained = valueRetained - expected_amount
                WHERE lp_address = :old.lp_addressFK;
            END IF;
        END IF;
    END;


-- PROCEDURES

-- Procedure to join a LP
CREATE OR REPLACE PROCEDURE joinLiquidityPool(userToJoin Users.user_address%TYPE, lpToMix LiquidityPool.lp_address%TYPE)
AS
    currentUsersInLP INTEGER;
    maxUsersLP LiquidityPool.maxUsers%TYPE;
    currentLPAssociated UsersToLP.lp_addressFK%TYPE;

    BEGIN

        SELECT COUNT(*) INTO currentUsersInLP FROM UsersToLP ulp WHERE ulp.lp_addressFK = lpToMix;
        SELECT maxUsers INTO maxUsersLP FROM LiquidityPool lp WHERE lp.lp_address = lpToMix;

        IF maxUsersLP = currentUsersInLP THEN
            raise_application_error(-20001, 'The Liquidity Pool is full. Please try join another one or try again later.');
        END IF;

        SELECT lp_addressFK INTO currentLPAssociated FROM UsersToLP ulp WHERE ulp.user_addressFK = userToJoin;

        IF currentLPAssociated IS NULL THEN
            UPDATE UsersToLP 
            SET encrypted_note = DBMS_RANDOM.VALUE,
                lp_addressFK = lpToMix
            WHERE UsersToLP.user_addressFK = userToJoin;
        ELSE
            raise_application_error(-20100, 'User given was already associated with another Liquidity Pool!');
        END IF;

    END joinLiquidityPool;

-- Procedure to leave a LP
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

-- Advanced Operators (also OLAP)

-- Analytics
-- Users ranked by their valueOnWallet in a specific Chain
SELECT user_address, valueOnWallet, chain_idFK, 
    RANK() OVER (PARTITION BY user_address ORDER BY valueOnWallet) RANK
    FROM Users WHERE chain_idFK = 1
    ORDER BY RANK, chain_idFK;

-- Total value of Users and Liquidity Pools and the total value of each Chain
SELECT c.chain_name, SUM(u.valueOnWallet) AS user_value, SUM(lp.valueRetained) AS lp_value,
    SUM(u.valueOnWallet + lp.valueRetained) AS total_value
FROM Chain c
JOIN Users u ON c.chain_id = u.chain_idFK
JOIN LiquidityPool lp ON c.chain_id = lp.chain_idFK
GROUP BY c.chain_name;

-- Show users that currently are in a Liquidity Pool
CREATE OR REPLACE PROCEDURE printUsersInLPs IS
    CURSOR getUsersInLP IS
    SELECT user_addressFK, lp_addressFK
    FROM UsersToLP WHERE lp_addressFK <> NULL
    ORDER BY lp_addressFK;

    BEGIN
        DBMS_OUTPUT.ENABLE;
        FOR userInlp IN getUsersInLP LOOP
            DBMS_OUTPUT.PUT_LINE ('User: ' || userInlp.user_addressFK || ' '  || userInlp.lp_addressFK);
        END LOOP;
    END;

-- Recursively selects rows from the LiquidityPool table 
WITH RatioMaxUsersLP(lp_address, expectedAmountPerUser, valueRetained, maxUsers, chain_idFK, ratio) AS 
(
    SELECT lp_address, expectedAmountPerUser, valueRetained, maxUsers, chain_idFK, 0 AS ratio 
    FROM LiquidityPool
    UNION ALL
    SELECT lp.lp_address, lp.expectedAmountPerUser, lp.valueRetained, lp.maxUsers, lp.chain_idFK, oldRatio.ratio + 1
    FROM RatioMaxUsersLP oldRatio
    INNER JOIN LiquidityPool lp
    ON lp.chain_idFK = oldRatio.chain_idFK AND lp.lp_address = oldRatio.lp_address
    WHERE (lp.valueRetained > oldRatio.valueRetained + 0.5) AND oldRatio.ratio < 100
)
SELECT lp_address, expectedAmountPerUser, valueRetained, maxUsers, chain_idFK, ratio FROM RatioMaxUsersLP;

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


--  Object Extension Section

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
