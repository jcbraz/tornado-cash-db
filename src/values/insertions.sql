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
    Chain
VALUES
    (
        10,
        'OPTIMISM',
        'https://mainnet.optimism.io',
        'OP',
        'https://optimistic.etherscan.io'
    )

INSERT INTO
    Users
VALUES
    (
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba8',
        100,
        '{
            "Hash": "0x5ca21bdbc9b261bc5e6e91e3d9c11c332cd2d4c331e76f192cd93ca2b0c330fe",
            "Status": "Sucess",
            "Block": 15528229,
            "Timestamp": "Sep-13-2022 05:33:55 PM +UTC",
            "Source": "0x21a31ee1afc51d94c2efccaa2092ad1028285549",
            "Destination": "0xbb6ba66a466ef9f31cc44c8a0d9b5c84c49a4ba8",
            "Value": 0.45848,
            "Fee": {
                "Payed": 0.000252718733085,
                "Base": 0.0000000119,
                "Max": 0.0000001214,
                "Max Priority": 0.00000000238
            },
            "Prices": {
                "Gas Price": 0.000000012034225385,
                "Ether Price": 1574.56
            }
        }',
        1
    );

INSERT INTO
    Users
VALUES
    (
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba4',
        4.2,
        '{
            "Hash": "0x68ea9bf0294e78fc85d5fb36eefc4f4885476734be834822f71463c8b4d7a7ef",
            "Status": "Sucess",
            "Block": 14782178,
            "Timestamp": "May-15-2022 08:57:30 PM +UTC",
            "Source": "0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba4",
            "Destination": "0x6399c842dd2be3de30bf99bc7d1bbf6fa3650e70",
            "Value": 0.00,
            "Fee": {
                "Payed": 0.000715778485058286,
                "Base": 0.0000000302,
                "Max": 0.0000000386,
                "Max Priority": 0.00000000179
            },
            "Prices": {
                "Gas Price": 0.000000026902897281,
                "Ether Price": 2143.12
            }
        }',
        1
    );

INSERT INTO
    Users
VALUES
    (
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ll1',
        0.1,
        '{
            "Hash": "0x5ca21bdbc,
            "Status": "Sucess",
            "Block": 15528229,
            "Timestamp": "Sep-13-2022 05:33:55 PM +UTC",
            "Source": "0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ll1",
            "Destination": "0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c46G4ga1",
            "Value": 0.45848,
            "Fee": {
                "Payed": 0.011252718733085,
                "Base": 0.009119012312,
                "Max": 0.1813135433,
                "Max Priority": 0.20000000238
            },
            "Prices": {
                "Gas Price": 0.01543212132,
                "OP Price": 1.09"
            }
        }',
        10
    );

INSERT INTO
    Users
VALUES
    (
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4df3',
        0.1,
        '{
            "Hash": "0x5ca21bdbc,
            "Status": "Sucess",
            "Block": 15528229,
            "Timestamp": "Sep-13-2022 05:33:55 PM +UTC",
            "Source": "0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4df3",
            "Destination": "0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c46G4ga1",
            "Value": 89.45848,
            "Fee": {
                "Payed": 0.011252718733085,
                "Base": 0.009119012312,
                "Max": 0.1813135433,
                "Max Priority": 0.20000000238
            },
            "Prices": {
                "Gas Price": 0.01543212132,
                "OP Price": 1.21"
            }
        }',
        10
    );


INSERT INTO
    LiquidityPool
VALUES
    (
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1',
        15,
        0.1,
        10,
        '{
            "Hash": "0x5ca21bdbc9b261bc5e6e91e3d9c11c332cd2d4c331e76f192cd93ca2b0c330ff",
            "Status": "Sucess",
            "Block": 15528241,
            "Timestamp": "Sep-13-2022 05:33:55 PM +UTC",
            "Source": "0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1",
            "Destination": "0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba4",
            "Value": 0.45848,
            "Fee": {
                "Payed": 0.000252718733085,
                "Base": 0.0000000119,
                "Max": 0.0000001214,
                "Max Priority": 0.00000000238
            },
            "Prices": {
                "Gas Price": 0.000000012034225385,
                "Ether Price": 1574.56
            }
        }',
        1
    );


INSERT INTO
    LiquidityPool
VALUES
    (
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bh9',
        20,
        1,
        20,
        '{
            "Hash": "0x5ca21bdbc9b261bc5e6e91e3d9c11c332cd2d4c331e76f192cd93ca2b0c330fh",
            "Status": "Sucess",
            "Block": 15528244,
            "Timestamp": "Sep-13-2022 05:33:55 PM +UTC",
            "Source": "0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1",
            "Destination": "0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba4",
            "Value": 0.45848,
            "Fee": {
                "Payed": 0.000252718733085,
                "Base": 0.0000000119,
                "Max": 0.0000001214,
                "Max Priority": 0.00000000238
            },
            "Prices": {
                "Gas Price": 0.000000012034225385,
                "Ether Price": 1574.56
            }
        }',
        1
    );

INSERT INTO
    LiquidityPool
