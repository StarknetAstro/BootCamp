# 06\_Cairo 中的Option\(特殊Enum\)
与Rust一样，Cairo同样没有Null这种代表空的系统级变量或者属性。因为这样很容易出现：将空值当作非空值，或者将非空值当作空值的错误。

为了更好的理解这个错误，举一个Golang的例子：

在使用Golang的Map的时候，经常会出现”从一个状态为 nil 的 Map中读取数据”的错误，因为Map可能在运行时是一个nil。nil在Golang中就表示空值的意思。

在Cairo中就不会出现这类错误，因为 Cairo编译器在编译的时候，就能够发现这类错误。实现这个效果的原因就是：Cairo没有Null这种代表空的系统级变量或者属性，Cairo使用一个特殊的Enum类型来实现非空判断(Option)。

## Option的基本使用
标准库中是这么定义Option的

```
enum Option<T> {
    Some: T,
    None: (),
}
```

在实际编码中时可以这么定义Option类型的变量：

```
use option::OptionTrait;

fn main(){
    let some_char = Option::Some('e');
    let some_number: Option<felt252> = Option::None(());
    let absent_number: Option<u32> = Option::Some(8_u32);
}
```

Option的Some成员是泛型，所以可以装入任意类型，上面我们就将一个短字符串装入了Some里。另外需要注意的是，如果使用的是None，参数不可以为空，需要传入**单位类型** `()`。单位类型是Cairo中的一个特殊类型，它是用来保证它所在的位置的代码不会被编译(编译时的空状态)。

### 与Rust的异同

**与Rust相同点：**

* 使用 None 时，需要指定Option中的类型，就像上面的 `let some_number: Option<felt252> = Option::None(());`，因为编译器通过 None 无法判断 Option 里面装的是什么类型。

**与Rust不同点：**

* None 和 Some 不可以直接全局使用。


### 不可以将其他类型的变量和Option一起混用

```
use option::OptionTrait;

fn main() {
    let x: u8 = 5_u8;
    let y: Option<u8> = Option::Some(5_u8);

    let sum = x + y;
}

// 得到如下错误：
error: Unexpected argument type. Expected: "core::integer::u8", found: "core::option::Option::<core::integer::u8>".
 --> h04_enum_option.cairo:11:19
    let sum = x + y;
                  ^
```

虽然 Option 变量 y 中装的是一个  u8 的值，但是 y 和 x的类型是不同的，所以不可以将两个相加。

## Cairo中的非空判断

Cairo中所有类型的变量都是非空的，编译器会保证变量在任何时刻都不为空，就像上面的x变量。也就是说，我们在编写Cairo代码时，无需担心：我是否忘记检查我的变量在运行中是一个空值。唯一需要考虑是否是空值的地方，就是使用 Option 变量的时候。

换句话说，只有Option才可以获取到空值的这个状态（None）。我们可以通过 [match 的控制模式](brain://A97vVOqDNUaDTeJzc9ayIw/08Cairo%E4%B8%AD%E7%9A%84Match%E6%8E%A7%E5%88%B6%E6%A8%A1%E5%BC%8F)来看看Option的实际使用案例。

## 源码剖析
Option核心库的源码：https://github.com/starkware-libs/cairo/blob/main/corelib/src/option.cairo

### 4个成员函数
有4个成员函数：

```
/// 判断Option中是否有值，如果有返回这个值；如果没有，抛出 err 错误
fn expect(self: Option<T>, err: felt252) -> T;

/// 判断Option中是否有值，如果有返回这个值；如果没有，也会抛出错误，此错误不是自定义的错误
fn unwrap(self: Option<T>) -> T;

/// 如果Option有值，返回true
fn is_some(self: @Option<T>) -> bool;

/// 如果Option没有值，返回false
fn is_none(self: @Option<T>) -> bool;
```


