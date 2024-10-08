#[starknet::interface]
trait IFossilClient<TState> {
    fn fossil_callback(self: @TState, job_id: felt252, fossil_result: Array<felt252>);
}

#[starknet::interface]
trait IPitchlakeVault<TState> {
    fn fossil_client_callback(self: @TState, job_id: felt252, fossil_result: Array<felt252>);
}

#[starknet::contract]
mod FossilClient {
    use starknet::storage::StoragePointerWriteAccess;
    use super::{IFossilClient, IPitchlakeVaultDispatcher, IPitchlakeVaultDispatcherTrait};
    use starknet::ContractAddress;

    #[storage]
    struct Storage {
        fossil_processor: ContractAddress,
        vault: ContractAddress,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState, fossil_processor: ContractAddress, vault: ContractAddress
    ) {
        self.fossil_processor.write(fossil_processor);
        self.vault.write(vault);
    }

    #[abi(embed_v0)]
    impl FossilClientImpl of IFossilClient<ContractState> {
        fn fossil_callback(self: @ContractState, job_id: felt252, fossil_result: Array<felt252>) {
            assert!(
                starknet::get_caller_address() == self.fossil_processor.read(),
                "Only fossil processor can call this"
            );

            let vault = IPitchlakeVaultDispatcher{contract_address: self.vault.read()};
            vault.fossil_client_callback(job_id, fossil_result);
        }
    }
}
