use starknet::ContractAddress;

#[starknet::interface]
trait IERC20<TStorage> {
    fn name(self: @TStorage) -> felt252;
    fn symbol(self: @TStorage) -> felt252;
    fn decimals(self: @TStorage) -> u8;
    fn totalSupply(self: @TStorage) -> u256;
    fn balanceOf(self: @TStorage, account: ContractAddress) -> u256;
    fn allowance(self: @TStorage, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(ref self: TStorage, recipient: ContractAddress, amount: u256);
    fn transferFrom(
        ref self: TStorage, sender: ContractAddress, recipient: ContractAddress, amount: u256
    );
    fn approve(ref self: TStorage, spender: ContractAddress, amount: u256);
    fn increase_allowance(ref self: TStorage, spender: ContractAddress, added_value: u256);
    fn decrease_allowance(ref self: TStorage, spender: ContractAddress, subtracted_value: u256);
}

#[contract]
mod ERC20 {
    use zeroable::Zeroable;
    use starknet::get_caller_address;
    use starknet::contract_address_const;
    use starknet::ContractAddress;

    #[starknet::storage]
    struct Storage {
        name: felt252,
        symbol: felt252,
        decimals: u8,
        totalSupply: u256,
        balances: LegacyMap::<ContractAddress, u256>,
        allowances: LegacyMap::<(ContractAddress, ContractAddress), u256>,
    }

    #[event]
    fn Transfer(from: ContractAddress, to: ContractAddress, value: u256) {}

    #[event]
    fn Approval(owner: ContractAddress, spender: ContractAddress, value: u256) {}

    #[constructor]
    fn constructor(
        ref self: Storage,
        name: felt252,
        symbol: felt252,
        decimals: u8,
        initialSupply: u256,
        recipient: ContractAddress
    ) {
        self.name.write(name);
        self.symbol.write(symbol);
        self.decimals.write(decimals);
        assert(!recipient.is_zero(), 'ERC20: mint to the 0 address');
        self.totalSupply.write(initialSupply);
        self.balances.write(recipient, initialSupply);
    }

    #[external]
    impl IERC20Impl of super::IERC20<Storage> {
        fn name(self: @Storage) -> felt252 {
            self.name.read()
        }

        fn symbol(self: @Storage) -> felt252 {
            self.symbol.read()
        }

        fn decimals(self: @Storage) -> u8 {
            self.decimals.read()
        }

        fn totalSupply(self: @Storage) -> u256 {
            self.totalSupply.read()
        }

        fn balanceOf(self: @Storage, account: ContractAddress) -> u256 {
            self.balances.read(account)
        }

        fn allowance(self: @Storage, owner: ContractAddress, spender: ContractAddress) -> u256 {
            self.allowances.read((owner, spender))
        }

        fn transfer(ref self: Storage, recipient: ContractAddress, amount: u256) {
            let sender = get_caller_address();
            self.transfer_helper(sender, recipient, amount);
        }

        fn transferFrom(
            ref self: Storage, sender: ContractAddress, recipient: ContractAddress, amount: u256
        ) {
            let caller = get_caller_address();
            self.transfer_helper(sender, recipient, amount);
        }

        fn approve(ref self: Storage, spender: ContractAddress, amount: u256) {
            let caller = get_caller_address();
            self.approve_helper(caller, spender, amount);
        }

        fn increase_allowance(ref self: Storage, spender: ContractAddress, added_value: u256) {
            let caller = get_caller_address();
            self
                .approve_helper(
                    caller, spender, self.allowances.read((caller, spender)) + added_value
                );
        }

        fn decrease_allowance(ref self: Storage, spender: ContractAddress, subtracted_value: u256) {
            let caller = get_caller_address();
            self
                .approve_helper(
                    caller, spender, self.allowances.read((caller, spender)) - subtracted_value
                );
        }
    }

    #[generate_trait]
    impl StorageImpl of StorageTrait {
        fn transfer_helper(
            ref self: Storage, sender: ContractAddress, recipient: ContractAddress, amount: u256
        ) {
            assert(!sender.is_zero(), 'ERC20: transfer from 0');
            assert(!recipient.is_zero(), 'ERC20: transfer to 0');
            self.balances.write(sender, self.balances.read(sender) - amount);
            self.balances.write(recipient, self.balances.read(recipient) + amount);
            Transfer(sender, recipient, amount);
        }

        fn approve_helper(
            ref self: Storage, owner: ContractAddress, spender: ContractAddress, amount: u256
        ) {
            assert(!spender.is_zero(), 'ERC20: approve from 0');
            self.allowances.write((owner, spender), amount);
            Approval(owner, spender, amount);
        }
    }
}
