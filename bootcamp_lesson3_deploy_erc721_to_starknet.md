# （BootCamp Lesson3）在 Starknet 测试网上部署 ERC-721 代币

![2023-06-11 20.15.07](ipfs://bafkreibsamvrlqodpjm3sza5scxeo3xput35fl4imosj7py7k452h654u4)


## 简介
本课程作为一个快速上手的BootCamp将不会过于深入的讲解Cairo语言的特性（但我们最后一节课将稍微深入的介绍一下Cairo语言其他有用的部分）。

如果你想提前深入学习Cairo，可以查看我们最近翻译的[Cairo-Book中文版](https://cairo-book.github.io/zh-cn/index.html) 。


## 环境配置

**最小安装选项：**
这次的课程要求你已经安装了我们在[第一节课](https://starknetastro.xlog.app/cairosetup) 所要求安装的Cairo 1.0，以及Starknet的Cairo 0.x CLI的所有所需依赖。
注意！由于DevNet的升级，导致现在只支持`starknet-compile 1.1.0`，因此你需要将Cairo 1.0升级到v1.1.0。
在你安装Cairo的目录下执行如下命令：

```
git checkout 4020f7b3
git pull
cargo build --all --release
```

**注意：以下步骤和上节课类似。已经完成配置的同学可以直接跳转到[ERC721代码模版](#erc721-代码模版)**

### 安装CLI
为了方便操作让我们先进入Cairo 1.0的根目录（此处参照你上节课装1.0时的目录，比如我的就是如下所示）

    cd ~/cairo/

创建一个camp1_lesson3文件夹：

    mkdir -p starknetastro/camp1_lesson3/
    cd starknetastro/camp1_lesson3/

接着创建一个python虚拟环境：

    python3.9 -m venv  venv

启动虚拟环境：

    source venv/bin/activate

此时你应该可以看到终端的前面带上了一个（venv）。让我们安装CLI

    (venv) camp1 $ pip install cairo-lang

检验是否安装成功

    (venv) camp1 $ starknet --version

这里应该输出：

    starknet 0.11.2



### 配置Starknet测试网账户
接下来我们来配置测试网账户。首先先定义几个环境变量如下：

```
# 指定测试网
export STARKNET_NETWORK=alpha-goerli


# 设定默认钱包实现
export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount


# 指定编译器路径为Cairo 1的路径（请按照你自己的路径修改）
export CAIRO_COMPILER_DIR=~/cairo/target/release/

```

之后你可以将这个保存进你的 `.zshrc`或者 `.bashrc`，方便关闭termianl之后依然可以使用环境变量。方法此处不再赘述。

我们用以下两个命令来测试
```
(venv) $ $CAIRO_COMPILER_DIR/cairo-compile --version
cairo-compile 1.1.0
(venv) $ $CAIRO_COMPILER_DIR/starknet-compile --version
starknet-compile 1.1.0
```
两者都输出1.1.0表示环境配置正确。

### 创建测试网的钱包
接着我们来创建一个测试网上的钱包：

    starknet new_account --account StarknetAstro

这里应该会输出
```
Account address: 0x你的地址
Public key: 0x你的公钥

Move the appropriate amount of funds to the account, and then deploy the account
by invoking the 'starknet deploy_account' command.

NOTE: This is a modified version of the OpenZeppelin account contract. The signature is computed
differently.
```

接着我们需要在测试网上部署它。在Starknet中部署也是一次交易，所以需要gas。我们通过跨链桥或者[官方Faucet](https://faucet.goerli.starknet.io/)给`0x你的地址` 发送一些测试用eth。


![スクリーンショット 2023-06-02 21.12.07](ipfs://bafybeic7zngebocrpczkjbocqemx26pybyvb7rzviqr3aieibjlrkrxhpu)

然后使用此命令部署


    starknet deploy_account --account StarknetAstro

输出：
```
Sending the transaction with max_fee: 0.000114 ETH (113796902644445 WEI).
Sent deploy account contract transaction.

Contract address: 0x你的地址
Transaction hash: 0x交易地址
```
## 部署测试

让我们先来用测试合约来尝试一下是否能够正常部署。
执行如下命令：

```
mkdir src sierra
touch src/example.cairo
```
之后，在 `src/example.cairo` 中填入测试内容：
```
#[starknet::contract]

mod SimpleStorage {
    #[storage]
    struct Storage {
    }
}
```

接着我们将cairo文件编译成sierra文件：

    $CAIRO_COMPILER_DIR/starknet-compile src/example.cairo sierra/example.json

编译成功后，我们需要先声明一下合约的ClassHash：
```
starknet declare --contract sierra/example.json --account StarknetAstro
```

当然，由于相同的ClassHash不能多次声明，这个测试用合约也早已被声明过，因此你会得到一个已经被声明的错误输出，这是没有问题的：
```
Got BadRequest while trying to access https://alpha4.starknet.io/feeder_gateway/simulate_transaction?blockNumber=pending&skipValidate=false. Status code: 500;
text: {"code": "StarknetErrorCode.CLASS_ALREADY_DECLARED",
"message": "Class with hash 0x695874cd8feed014ebe379df39aa0dcef861ff495cc5465e84927377fa8e7e6
is already declared.
0x317d3ac2cf840e487b6d0014a75f0cf507dff0bc143c710388e323487089bfa != 0”}.
```
接着我们来实际部署合约的instance：
```
starknet deploy --class_hash 0x695874cd8feed014ebe379df39aa0dcef861ff495cc5465e84927377fa8e7e6 --account StarknetAstro
```
输出如下：
```
Sending the transaction with max_fee: 0.000132 ETH (132082306595047 WEI).
Invoke transaction for contract deployment was sent.
Contract address: 0x060e17c12d4e3fee8af2e28e6a310a3192a1b1190d060cb4324e234213d72b64
Transaction hash: 0x73f995d1fd9a05161e271f5ffb879bd70b79185a2b3de5536a289780387dd30
```
这表明实际部署成功了！你可以在这里看到我们[部署的合约](https://testnet.starkscan.co/contract/0x060e17c12d4e3fee8af2e28e6a310a3192a1b1190d060cb4324e234213d72b64)。


## ERC721代码模版

将下面的erc721.cairo保存在上面创建的 `src`中 ，方便终端操作。

文件名：erc721.cairo
```
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


```

## 部署ERC721

首先我们依然需要编译cairo文件到sierra
```
$CAIRO_COMPILER_DIR/starknet-compile src/erc721.cairo sierra/erc721.json
```
接下来是声明
```
starknet declare --contract sierra/erc721.json --account StarknetAstro
```
这次的输出不一样了，因为我们编写的这个erc20文件还没有人部署过，因此不会出现错误（当然，照着课程做的同学们还是会遇上已经被声明的错误）。

```
Sending the transaction with max_fee: 0.000001 ETH (1378300016540 WEI).
Declare transaction was sent.
Contract class hash: 0x232f6df73a376998769e0571aa14281dc2e8a6f2dce0578e4c45741392a2b37
Transaction hash: 0x24b19a2b7b9663699ce134ce29bd03cf8f17e7cb17a30ab19509fcdc568f27f
```

接着则是Deploy这个erc721合约的instance。注意erc721代码中的构造函数是有参数的，因此我们也需要给出相应的参数：

```
starknet deploy --inputs 0x417374726F546F6B656E 0x417374726F --class_hash 0x232f6df73a376998769e0571aa14281dc2e8a6f2dce0578e4c45741392a2b37 --account StarknetAstro
```

输出为：

```
Sending the transaction with max_fee: 0.000006 ETH (6121500073459 WEI).
Invoke transaction for contract deployment was sent.
Contract address: 0x051566565f452d8dc645f7aaa4f232c935ce0f89d98f7663c094261c04748dfb
Transaction hash: 0x36d8fc6b9dfece81d2804c563fd000b5b5cb8f0f704d978b7a2c1623e390d08
```
大功告成！你可以在这里看到我们 [部署的合约](https://testnet.starkscan.co/contract/0x051566565f452d8dc645f7aaa4f232c935ce0f89d98f7663c094261c04748dfb)
