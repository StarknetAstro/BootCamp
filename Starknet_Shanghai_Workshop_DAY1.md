![52994791718314e29c662ab33aafc40c](ipfs://bafybeifafndbh5zpbiq7ceqj3ccvhv6fbvua7jxuuu6h3qvran4mqaahgu)

## 简介
本课程作为一个快速上手的Workshop将不会过于深入的讲解Cairo语言的特性（但我们在线Bootcamp最后一节课将深入的介绍一下Cairo语言其他有用的部分）。

如果你想提前深入学习Cairo，可以查看我们最近翻译的[Cairo-Book中文版](https://cairo-book.github.io/zh-cn/index.html) 。


## 环境配置

 **最小安装选项：**

系统：curl，git
IDE：VSCode或任何你喜欢的编辑器（唯独不要使用windows自带的notepad）
MacOS：homebrew
Cairo-Lang CLI。

##  安装 Rust

建议通过 rustup ([docs](https://www.rust-lang.org/tools/install)) 来安装rust。rustup可以切换rust版本和升级。


    ~ $ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

之后重启命令行终端即可验证是否安装成功，或者在终端内执行以下命令：


    ~ $ source "$HOME/.cargo/env"

验证版本


    ~ $ rustup --version
    rustup 1.25.2 (17db695f1 2023-02-01)



如果你没有安装curl，也可以在此处下载rust的各种系统的安装包

https://forge.rust-lang.org/infra/other-installation-methods.html#rustup

## 安装 Cairo
在终端中输入如下命令，从Github上Clone最新的Cairo repo


    git clone https://github.com/starkware-libs/cairo/ ./cairo


接着我们使用稳定的1.10版本：

```
cd ./cairo
git checkout 1003d5d14c09191bbfb64ee318d1975584b3c819
git pull
cargo build --all --release
```

测试是否成功

    cargo run --bin starknet-compile --help

或者

    ./target/release/starknet-compile --version

## 执行 .cairo 文件
让我们先编写一个测试用Cairo文件。在当前目录下创建一个新的文件。
文件名为：`hellostarknetastro.cairo`

内容为：

    use debug::PrintTrait;
    fn main() {
        'Hello, StarknetAstro!'.print();
    }

执行如下命令：

    cargo run --bin cairo-run -- hellostarknetastro.cairo

或者使用上面编译好的relese中的来进行执行
    target/release/cairo-run hellostarknetastro.cairo

这时，终端里会输出类似以下内容

    [DEBUG]  Hello, StarknetAstro!  (raw: 105807143882116536446217580363080108601441594273569)

## 编译 .cairo 文件


Cairo自带了一些范例，我们可以用如下命令编译:
首先我们在cairo根目录下创建一个文件夹用来保存输出

    mkdir output

之后使用cargo进行编译

    cargo run --bin cairo-compile examples/fib.cairo output/fib.json

或者使用

    target/release/cairo-compile examples/fib.cairo output/fib.json

这里我们输出的其实是中间代码， Cairo称之为Sierra。
如果想输出可以直接在Cairo-VM上执行的文件，我们需要进一步把Sierra编译称Cairo汇编（casm）文件。

    cargo run --bin sierra-compile -- output/fib.json output/fib.casm


或者

    target/release/sierra-compile -- output/fib.json output/fib.casm

当然，一般来说，只有需要部署到starknet上时才需要编译Cairo合约到casm。无特殊需求我们一般不需要编译单纯的Cairo代码到casm。

## 安装 Python

旧Cairo-CLI需要的是python 3.9版本。为了避免和已经安装的冲突，和rust一样，我们推荐使用python版本管理工具pyenv来安装python。

**MacOS：**

    brew update
    brew install pyenv
或者

    curl https://pyenv.run | bash

之后

    pyenv install 3.9
    pyenv global 3.9

**Linux：**

    curl https://pyenv.run | bash
之后

    pyenv install 3.9
    pyenv global 3.9

验证是否安装成功

    python3.9 --version

或者直接简单的安装一个py3.9版本
https://www.python.org/downloads/release/python-3915/

### 安装CLI

此CLI用于部署starknet合约。我们需要先安装GMP环境支持

linux

    sudo apt install -y libgmp3-dev

MACOS

    brew install gmp


为了方便操作让我们先进入Cairo 1.0的根目录（此处参照你Cairo的安装目录，比如我的就是如下所示）

    cd ~/cairo/

创建一个camp1_lesson3文件夹：

    mkdir -p starknetastro/workshop/
    cd starknetastro/workshop/

接着创建一个python虚拟环境：

    python3.9 -m venv  venv

启动虚拟环境：

    source venv/bin/activate

此时你应该可以看到终端的前面带上了一个（venv）。让我们安装CLI

    (venv) camp1 $ pip install cairo-lang==0.11.1.1

检验是否安装成功

    (venv) camp1 $ starknet --version

这里应该输出：

    starknet 0.11.1.1

### 常见问题

很多同学在安装python后依然无法正常编译，在这里给出一些常见问题的解决方法：
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
cairo-lang-compile 1.1.0
(venv) $ $CAIRO_COMPILER_DIR/starknet-compile --version
cairo-lang-starknet 1.1.0
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

## ERC20代码模版

将下面的erc20.cairo保存在上面创建的 `src`中 ，方便终端操作。

文件名：erc20.cairo

```
use starknet::ContractAddress;

#[abi]
trait IERC20 {
    #[view]
    fn name() -> felt252;
    #[view]
    fn symbol() -> felt252;
    #[view]
    fn decimals() -> u8;
    #[view]
    fn totalSupply() -> u256;
    #[view]
    fn balanceOf(account: ContractAddress) -> u256;
    #[view]
    fn allowance(owner: ContractAddress, spender: ContractAddress) -> u256;
    #[external]
    fn transfer(recipient: ContractAddress, amount: u256) -> bool;
    #[external]
    fn transferFrom(sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool;
    #[external]
    fn approve(spender: ContractAddress, amount: u256) -> bool;
    #[external]
    fn increaseAllowance(spender: ContractAddress, added_value: u256) -> bool;
    #[external]
    fn decreaseAllowance(spender: ContractAddress, subtracted_value: u256) -> bool;
}

#[contract]
mod ERC20 {
    use super::IERC20;
    use integer::BoundedInt;
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use zeroable::Zeroable;

    struct Storage {
        _name: felt252,
        _symbol: felt252,
        _total_supply: u256,
        _balances: LegacyMap<ContractAddress, u256>,
        _allowances: LegacyMap<(ContractAddress, ContractAddress), u256>,
    }

    #[event]
    fn Transfer(from: ContractAddress, to: ContractAddress, value: u256) {}

    #[event]
    fn Approval(owner: ContractAddress, spender: ContractAddress, value: u256) {}

    impl ERC20 of IERC20 {
        fn name() -> felt252 {
            _name::read()
        }

        fn symbol() -> felt252 {
            _symbol::read()
        }

        fn decimals() -> u8 {
            18_u8
        }

        fn totalSupply() -> u256 {
            _total_supply::read()
        }

        fn balanceOf(account: ContractAddress) -> u256 {
            _balances::read(account)
        }

        fn allowance(owner: ContractAddress, spender: ContractAddress) -> u256 {
            _allowances::read((owner, spender))
        }

        fn transfer(recipient: ContractAddress, amount: u256) -> bool {
            let sender = get_caller_address();
            _transfer(sender, recipient, amount);
            true
        }

        fn transferFrom(
            sender: ContractAddress, recipient: ContractAddress, amount: u256
        ) -> bool {
            let caller = get_caller_address();
            _spend_allowance(sender, caller, amount);
            _transfer(sender, recipient, amount);
            true
        }

        fn approve(spender: ContractAddress, amount: u256) -> bool {
            let caller = get_caller_address();
            _approve(caller, spender, amount);
            true
        }

        fn increaseAllowance(spender: ContractAddress, added_value: u256) -> bool {
            _increase_allowance(spender, added_value)
        }

        fn decreaseAllowance(spender: ContractAddress, subtracted_value: u256) -> bool {
            _decrease_allowance(spender, subtracted_value)
        }
    }

    #[constructor]
    fn constructor(
        name: felt252, symbol: felt252, initial_supply: u256, recipient: ContractAddress
    ) {
        initializer(name, symbol);
        _mint(recipient, initial_supply);
    }

    #[view]
    fn name() -> felt252 {
        ERC20::name()
    }

    #[view]
    fn symbol() -> felt252 {
        ERC20::symbol()
    }

    #[view]
    fn decimals() -> u8 {
        ERC20::decimals()
    }

    #[view]
    fn totalSupply() -> u256 {
        ERC20::totalSupply()
    }

    #[view]
    fn balanceOf(account: ContractAddress) -> u256 {
        ERC20::balanceOf(account)
    }

    #[view]
    fn allowance(owner: ContractAddress, spender: ContractAddress) -> u256 {
        ERC20::allowance(owner, spender)
    }

    #[external]
    fn transfer(recipient: ContractAddress, amount: u256) -> bool {
        ERC20::transfer(recipient, amount)
    }

    #[external]
    fn transferFrom(sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool {
        ERC20::transferFrom(sender, recipient, amount)
    }

    #[external]
    fn approve(spender: ContractAddress, amount: u256) -> bool {
        ERC20::approve(spender, amount)
    }

    #[external]
    fn increaseAllowance(spender: ContractAddress, added_value: u256) -> bool {
        ERC20::increaseAllowance(spender, added_value)
    }

    #[external]
    fn decreaseAllowance(spender: ContractAddress, subtracted_value: u256) -> bool {
        ERC20::decreaseAllowance(spender, subtracted_value)
    }

    ///
    /// Internals
    ///

    #[internal]
    fn initializer(name_: felt252, symbol_: felt252) {
        _name::write(name_);
        _symbol::write(symbol_);
    }

    #[internal]
    fn _increase_allowance(spender: ContractAddress, added_value: u256) -> bool {
        let caller = get_caller_address();
        _approve(caller, spender, _allowances::read((caller, spender)) + added_value);
        true
    }

    #[internal]
    fn _decrease_allowance(spender: ContractAddress, subtracted_value: u256) -> bool {
        let caller = get_caller_address();
        _approve(caller, spender, _allowances::read((caller, spender)) - subtracted_value);
        true
    }

    #[internal]
    fn _mint(recipient: ContractAddress, amount: u256) {
        assert(!recipient.is_zero(), 'ERC20: mint to 0');
        _total_supply::write(_total_supply::read() + amount);
        _balances::write(recipient, _balances::read(recipient) + amount);
        Transfer(Zeroable::zero(), recipient, amount);
    }

    #[internal]
    fn _burn(account: ContractAddress, amount: u256) {
        assert(!account.is_zero(), 'ERC20: burn from 0');
        _total_supply::write(_total_supply::read() - amount);
        _balances::write(account, _balances::read(account) - amount);
        Transfer(account, Zeroable::zero(), amount);
    }

    #[internal]
    fn _approve(owner: ContractAddress, spender: ContractAddress, amount: u256) {
        assert(!owner.is_zero(), 'ERC20: approve from 0');
        assert(!spender.is_zero(), 'ERC20: approve to 0');
        _allowances::write((owner, spender), amount);
        Approval(owner, spender, amount);
    }

    #[internal]
    fn _transfer(sender: ContractAddress, recipient: ContractAddress, amount: u256) {
        assert(!sender.is_zero(), 'ERC20: transfer from 0');
        assert(!recipient.is_zero(), 'ERC20: transfer to 0');
        _balances::write(sender, _balances::read(sender) - amount);
        _balances::write(recipient, _balances::read(recipient) + amount);
        Transfer(sender, recipient, amount);
    }

    #[internal]
    fn _spend_allowance(owner: ContractAddress, spender: ContractAddress, amount: u256) {
        let current_allowance = _allowances::read((owner, spender));
        if current_allowance != BoundedInt::max() {
            _approve(owner, spender, current_allowance - amount);
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
Contract class hash: 0x580e15048e1a124d1ce0579c299391b8583bc167dc64768bb99f95af0d9e2b6
Transaction hash: 0x74680a930e3999195bb534c26b7a7c8ce00b357ddccd3681378a0d9b1e01d5c

```

接着则是Deploy这个erc20合约的instance。注意erc20代码中的构造函数是有参数的，因此我们也需要给出相应的参数：

```
starknet deploy --inputs 0x417374726F546F6B656E 0x417374726F 0x3e8 0x0 0x01d4557fb129128c4db7a1d8049cbba4779e5aa64798cec7aea1a477a489d695 --class_hash 0x0580e15048e1a124d1ce0579c299391b8583bc167dc64768bb99f95af0d9e2b6 --account StarknetAstro
```

输出为：

```
Sending the transaction with max_fee: 0.000009 ETH (8827510645965 WEI).
Invoke transaction for contract deployment was sent.
Contract address: 0x010d93ff677abe100d6577d5e96416a01aa5c212f8012b105444c3efde20a95f
Transaction hash: 0x6e87fd6b23af80f59e21127ad0e54e5526062970d4a420e8e79d7e6911f992
```
大功告成！你可以在这里看到我们 [部署的合约](https://testnet.starkscan.co/contract/0x010d93ff677abe100d6577d5e96416a01aa5c212f8012b105444c3efde20a95f)


## ERC721代码模版

将下面的erc721.cairo保存在上面创建的 `src`中 ，方便终端操作。

文件名：erc721.cairo

```
use array::ArrayTrait;
use array::SpanTrait;
use option::OptionTrait;
use serde::Serde;
use serde::deserialize_array_helper;
use serde::serialize_array_helper;
use starknet::ContractAddress;

const IERC165_ID: u32 = 0x01ffc9a7_u32;
const IERC721_ID: u32 = 0x80ac58cd_u32;
const IERC721_METADATA_ID: u32 = 0x5b5e139f_u32;
const IERC721_RECEIVER_ID: u32 = 0x150b7a02_u32;


#[abi]
trait IERC721 {
    fn balance_of(account: ContractAddress) -> u256;
    fn owner_of(token_id: u256) -> ContractAddress;
    fn transfer_from(from: ContractAddress, to: ContractAddress, token_id: u256);
    fn safe_transfer_from(
        from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>
    );
    fn approve(to: ContractAddress, token_id: u256);
    fn set_approval_for_all(operator: ContractAddress, approved: bool);
    fn get_approved(token_id: u256) -> ContractAddress;
    fn is_approved_for_all(owner: ContractAddress, operator: ContractAddress) -> bool;
    // IERC721Metadata
    fn name() -> felt252;
    fn symbol() -> felt252;
    fn token_uri(token_id: u256) -> felt252;
}

#[abi]
trait IERC721Camel {
    fn balanceOf(account: ContractAddress) -> u256;
    fn ownerOf(tokenId: u256) -> ContractAddress;
    fn transferFrom(from: ContractAddress, to: ContractAddress, tokenId: u256);
    fn safeTransferFrom(
        from: ContractAddress, to: ContractAddress, tokenId: u256, data: Span<felt252>
    );
    fn approve(to: ContractAddress, tokenId: u256);
    fn setApprovalForAll(operator: ContractAddress, approved: bool);
    fn getApproved(tokenId: u256) -> ContractAddress;
    fn isApprovedForAll(owner: ContractAddress, operator: ContractAddress) -> bool;
    // IERC721Metadata
    fn name() -> felt252;
    fn symbol() -> felt252;
    fn tokenUri(tokenId: u256) -> felt252;
}

#[abi]
trait IASTRONFT  {
    fn mint(to: ContractAddress, token_id: u256);
}

//
// ERC721Receiver
//

#[abi]
trait IERC721ReceiverABI {
    fn on_erc721_received(
        operator: ContractAddress, from: ContractAddress, token_id: u256, data: Span<felt252>
    ) -> u32;
    fn onERC721Received(
        operator: ContractAddress, from: ContractAddress, tokenId: u256, data: Span<felt252>
    ) -> u32;
}

#[abi]
trait IERC721Receiver {
    fn on_erc721_received(
        operator: ContractAddress, from: ContractAddress, token_id: u256, data: Span<felt252>
    ) -> u32;
}

#[abi]
trait IERC721ReceiverCamel {
    fn onERC721Received(
        operator: ContractAddress, from: ContractAddress, tokenId: u256, data: Span<felt252>
    ) -> u32;
}

#[abi]
trait ERC721ABI {
    // case agnostic
    #[view]
    fn name() -> felt252;
    #[view]
    fn symbol() -> felt252;
    #[external]
    fn approve(to: ContractAddress, token_id: u256);
    // snake_case
    #[view]
    fn balance_of(account: ContractAddress) -> u256;
    #[view]
    fn owner_of(token_id: u256) -> ContractAddress;
    #[external]
    fn transfer_from(from: ContractAddress, to: ContractAddress, token_id: u256);
    #[external]
    fn safe_transfer_from(
        from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>
    );
    #[external]
    fn set_approval_for_all(operator: ContractAddress, approved: bool);
    #[view]
    fn get_approved(token_id: u256) -> ContractAddress;
    #[view]
    fn is_approved_for_all(owner: ContractAddress, operator: ContractAddress) -> bool;
    #[view]
    fn token_uri(token_id: u256) -> felt252;
    // camelCase
    #[view]
    fn balanceOf(account: ContractAddress) -> u256;
    #[view]
    fn ownerOf(tokenId: u256) -> ContractAddress;
    #[external]
    fn transferFrom(from: ContractAddress, to: ContractAddress, tokenId: u256);
    #[external]
    fn safeTransferFrom(
        from: ContractAddress, to: ContractAddress, tokenId: u256, data: Span<felt252>
    );
    #[external]
    fn setApprovalForAll(operator: ContractAddress, approved: bool);
    #[view]
    fn getApproved(tokenId: u256) -> ContractAddress;
    #[view]
    fn isApprovedForAll(owner: ContractAddress, operator: ContractAddress) -> bool;
    #[view]
    fn tokenUri(tokenId: u256) -> felt252;
}

#[abi]
trait ASTRONFTABI {
    #[external]
    fn mint(to: ContractAddress, token_id: u256);
}


#[contract]
mod ERC721 {
    use super::IERC721;
    use super::IERC721Camel;
    use super::IASTRONFT;

    // Other
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use zeroable::Zeroable;
    use option::OptionTrait;
    use array::SpanTrait;
    use traits::Into;
    use super::SpanSerde;

    struct Storage {
        _name: felt252,
        _symbol: felt252,
        _owners: LegacyMap<u256, ContractAddress>,
        _balances: LegacyMap<ContractAddress, u256>,
        _token_approvals: LegacyMap<u256, ContractAddress>,
        _operator_approvals: LegacyMap<(ContractAddress, ContractAddress), bool>,
        _token_uri: LegacyMap<u256, felt252>,
    }

    #[event]
    fn Transfer(from: ContractAddress, to: ContractAddress, token_id: u256) {}

    #[event]
    fn Approval(owner: ContractAddress, approved: ContractAddress, token_id: u256) {}

    #[event]
    fn ApprovalForAll(owner: ContractAddress, operator: ContractAddress, approved: bool) {}

    #[constructor]
    fn constructor(name: felt252, symbol: felt252) {
        initializer(name, symbol);
    }

    impl IASTRONFTImpl of IASTRONFT {
        fn mint(to: ContractAddress, token_id: u256) {
            _mint(to, token_id);
        }
    }

    impl ERC721Impl of IERC721 {
        fn name() -> felt252 {
            _name::read()
        }

        fn symbol() -> felt252 {
            _symbol::read()
        }

        fn token_uri(token_id: u256) -> felt252 {
            assert(_exists(token_id), 'ERC721: invalid token ID');
            _token_uri::read(token_id)
        }

        fn balance_of(account: ContractAddress) -> u256 {
            assert(!account.is_zero(), 'ERC721: invalid account');
            _balances::read(account)
        }

        fn owner_of(token_id: u256) -> ContractAddress {
            _owner_of(token_id)
        }

        fn get_approved(token_id: u256) -> ContractAddress {
            assert(_exists(token_id), 'ERC721: invalid token ID');
            _token_approvals::read(token_id)
        }

        fn is_approved_for_all(owner: ContractAddress, operator: ContractAddress) -> bool {
            _operator_approvals::read((owner, operator))
        }

        fn approve(to: ContractAddress, token_id: u256) {
            let owner = _owner_of(token_id);

            let caller = get_caller_address();
            assert(
                owner == caller | is_approved_for_all(owner, caller), 'ERC721: unauthorized caller'
            );
            _approve(to, token_id);
        }

        fn set_approval_for_all(operator: ContractAddress, approved: bool) {
            _set_approval_for_all(get_caller_address(), operator, approved)
        }

        fn transfer_from(from: ContractAddress, to: ContractAddress, token_id: u256) {
            assert(
                _is_approved_or_owner(get_caller_address(), token_id), 'ERC721: unauthorized caller'
            );
            _transfer(from, to, token_id);
        }

        fn safe_transfer_from(
            from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>
        ) {
            assert(
                _is_approved_or_owner(get_caller_address(), token_id), 'ERC721: unauthorized caller'
            );
            _safe_transfer(from, to, token_id, data);
        }
    }

    impl ERC721CamelImpl of IERC721Camel {
        fn name() -> felt252 {
            ERC721Impl::name()
        }

        fn symbol() -> felt252 {
            ERC721Impl::symbol()
        }

        fn tokenUri(tokenId: u256) -> felt252 {
            ERC721Impl::token_uri(tokenId)
        }

        fn balanceOf(account: ContractAddress) -> u256 {
            ERC721Impl::balance_of(account)
        }

        fn ownerOf(tokenId: u256) -> ContractAddress {
            ERC721Impl::owner_of(tokenId)
        }

        fn approve(to: ContractAddress, tokenId: u256) {
            ERC721Impl::approve(to, tokenId)
        }

        fn getApproved(tokenId: u256) -> ContractAddress {
            ERC721Impl::get_approved(tokenId)
        }

        fn isApprovedForAll(owner: ContractAddress, operator: ContractAddress) -> bool {
            ERC721Impl::is_approved_for_all(owner, operator)
        }

        fn setApprovalForAll(operator: ContractAddress, approved: bool) {
            ERC721Impl::set_approval_for_all(operator, approved)
        }

        fn transferFrom(from: ContractAddress, to: ContractAddress, tokenId: u256) {
            ERC721Impl::transfer_from(from, to, tokenId)
        }

        fn safeTransferFrom(
            from: ContractAddress, to: ContractAddress, tokenId: u256, data: Span<felt252>
        ) {
            ERC721Impl::safe_transfer_from(from, to, tokenId, data)
        }
    }

    // View

    #[view]
    fn supports_interface(interface_id: u32) -> bool {
        if super::IERC165_ID == interface_id {
            return true;
        } else if super::IERC721_METADATA_ID == interface_id {
            return true;
        } else {
            return super::IERC721_ID == interface_id;
        }
    }

    #[view]
    fn supportsInterface(interfaceId: u32) -> bool {
        if super::IERC165_ID == interfaceId {
            return true;
        } else if super::IERC721_METADATA_ID == interfaceId {
            return true;
        } else {
            return super::IERC721_ID == interfaceId;
        }
    }

    #[view]
    fn name() -> felt252 {
        ERC721Impl::name()
    }

    #[view]
    fn symbol() -> felt252 {
        ERC721Impl::symbol()
    }

    #[view]
    fn token_uri(token_id: u256) -> felt252 {
        ERC721Impl::token_uri(token_id)
    }

    #[view]
    fn tokenUri(tokenId: u256) -> felt252 {
        ERC721CamelImpl::tokenUri(tokenId)
    }

    #[view]
    fn balance_of(account: ContractAddress) -> u256 {
        ERC721Impl::balance_of(account)
    }

    #[view]
    fn balanceOf(account: ContractAddress) -> u256 {
        ERC721CamelImpl::balanceOf(account)
    }

    #[view]
    fn owner_of(token_id: u256) -> ContractAddress {
        ERC721Impl::owner_of(token_id)
    }

    #[view]
    fn ownerOf(tokenId: u256) -> ContractAddress {
        ERC721CamelImpl::ownerOf(tokenId)
    }

    #[view]
    fn get_approved(token_id: u256) -> ContractAddress {
        ERC721Impl::get_approved(token_id)
    }

    #[view]
    fn getApproved(tokenId: u256) -> ContractAddress {
        ERC721CamelImpl::getApproved(tokenId)
    }

    #[view]
    fn is_approved_for_all(owner: ContractAddress, operator: ContractAddress) -> bool {
        ERC721Impl::is_approved_for_all(owner, operator)
    }

    #[view]
    fn isApprovedForAll(owner: ContractAddress, operator: ContractAddress) -> bool {
        ERC721CamelImpl::isApprovedForAll(owner, operator)
    }

    // External

    #[external]
    fn approve(to: ContractAddress, token_id: u256) {
        ERC721Impl::approve(to, token_id)
    }

    #[external]
    fn set_approval_for_all(operator: ContractAddress, approved: bool) {
        ERC721Impl::set_approval_for_all(operator, approved)
    }

    #[external]
    fn setApprovalForAll(operator: ContractAddress, approved: bool) {
        ERC721CamelImpl::setApprovalForAll(operator, approved)
    }

    #[external]
    fn transfer_from(from: ContractAddress, to: ContractAddress, token_id: u256) {
        ERC721Impl::transfer_from(from, to, token_id)
    }

    #[external]
    fn transferFrom(from: ContractAddress, to: ContractAddress, tokenId: u256) {
        ERC721CamelImpl::transferFrom(from, to, tokenId)
    }

    #[external]
    fn safe_transfer_from(
        from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>
    ) {
        ERC721Impl::safe_transfer_from(from, to, token_id, data)
    }

    #[external]
    fn safeTransferFrom(
        from: ContractAddress, to: ContractAddress, tokenId: u256, data: Span<felt252>
    ) {
        ERC721CamelImpl::safeTransferFrom(from, to, tokenId, data)
    }

    #[external]
    fn mint(to: ContractAddress, token_id: u256) {
            IASTRONFTImpl::mint(to, token_id);
    }

    // Internal

    #[internal]
    fn initializer(name_: felt252, symbol_: felt252) {
        _name::write(name_);
        _symbol::write(symbol_);
    }

    #[internal]
    fn _owner_of(token_id: u256) -> ContractAddress {
        let owner = _owners::read(token_id);
        match owner.is_zero() {
            bool::False(()) => owner,
            bool::True(()) => panic_with_felt252('ERC721: invalid token ID')
        }
    }

    #[internal]
    fn _exists(token_id: u256) -> bool {
        !_owners::read(token_id).is_zero()
    }

    #[internal]
    fn _is_approved_or_owner(spender: ContractAddress, token_id: u256) -> bool {
        let owner = _owner_of(token_id);
        owner == spender | is_approved_for_all(owner, spender) | spender == get_approved(token_id)
    }

    #[internal]
    fn _approve(to: ContractAddress, token_id: u256) {
        let owner = _owner_of(token_id);
        assert(owner != to, 'ERC721: approval to owner');
        _token_approvals::write(token_id, to);
        Approval(owner, to, token_id);
    }

    #[internal]
    fn _set_approval_for_all(owner: ContractAddress, operator: ContractAddress, approved: bool) {
        assert(owner != operator, 'ERC721: self approval');
        _operator_approvals::write((owner, operator), approved);
        ApprovalForAll(owner, operator, approved);
    }

    #[internal]
    fn _mint(to: ContractAddress, token_id: u256) {
        assert(!to.is_zero(), 'ERC721: invalid receiver');
        assert(!_exists(token_id), 'ERC721: token already minted');

        // Update balances
        _balances::write(to, _balances::read(to) + 1.into());

        // Update token_id owner
        _owners::write(token_id, to);

        // Emit event
        Transfer(Zeroable::zero(), to, token_id);
    }

    #[internal]
    fn _transfer(from: ContractAddress, to: ContractAddress, token_id: u256) {
        assert(!to.is_zero(), 'ERC721: invalid receiver');
        let owner = _owner_of(token_id);
        assert(from == owner, 'ERC721: wrong sender');

        // Implicit clear approvals, no need to emit an event
        _token_approvals::write(token_id, Zeroable::zero());

        // Update balances
        _balances::write(from, _balances::read(from) - 1.into());
        _balances::write(to, _balances::read(to) + 1.into());

        // Update token_id owner
        _owners::write(token_id, to);

        // Emit event
        Transfer(from, to, token_id);
    }

    #[internal]
    fn _burn(token_id: u256) {
        let owner = _owner_of(token_id);

        // Implicit clear approvals, no need to emit an event
        _token_approvals::write(token_id, Zeroable::zero());

        // Update balances
        _balances::write(owner, _balances::read(owner) - 1.into());

        // Delete owner
        _owners::write(token_id, Zeroable::zero());

        // Emit event
        Transfer(owner, Zeroable::zero(), token_id);
    }

    #[internal]
    fn _safe_mint(to: ContractAddress, token_id: u256, data: Span<felt252>) {
        _mint(to, token_id);
    }

    #[internal]
    fn _safe_transfer(
        from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>
    ) {
        _transfer(from, to, token_id);
    }

    #[internal]
    fn _set_token_uri(token_id: u256, token_uri: felt252) {
        assert(_exists(token_id), 'ERC721: invalid token ID');
        _token_uri::write(token_id, token_uri)
    }
}

impl SpanSerde<
    T, impl TSerde: Serde<T>, impl TCopy: Copy<T>, impl TDrop: Drop<T>
> of Serde<Span<T>> {
    fn serialize(self: @Span<T>, ref output: Array<felt252>) {
        (*self).len().serialize(ref output);
        serialize_array_helper(*self, ref output);
    }
    fn deserialize(ref serialized: Span<felt252>) -> Option<Span<T>> {
        let length = *serialized.pop_front()?;
        let mut arr = ArrayTrait::new();
        Option::Some(deserialize_array_helper(ref serialized, arr, length)?.span())
    }
}
```

### 部署ERC721

首先我们依然需要编译cairo文件到sierra
```
$CAIRO_COMPILER_DIR/starknet-compile src/erc721.cairo sierra/erc721.json
```
接下来是声明
```
starknet declare --contract sierra/erc721.json --account StarknetAstro
```

这次的输出不一样了，因为我们编写的这个erc721文件还没有人部署过，因此不会出现错误（当然，照着课程做的同学们还是会遇上已经被声明的错误）。

```
Sending the transaction with max_fee: 0.000001 ETH (1378300012405 WEI).
Declare transaction was sent.
Contract class hash: 0x49f6ecc90497560cb72901c514407cb91a42cc5d8868b2d348ba0264067c94c
Transaction hash: 0x24999e08268d91439d75c251bf0e86ad4abc633d9f03ac2ca1eb00d421d3c54
```

接着则是Deploy这个erc721合约的instance。注意erc721代码中的构造函数是有参数的，因此我们也需要给出相应的参数：

```
starknet deploy --inputs 0x417374726F546F6B656E 0x417374726F --class_hash 0x49f6ecc90497560cb72901c514407cb91a42cc5d8868b2d348ba0264067c94c --account StarknetAstro
```

输出为：

```
Sending the transaction with max_fee: 0.000006 ETH (6121500055094 WEI).
Invoke transaction for contract deployment was sent.
Contract address: 0x06722e748113c467542ad7f9985fdf2dd81c2b92088fc832dc7845c13d2eff41
Transaction hash: 0x40bd533e6e2503f05c20f1abfc584aaf03075dee9659278ec6674195f4d2795
```
大功告成！你可以在这里看到我们 [部署的合约](https://testnet.starkscan.co/contract/0x06722e748113c467542ad7f9985fdf2dd81c2b92088fc832dc7845c13d2eff41)
