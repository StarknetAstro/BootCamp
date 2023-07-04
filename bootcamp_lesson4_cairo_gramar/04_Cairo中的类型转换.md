# 04\_Cairo中的类型转换
> 此文章使用的Cairo编译器版本：2.0.0-rc0。因为Cairo正在快速更新，所以不同版本的语法会有些许不同，未来将会将文章内容更新到稳定版本。

目前Cairo中的类型转换主要是将各种类型的整数相互转换，例如：u8、u16、u256、felt252 等。即使是u8和u16这两种十分相似的类型，相互转换也不像其他编程语言那样轻松。

## TryInto & Into traits
首先需要介绍一下这两个官方库中提供的两个[traits](brain://7Ke1xxSUfUe9WtfovFXRZA/17Cairo%E4%B8%AD%E7%9A%84Trait)。我们要实现整数类型相互转换，就需要使用这两个traits。

**(1). TryInto** 
TryInto trait 提供 `try_into` 函数，当源类型的取值范围比目标类型大时使用，比如 felt252 转换成 u32 。`try_into` 函数返回值是`Option<T>`类型🔗[Option](brain://api.thebrain.com/zBJh6lmfMEWrNhIe90B2qA/IxK6qo9bJEmIp1GFZ_JvMg/Option)的，如果目标类型无法装下原值，那么就会返回None；如果可以装下，就会返回Some。如果返回 Some，就还需要通过 `unwrap` 函数将返回值转换为目标类型。看例子：

```
use traits::TryInto;
use option::OptionTrait;

fn main() {
    let my_felt252 = 10;
	let my_usize: usize = my_felt252.try_into().unwrap();
}
```

上面先定义了一个felt252的变量`my_felt252`，然后使用`try_into`转换为`Option<T>`类型，再调用Option自带的`unwrap`函数，将`Option`中的泛型变量转换为usize类型变量`my_usize`

**(2). Into**
知道了TryInto的知识后，Into就很好理解了。Into trait 提供 `into` 函数，当目标类型的取值范围比源类型大时，我们就不必考虑溢出错误，所以可以放心转换。比如 u32 转换为 u64 。`into` 函数将会直接返回目标类型的变量，不需要再使用Option进行转换。

```
use traits::TryInto;
use traits::Into;
use option::OptionTrait;

fn main() {
    let my_u8: u8 = 10;
    let my_u16: u16 = my_u8.into();

	let my_u256:u256 = my_felt252.into();
}
```
 
值得注意的是，u256同样可以使用这两个 trait 进行转换。
