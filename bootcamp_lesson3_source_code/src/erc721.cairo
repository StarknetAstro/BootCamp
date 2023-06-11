use starknet::ContractAddress;

#[starknet::interface]
trait IERC721<TStorage> {
    fn name(self: @TStorage) -> felt252;
    fn symbol(self: @TStorage) -> felt252;
    fn approve(ref self: TStorage, to: ContractAddress, tokenId: u256);
    // camelCase
    fn balanceOf(self: @TStorage, account: ContractAddress) -> u256;
    fn ownerOf(self: @TStorage, tokenId: u256) -> ContractAddress;
    fn transferFrom(
        ref self: TStorage, from: ContractAddress, to: ContractAddress, tokenId: u256
    );
    fn safeTransferFrom(
        ref self: TStorage, from: ContractAddress, to: ContractAddress, tokenId: u256, data: Span<felt252>
    );
    fn setApprovalForAll(ref self: TStorage, operator: ContractAddress, approved: bool);
    fn getApproved(self: @TStorage, tokenId: u256) -> ContractAddress;
    fn isApprovedForAll(self: @TStorage, owner: ContractAddress, operator: ContractAddress) -> bool;
    fn tokenUri(self: @TStorage, tokenId: u256) -> felt252;
}

#[starknet::contract]
mod ERC721 {

    // Other
    use zeroable::Zeroable;
    use starknet::get_caller_address;
    use starknet::contract_address_const;
    use starknet::ContractAddress;
    use option::OptionTrait;
    use array::SpanTrait;
    use traits::Into;

    #[storage]
    struct Storage {
        name: felt252,
        symbol: felt252,
        owners: LegacyMap<u256, ContractAddress>,
        balances: LegacyMap<ContractAddress, u256>,
        token_approvals: LegacyMap<u256, ContractAddress>,
        operator_approvals: LegacyMap<(ContractAddress, ContractAddress), bool>,
        token_uri: LegacyMap<u256, felt252>,
    }

    #[event]
    fn Transfer(from: ContractAddress, to: ContractAddress, token_id: u256) {}

    #[event]
    fn Approval(owner: ContractAddress, approved: ContractAddress, token_id: u256) {}

    #[event]
    fn ApprovalForAll(owner: ContractAddress, operator: ContractAddress, approved: bool) {}

    #[constructor]
    fn constructor(ref self: Storage, name_: felt252, symbol_: felt252) {
        self.name.write(name_);
        self.symbol.write(symbol_);
    }

    #[external(v0)]
    impl IERC721Impl of super::IERC721<Storage> {
        fn name(self: @Storage) -> felt252 {
            self.name.read()
        }

        fn symbol(self: @Storage) -> felt252 {
            self.symbol.read()
        }

        fn tokenUri(self: @Storage, tokenId: u256) -> felt252 {
            self.token_uri.read(tokenId)
        }

        fn balanceOf(self: @Storage, account: ContractAddress) -> u256 {
            self.balances.read(account)
        }

        fn ownerOf(self: @Storage, tokenId: u256) -> ContractAddress {
            let owner = self.owners.read(tokenId);
            match owner.is_zero() {
                bool::False(()) => owner,
                bool::True(()) => panic_with_felt252('ERC721: invalid token ID')
            }
        }

        fn approve(ref self: Storage, to: ContractAddress, tokenId: u256) {
            self.approve_helper(to, tokenId)
        }

        fn getApproved(self: @Storage, tokenId: u256) -> ContractAddress {
            self.token_approvals.read(tokenId)
        }

        fn isApprovedForAll(self: @Storage, owner: ContractAddress, operator: ContractAddress) -> bool {
            self.operator_approvals.read((owner, operator))
        }

        fn setApprovalForAll(ref self: Storage, operator: ContractAddress, approved: bool) {
            self.approval_for_all_helper(get_caller_address(), operator, approved)
        }

        fn transferFrom(ref self: Storage, from: ContractAddress, to: ContractAddress, tokenId: u256) {
            self.transfer_helper(from, to, tokenId);
        }

        fn safeTransferFrom(
            ref self: Storage, from: ContractAddress, to: ContractAddress, tokenId: u256, data: Span<felt252>
        ) {
            self.safe_transfer_helper(from, to, tokenId, data);
        }
    }

    #[generate_trait]
    impl StorageImpl of StorageTrait {
        fn transfer_helper(
            ref self: Storage, from: ContractAddress, to: ContractAddress, token_id: u256
        ) {
            assert(!to.is_zero(), 'ERC721: invalid receiver');
            let owner = self.owners.read(token_id);
            assert(from == owner, 'ERC721: wrong sender');

            // Implicit clear approvals, no need to emit an event
            self.token_approvals.write(token_id, Zeroable::zero());

            // Update balances
            self.balances.write(from, self.balances.read(from) - 1);
            self.balances.write(to, self.balances.read(to) + 1);

            // Update token_id owner
            self.owners.write(token_id, to);

            // Emit event
            Transfer(from, to, token_id);
        }

        fn safe_transfer_helper(
            ref self: Storage, from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>
        ) {
            self.transfer_helper(from, to, token_id);
        
        }

        fn approve_helper(
            ref self: Storage, to: ContractAddress, token_id: u256
        ) {
            let owner = self.owners.read(token_id);
            assert(owner != to, 'ERC721: approval to owner');
            assert(!owner.is_zero(), 'ERC721: invalid token ID');
            self.token_approvals.write(token_id, to);
            Approval(owner, to, token_id);
        }

        fn approval_for_all_helper(ref self: Storage, owner: ContractAddress, operator: ContractAddress, approved: bool) {
            assert(owner != operator, 'ERC721: self approval');
            self.operator_approvals.write((owner, operator), approved);
            ApprovalForAll(owner, operator, approved);
        }

        fn exists_helper(self: @Storage, token_id: u256) -> bool {
            !self.owners.read(token_id).is_zero()
        }
    }

    #[external]
    fn mint(ref self: Storage, to: ContractAddress, token_id: u256) {
        assert(!to.is_zero(), 'ERC721: invalid receiver');
        assert(!self.exists_helper(token_id), 'ERC721: token already minted');

        // Update balances
        self.balances.write(to, self.balances.read(to) + 1);

        // Update token_id owner
        self.owners.write(token_id, to);

        // Emit event
        Transfer(Zeroable::zero(), to, token_id);
    }

}



