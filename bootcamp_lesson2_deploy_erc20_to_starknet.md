# （BootCamp Lesson2）在 Starknet 测试网上部署 ERC-20 代币

![WechatIMG691](ipfs://bafybeieodf46rumntntlfcofeuw3o3xcpibhekt57id2c2nnm5e63367tm)

## 简介
本课程作为一个快速上手的BootCamp将不会过于深入的讲解Cairo语言的特性（但我们最后一节课将稍微深入的介绍一下Cairo语言其他有用的部分）。

如果你想提前深入学习Cairo，可以查看我们最近翻译的[Cairo-Book中文版](https://cairo-book.github.io/zh-cn/index.html) 。


## 环境配置

**最小安装选项：**
这次的课程要求你已经安装了我们在[上一节课](https://starknetastro.xlog.app/cairosetup) 所要求安装的Cairo 1.0，以及Starknet的Cairo 0.x CLI的所有所需依赖。
注意！由于DevNet的升级，导致现在只支持`starknet-compile 1.1.0`，因此你需要将Cairo 1.0升级到v1.1.0。
在你安装Cairo的目录下执行如下命令：

```
git checkout main
cargo build --all --release
```

此外，根据上节课的反馈，很多同学在安装python后依然无法正常编译，在这里给出一些常见问题的解决方法：
1. `linker 'cc' not found`，找不到cc的链接器，可用下面方案解决。

```
sudo apt install build-essential
```
当然为了以防万一，可以直接来一整套：
```
sudo apt-get install build-essential libncursesw5-dev libgdbm-dev libc6-dev zlib1g-dev libsqlite3-dev tk-dev libssl-dev openssl libbz2-dev libreadline-dev
```

2. `ModuleNotFoundError: No module named '_ctypes'`
解决方案比较麻烦，要重新安装python。

```
pyenv uninstall 3.9.16
sudo yum install libffi-devel
pyenv install 3.9.16
```

3. `use_2to3 is invalid.`有时候会莫名奇妙发生。
```
pip install -U setuptools
```


### 安装CLI
为了方便操作让我们先进入Cairo 1.0的根目录（此处参照你上节课装1.0时的目录，比如我的就是如下所示）

    cd ~/cairo/

创建一个test文件夹()：

    mkdir -p starknetastro/camp1_lesson2/
    cd starknetastro/camp1_lesson2/

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
#[contract]

mod SimpleStorage {
    #[starknet::storage]
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


## ERC20代码模版

将下面的erc20.cairo保存在上面创建的 `src`中 ，方便终端操作。

文件名：erc20.cairo
```
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


```

## 部署ERC20

首先我们依然需要编译cairo文件到sierra
```
$CAIRO_COMPILER_DIR/starknet-compile src/erc20.cairo sierra/erc20.json
```
接下来是声明
```
starknet declare --contract sierra/erc20.json --account StarknetAstro
```
这次的输出不一样了，因为我们编写的这个erc20文件还没有人部署过，因此不会出现错误（当然，照着课程做的同学们还是会遇上已经被声明的错误）。

```
Sending the transaction with max_fee: 0.000101 ETH (101461098713976 WEI).
Declare transaction was sent.
Contract class hash: 0x5d144ad5b9af2752da0ef741b565d334a1cb18d02224462d978ebf0a6e8e919
Transaction hash: 0x21da071ce36db1544f482150a8b99902ca1b5db090b66618de724362408ea00
```

接着则是Deploy这个erc20合约的instance。注意erc20代码中的构造函数是有参数的，因此我们也需要给出相应的参数：

```
starknet deploy --inputs 0x417374726F546F6B656E 0x417374726F 0x12 0x3e8 0x0 0x04202409943437c6ebe83697e1ba183976912b667066db7b8796064e59426b0e --class_hash 0x5d144ad5b9af2752da0ef741b565d334a1cb18d02224462d978ebf0a6e8e919 --account StarknetAstro
```

输出为：

```
Sending the transaction with max_fee: 0.000791 ETH (790973560660141 WEI).
Invoke transaction for contract deployment was sent.
Contract address: 0x059128b7b3001106211376c12ee86feedd9247033cd1a771e8957efac3b61ca8
Transaction hash: 0x4bcf2d5f9a2e2090755d7a07d2849d4e5cf13fbdd36befd4f73d2030cea392c
```
大功告成！你可以在这里看到我们 [部署的合约](https://testnet.starkscan.co/contract/0x059128b7b3001106211376c12ee86feedd9247033cd1a771e8957efac3b61ca8)

![スクリーンショット 2023-06-03 2.12.16](ipfs://bafkreifzwmktagu3svvquuoo64ucs4kjvcd7sgno4xaoxss47ynsopctpi)
)。
