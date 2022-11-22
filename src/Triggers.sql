CREATE TRIGGER verifyNetwork
    AFTER DELETE ON Transaction
        WHEN (User.address_network_USER <> LiquidityPool.address_network_LP)
            BEGIN ATOMIC
                DROP TABLE Transaction
            END; -- VERIFY TRIGGER

CREATE TRIGGER verifyAmount
    AFTER DELETE ON Transaction
        WHEN (Transaction.transaction_amount <> LiquidityPool.expectedAmountPerUser)
            BEGIN ATOMIC
                DROP TABLE Transaction
            END;
