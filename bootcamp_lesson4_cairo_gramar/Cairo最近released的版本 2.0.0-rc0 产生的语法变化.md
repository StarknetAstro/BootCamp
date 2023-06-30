# Cairo最近released的版本 2\.0\.0\-rc0 产生的语法变化
## 一些相关信息的渠道
GitHub的Cairo项目任务进度版图：https://github.com/orgs/starkware-libs/projects/1/views/1

GitHub release 信息列表：https://github.com/starkware-libs/cairo/releases

## 通用性的变化
**(1).** 整数字面量不再需要指明是那个类型的变量

```
// 过去
let n:u8 = 8_u8;
// 现在可以省略后缀，加上也不会报错
let n:u8 = 8;
```

**(2).** 创建字典

过去

```
use dict::Felt252DictTrait;
fn main(){
	let mut dict = Felt252DictTrait::new();
}
```

现在使用 Default trait

```
use dict::Felt252DictTrait;
use traits::Default;

fn main(){
    let mut map : Felt252Dict<felt252> = Default::default();
}
```

## 编写合约的语法变化
首先给出旧版本的合约代码：

```
#[abi]
trait IOtherContract {
    fn decrease_allowed() -> bool;
}

#[contract]
mod CounterContract {
    use starknet::ContractAddress;
    use super::{
        IOtherContractDispatcher, 
        IOtherContractDispatcherTrait, 
        IOtherContractLibraryDispatcher
    };

    struct Storage {
        counter: u128,
        other_contract: IOtherContractDispatcher
    }

    #[event]
    fn counter_increased(amount: u128) {}
    #[event]
    fn counter_decreased(amount: u128) {}

    #[constructor]
    fn constructor(initial_counter: u128, other_contract_addr: ContractAddress) {
        counter::write(initial_counter);
        other_contract::write(IOtherContractDispatcher { contract_address: other_contract_addr });
    }

    #[external]
    fn increase_counter(amount: u128) {
        let current = counter::read();
        counter::write(current + amount);
        counter_increased(amount);
    }

    #[external]
    fn decrease_counter(amount: u128) {
        let allowed = other_contract::read().decrease_allowed();
        if allowed {
           let current = counter::read();
           counter::write(current - amount);
           counter_decreased(amount);
        }
    }

   #[view]
   fn get_counter() -> u128 {
      counter::read()
   }
}
```

### **以下的代码都是新语法的合约代码**

**(1).**external函数集中在一个特定的trait和对应的impl中

以上合约中有三个公开的函数：`increase_counter`、`decrease_counter` 和 `get_counter`。

* 首先这些公开的函数，会在由 `#[starknet::interface]` 标识的 trait 中定义出函数签名（或称函数选择器）。
* 这个trait中包含一个泛型变量 `TContractState` ，它代表合约的 storage 结构体。
* 这些公开的函数都是 `TContractState` 的方法（method）。
* 方法中，第一个参数是 `self`；如果是view方法，self 就是 `TContractState` 的 snapshot `self: @TContractState`；如果是会更改状态的方法，self 就是 `TContractState` 的 reference `ref self: TContractState`。后面再接方法中的其他参数。
* 公开函数的逻辑，都写在由 `#[external(v0)]` 标识的 impl 里。

以上是关于公开函数的新的语法规则，变动还是蛮大的。代码中的注释会有更多的细节：

```
/// @notice 定义了当前合约的外部接口，所有的external函数，都会定义在这个trait的impl里
#[starknet::interface]
trait ICounterContract<TContractState> {
    fn increase_counter(ref self: TContractState, amount: u128);
    fn decrease_counter(ref self: TContractState, amount: u128);
    fn get_counter(self: @TContractState) -> u128;
}

#[starknet::contract]
mod CounterContract {
	...

    /// @notice 这里定义所有external函数，ContractState代表合约的storage状态
    /// @dev 通过传递 snapshot 还是 reference 来区分是否是view函数，如果是snapshot，那么就是view函数
    /// @dev 合约语法还在更新中，v0是为了现在的合约可以兼容将来升级后的新版本编译器
    #[external(v0)]
    impl CounterContract of super::ICounterContract<ContractState> {
        // 传入的是snapshot，因此是view函数
        fn get_counter(self: @ContractState) -> u128 {
            self.counter.read()
        }

        // 传入的是reference，所以会更改合约 storage状态
        fn increase_counter(ref self: ContractState, amount: u128) {
            // 读取合约状态变量
            let current = self.counter.read();
            // 更改合约状态变量
            self.counter.write(current + amount);
            // ContractState 同时给出 emit event 的能力
            self.emit(Event::CounterIncreased(CounterIncreased { amount }));
        }

        fn decrease_counter(ref self: ContractState, amount: u128) {
            let allowed = self.other_contract.read().decrease_allowed();
            if allowed {
                let current = self.counter.read();
                self.counter.write(current - amount);
                self.emit(Event::CounterDecreased(CounterDecreased { amount }));
            }
        }
    }

	...
}
```

**(2).** 合约的外部调用

公开函数的写法更改了，那么合约的外部调用自然也会随着更改。

* 原本使用 `#[abi]` 标识的部分，改为使用 `#[starknet::interface]` 标识。
* trait使用了 泛型trait，用法和上面👆内容一致。

```
/// @notice 外部合约接口的定义
/// @dev 使用 #[starknet::interface] 替换 #[abi]
/// @dev 使用泛型trait，其中 TContractState 是代表合约状态的泛型名称
#[starknet::interface]
trait IOtherContract<TContractState> {
    fn decrease_allowed(self: @TContractState) -> bool;
}
```

**(3).**  Event的改动

 Event的改动也比较大，现在采用 Enum 和 struct 来表示。

* 所有event都定义在 `#[event]` 和 `#[derive(Drop, starknet::Event)]` 标识的 enum 中。
* 每个 event 由单独的结构体来表示传入的字段和类型，并且也需要 `#[derive(Drop, starknet::Event)]` 标识。
* event的调用，需要使用 `ContractState`： `self.emit(Event::CounterDecreased(CounterDecreased { amount }));`

```
	/// @notice 合约的event同时也有了非常大的改变
    /// @dev 将所有的event定义在有 #[event] 标识，且名字为 Event 的 enum 中
    /// @dev 每个event定义的结构为： event_name: event_type，event_type 用来存放事件中的参数结构
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        CounterIncreased: CounterIncreased,
        CounterDecreased: CounterDecreased
    }

    #[derive(Drop, starknet::Event)]
    struct CounterIncreased {
        amount: u128
    }

    #[derive(Drop, starknet::Event)]
    struct CounterDecreased {
        amount: u128
    }
```
