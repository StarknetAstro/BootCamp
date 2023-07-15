# 08\_Cairo 中的Match控制模式
> 此文章使用的Cairo编译器版本：2.0.0-rc0。因为Cairo正在快速更新，所以不同版本的语法会有些许不同，未来将会将文章内容更新到稳定版本。

Cairo 中的Match控制模式，90%与Rust的一样。因为Cairo还在开发中，许多特性还未完善，Rust相对稳定，所以我们可以参考[Rust 中的Match控制模式](brain://api.thebrain.com/zBJh6lmfMEWrNhIe90B2qA/mvu2dpyJ5k66fBpQEmTdew/Rust%E4%B8%AD%E7%9A%84Match%E6%8E%A7%E5%88%B6%E6%A8%A1%E5%BC%8F)来对照着学习Cairo的这个功能。
## 基本用法
如果匹配到的代码块比较简短，可以不用使用大括号，并且以逗号分隔。如果比较长，那么就需要使用大括号。

```
use debug::PrintTrait;

#[derive(Drop)]
enum Coin {
    Penny:(),
    Nickel:(),
    Dime:(),
    Quarter:(),
}

fn value_in_cents(coin: Coin) -> felt252 {
    match coin {
        Coin::Penny(_) => 1,
        Coin::Nickel(_) => 5,
        Coin::Dime(_) => 10,
        Coin::Quarter(_) => 25,
    }
}

fn main() {
	let p = Coin::Penny(());
	let n = Coin::Nickel(());
	value_in_cents(p).print();
	value_in_cents(n).print();
}
```

上述代码中，`value_in_cents`的参数类型是Coin，而Coin的子类型的变量也可以作为`value_in_cents`的入参。之前说过，Enum可以理解为一组子类型的集合，所有子类型都可以代表父类型。所以任何一个子类型变量，都可以作为 `value_in_cents` 函数的参数。

**使用大括号的情况：**

```
fn value_in_cents(coin: Coin) -> felt252 {
    match coin {
        Coin::Penny(_) => {
            'Lucky penny!'.print();
            1
        },
        Coin::Nickel(_) => 5,
        Coin::Dime(_) => 10,
        Coin::Quarter(_) => 25,
    }
}
```

### 与Rust不一样的地方
**(1). Enum定义时的区别**
* 指定Enum元素类型的方式不同，Cairo需要加上冒号`Penny:(u8)`，Rust不需要冒号`Penny(u8)`
* 不指定Enum元素类型时，Cairo不可以省略括号`Penny:()`，Rust可以直接省略

**(2). Match匹配条件中的区别**
* 没有指定类型的Enum元素，必须使用`(_)`标明，Rust不需要

**(3). 传参时的区别**
*  没有指定类型的Enum元素，传参时需要传入一个标准类型，比如：`let n = Coin::Nickel(());`

|           | **Enum定义时**  | **Match匹配条件**    | **传参时**     |
| --------- | ------------ | ---------------- | ----------------- |
| **Rust**  | `Penny(u8)`  | `Coin::Penny`    | `Coin::Penny()`   |
| **Cairo** | `Penny:(u8)` | `Coin::Penny(_)` | `Coin::Penny(())` |

## 绑定参数
Enum是可以添加类型的，Match的各个匹配项可以将Enum绑定的类型作为匹配项的参数。

```
use debug::PrintTrait;

// #[derive(Debug)] // so we can inspect the state in a minute
enum UsState {
    Alabama: (),
    Alaska: (),
// --snip--
}

enum Coin {
    Penny: (),
    Nickel: (),
    Dime: (),
    // 这里添加了一个Enum类型
    Quarter: UsState,
}

impl UsStatePrintImpl of PrintTrait<UsState> {
    fn print(self: UsState) {
        match self {
            UsState::Alabama(_) => ('Alabama').print(),
            UsState::Alaska(_) => ('Alaska').print(),
        }
    }
}

fn value_in_cents(coin: Coin) -> felt252 {
    match coin {
        Coin::Penny(_) => 1,
        Coin::Nickel(_) => 5,
        Coin::Dime(_) => 10,
        Coin::Quarter(state) => {
            state.print();
            25
        }
    }
}

fn main() {
    let u = Coin::Quarter(UsState::Alabama(()));

    value_in_cents(u);
}
```

上面代码中，UsState::Alabama 就成了 Coin::Quarter(state) 中的参数 state。

### 与Rust不一样的地方
Cairo中Enum默认是没有实现PrintTrait的，所以需要为UsState添加一个impl，用来实现打印功能

```
impl UsStatePrintImpl of PrintTrait::<UsState> {
    fn print(self: UsState) {
        match self {
            UsState::Alabama(_) => ('Alabama').print(),
            UsState::Alaska(_) => ('Alaska').print(),
        }
    }
}
```

## Match模式与Option搭配使用
Match模式与Option搭配使用，就能够实现非空判断。

我们尝试实现一个函数，包含逻辑：如果参数不为空，就+1，如果为空，就不做任何操作。

```
use option::OptionTrait;
use debug::PrintTrait;

fn plus_one(x: Option<u8>) -> Option<u8> {
    match x {
        Option::Some(val) => Option::Some(val + 1_u8),
        Option::None(_) => {
            // 这里可以增加一些额外操作 ...
            Option::None(())
        },
    }
}

fn main() {
    let five: Option<u8> = Option::Some(5_u8);
    let six: Option<u8> = plus_one(five);
    six.unwrap().print();

    let none = plus_one(Option::None(()));
    if none.is_none() {
        'is none !'.print();
    }
}
```

`plus_one`函数就实现了这个功能，可以在函数内部增加一些为空的逻辑处理，也可以在调用处通过返回值来判断是否为空，进而处理为空的情况。

## 使用Match模式的规则
**第一个规则**：Match需要覆盖所有的可能。

```
use option::OptionTrait;
use debug::PrintTrait;

fn plus_one(x: Option<u8>) -> Option<u8> {
    match x {
        Option::Some(i) => Option::Some(i + 1_u8), 
    }
}

fn main() {
    let five: Option<u8> = Option::Some(5_u8);
    let six = plus_one(five);
    let none = plus_one(Option::None(()));
}
```

以上代码没有处理None的情况，所以编译会报错。

**第二个规则**：Cairo目前只有很简单的Default效果。

```
use option::OptionTrait;
use debug::PrintTrait;

fn match_default(x: felt252) -> felt252 {
    match x {
        0 => 'zero', 
        _ => 'default',
    }
}

fn main() {
    let r = match_default(0);
    r.print();
    let r = match_default(1);
    r.print();
}

```
