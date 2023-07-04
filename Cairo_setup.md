
![image](ipfs://bafybeihonbq2bp7irm5cwynnfgrz7qbw2p2tmv667wii4jw2et2xnixa34)

**注意！由于Cairo语言变化，此教程已经过期。1.10语法请参考此文 https://starknetastro.xlog.app/Starknet_Shanghai_Workshop_DAY1**
---
**学习资料推荐：**

- 文档类
    1. [Starknet Astro Boot Camp](https://github.com/StarknetAstro/BootCamp),
    本次Boot Camp的文档。
    2. [cairo-book](https://cairo-book.github.io/title-page.html), 社区中的成员模仿 [rust-book](https://doc.rust-lang.org/book/) 写的一本书，目前是相对较全面的一份资料
    3. [Cairo Github仓库里的文档](https://github.com/starkware-libs/cairo/tree/main/docs/reference/src/components/cairo/modules/language_constructs/pages)，这是官方文档，但是还在撰写中
    4. [一位来自 Argent X 的非洲励志哥总结的文档](https://github.com/Starknet-Africa-Edu/Cairo1.0/tree/main/chapters)

- 代码案例类

    1. [starklings交互式教程](https://github.com/shramee/starklings-cairo1) 运行于本地环境的交互式教程。Starknet Basecamp的作业之一。
    2. [starknet-cairo-101](https://github.com/starknet-edu/starknet-cairo-101) 针对Cairo合约的教程。Basecamp的作业之一。
    3. [awesome-cairo](https://github.com/auditless/awesome-cairo#libraries) 汇总了很多开源的Cairo项目，包含很多优秀的实现案例
    4. [Openzepplin的合约仓库](https://github.com/OpenZeppelin/cairo-contracts/tree/cairo-1)
    5. [Cairo核心库源码](https://github.com/starkware-libs/cairo/blob/main/corelib/src)

 **最小安装选项：**

系统：curl，git
IDE：VSCode或任何你喜欢的编辑器（唯独不要使用windows自带的notepad）
MacOS：homebrew

**可选项：**

如果你想要尝试将Cairo合约部署到testnet和mainnet上，你还需要安装以下支持
账户抽象钱包：Braavos 或 Argent X
Cairo 0.x的CLI工具。


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


注意，alpha的一些版本可能是starknet不支持的，所以我们需要指定特定的tag，现阶段starknet支持的稳定版本是v1.0.0-rc0。


    cd ./cairo
    git checkout tags/v1.0.0-rc0

之后我们就可以build整个Cairo了

    cargo build --all --release
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


## 可选内容：安装Cairo 0.x CLI

此CLI用于部署starknet合约。我们需要先安装GMP环境支持

linux

    sudo apt install -y libgmp3-dev

MACOS

    brew install gmp


之后我推荐创建一个虚拟环境。让我们先创建一个test文件夹：

    mkdir -p starknetastro/camp1/
    cd starknetastro/camp1/

接着创建一个python虚拟环境：

    python3.9 -m venv  venv

启动虚拟环境：

    source venv/bin/activate

此时你应该可以看到终端的前面带上了一个（venv）。让在虚拟环境中升级PIP

    (venv)camp1 $ pip install --upgrade pip

安装CLI
Linux:

    (venv) camp1 $ pip install cairo-lang

MACOS(M1～芯片)

    (venv) camp1 $ CFLAGS=-I`brew --prefix gmp`/include LDFLAGS=-L`brew --prefix gmp`/lib pip install cairo-lang


检验是否安装完成

    (venv) camp1 $ starknet --version

输出：

    starknet 0.11.1