VALUES
    (
        '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb2',
        15,
        0.1,
        10,
        '{
            "Hash": "0x5ca21bdbc9b261bc5e6e91e3d9c11c332cd2d4c331e76f192cd93ca2b0c33312",
            "Status": "Sucess",
            "Block": 15528242,
            "Timestamp": "Sep-13-2022 05:33:55 PM +UTC",
            "Source": "0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb2",
            "Destination": "0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba4",
            "Value": 0.45848,
            "Fee": {
                "Payed": 0.000252718733085,
                "Base": 0.0000000119,
                "Max": 0.0000001214,
                "Max Priority": 0.00000000238
            },
            "Prices": {
                "Gas Price": 0.000000012034225385,
                "OP Price": 1.56
            }
        }',
        10
    );


INSERT INTO
    UsersToLP(user_addressFK)
VALUES
    ('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba8');

INSERT INTO
    UsersToLP(user_addressFK)
VALUES
    ('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba4');

INSERT INTO
    UsersToLP(user_addressFK)
VALUES
    ('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ll1');

INSERT INTO
    UsersToLP(user_addressFK)
VALUES
    ('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4df3');

-- Testing (Done in order of implementation in the TornadoCash.sql file)

-- Function getUserWalletBalance
SELECT GETUSERWALLETBALANCE('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba8') FROM DUAL;

-- Function getNumberUserLP
SELECT GETNUMBERUSERLP('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1') FROM DUAL;

-- Declare Triggers present in the TornadoCash.sql file

-- Trigger secureValueIntegrityUser
UPDATE Users SET valueOnWallet = -1 WHERE user_address = '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba8';

-- Trigger secureValueIntegrityLP
UPDATE LiquidityPool SET valueRetained = -1 WHERE lp_address = '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1';

-- Trigger secureValueIntegrityUsersToLP
UPDATE UsersToLP SET user_addressFK = '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba8' WHERE transaction_id = 1;

-- Trigger secureIntegrityDeposits
UPDATE UsersToLP SET lp_addressFK = NULL WHERE transaction_id = 1;

-- Trigger secureIntegrityEncryptedNote
UPDATE UsersToLP SET encrypted_note = NULL WHERE lp_addressFK = '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1';

-- Trigger transactionsLPControl
-- Check thought the execution of the Procedure joinLiquiidtyPool & leaveLiquidityPool

-- Procedure joinLiquidityPool
BEGIN
  JOINLIQUIDITYPOOL('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba4', '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1');
END;

SELECT * FROM USERS;

-- Procedure leaveLiquidityPool
UPDATE LIQUIDITYPOOL SET maxUsers = 1 WHERE LP_ADDRESS = '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1';

BEGIN
  LEAVELIQUIDITYPOOL('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1');
END;

SELECT * FROM USERS;
SELECT * FROM USERSTOLP;


-- Procedure printUsersInLPs
SET SERVEROUTPUT ON;
BEGIN
    PRINTUSERSPERLP;
END;

-- Recursive View recursiveLPchain
SELECT lp_address, chain_idFK FROM recursiveLPchain;


-- Trigger secureTranscationDataUser (JSON)
UPDATE Users SET transaction_history = '{
    "Hash": "0x68ea9bf0294e78fc85d5fb36eefc4f4885476734be834822f71463c8b4d7a7ef",
    "Status": "Sucess",
    "Block": 14782178,
    "Timestamp": "May-15-2022 08:57:30 PM +UTC",
    "Source": "0xbb6ba66a466ef9f31cc44c8a0d9b5c84c49a4bm9",
    "Destination": "0x6399c842dd2be3de30bf99bc7d1bbf6fa3650e70",
    "Value": 0.00,
    "Fee": {
        "Payed": 0.000715778485058286,
        "Base": 0.0000000302,
        "Max": 0.0000000386,
        "Max Priority": 0.00000000179
    },
    "Prices": {
        "Gas Price": 0.000000026902897281,
        "Ether Price": 2143.12
    }
}' WHERE user_address = '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba8';

-- Trigger secureTranscationDataLP (JSON)
UPDATE LiquidityPool SET transaction_history = '{
    "Hash": "0x5ca21bdbc9b261bc5e6e91e3d9c11c332cd2d4c331e76f192cd93ca2b0c330fh",
    "Status": "Sucess",
    "Block": 15528244,
    "Timestamp": "Sep-13-2022 05:33:55 PM +UTC",
    "Source": "0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4l6",
    "Destination": "0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba4",
    "Value": 0.45848,
    "Fee": {
        "Payed": 0.000252718733085,
        "Base": 0.0000000119,
        "Max": 0.0000001214,
        "Max Priority": 0.00000000238
    },
    "Prices": {
        "Gas Price": 0.000000012034225385,
        "Ether Price": 1574.56
    }
}' WHERE lp_address = '0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4bb1';

-- Nested Table
INSERT INTO Rating(rating_time) VALUES (TO_DATE('17/12/2015', 'DD/MM/YYYY'));

UPDATE Rating
    SET unbanned_users = rated_users(rated_user('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba8', 'false')),
        banned_users = rated_users(rated_user('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba4', 'true'))
    WHERE rating_time = TO_DATE('17/12/2015', 'DD/MM/YYYY');

SELECT * FROM Rating;
