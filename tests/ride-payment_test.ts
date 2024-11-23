import {
    Clarinet,
    Tx,
    Chain,
    Account,
    types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Test ride creation and completion flow",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const driver = accounts.get('wallet_1')!;
        const passenger = accounts.get('wallet_2')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('ride-payment', 'create-ride', [
                types.uint(1),
                types.principal(driver.address),
                types.principal(passenger.address),
                types.uint(100)
            ], deployer.address),
            
            Tx.contractCall('ride-payment', 'get-ride-details', [
                types.uint(1)
            ], deployer.address)
        ]);
        
        block.receipts[0].result.expectOk();
        
        let block2 = chain.mineBlock([
            Tx.contractCall('ride-payment', 'complete-ride', [
                types.uint(1)
            ], driver.address)
        ]);
        
        block2.receipts[0].result.expectOk();
    }
});

Clarinet.test({
    name: "Test payment flow",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const driver = accounts.get('wallet_1')!;
        const passenger = accounts.get('wallet_2')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('ride-payment', 'create-ride', [
                types.uint(1),
                types.principal(driver.address),
                types.principal(passenger.address),
                types.uint(100)
            ], deployer.address),
            
            Tx.contractCall('ride-payment', 'complete-ride', [
                types.uint(1)
            ], driver.address),
            
            Tx.contractCall('ride-payment', 'pay-ride', [
                types.uint(1)
            ], passenger.address)
        ]);
        
        block.receipts[2].result.expectOk();
        
        let statusBlock = chain.mineBlock([
            Tx.contractCall('ride-payment', 'get-ride-status', [
                types.uint(1)
            ], deployer.address)
        ]);
        
        statusBlock.receipts[0].result.expectOk().expectTuple()['paid'].expectBool(true);
    }
});
