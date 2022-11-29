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


-- Nested Table
INSERT INTO Rating(rating_time) VALUES (TO_DATE('17/12/2015', 'DD/MM/YYYY'));

UPDATE Rating
    SET unbanned_users = rated_users(rated_user('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba8', 'false')),
        banned_users = rated_users(rated_user('0xbb6ba66A466Ef9f31cC44C8A0D9b5c84c49A4ba4', 'true'))
    WHERE rating_time = TO_DATE('17/12/2015', 'DD/MM/YYYY');

-- Testing Nested Table
SELECT * FROM Rating;