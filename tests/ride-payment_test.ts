[Previous test imports and positive test cases remain unchanged]

Clarinet.test({
    name: "Test invalid ride creation scenarios",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const driver = accounts.get('wallet_1')!;
        const passenger = accounts.get('wallet_2')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('ride-payment', 'create-ride', [
                types.uint(1),
                types.principal(driver.address),
                types.principal(passenger.address),
                types.uint(0)  // Invalid fare
            ], deployer.address)
        ]);
        
        block.receipts[0].result.expectErr(110); // err-invalid-fare
        
        // Test duplicate ride creation
        let block2 = chain.mineBlock([
            Tx.contractCall('ride-payment', 'create-ride', [
                types.uint(1),
                types.principal(driver.address),
                types.principal(passenger.address),
                types.uint(100)
            ], deployer.address),
            
            Tx.contractCall('ride-payment', 'create-ride', [
                types.uint(1),
                types.principal(driver.address),
                types.principal(passenger.address),
                types.uint(100)
            ], deployer.address)
        ]);
        
        block2.receipts[0].result.expectOk();
        block2.receipts[1].result.expectErr(109); // err-ride-exists
    }
});

[Remaining test cases unchanged]
