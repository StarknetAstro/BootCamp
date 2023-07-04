# 03\_Cairo中的标量类型\(felt,integer,boolean,float\)
> 此文章使用的Cairo编译器版本：2.0.0-rc0。因为Cairo正在快速更新，所以不同版本的语法会有些许不同，未来将会将文章内容更新到稳定版本。

## felt252
felt252是Cairo中基础类型，代表一个存储槽，未指定变量类型的字面量默认类型都是felt252。felt252可以是负数或者是0，它的取值范围是：

```
-X < felt < X, where X = 2^{251} + 17* 2^{192} + 1
```

任何在这个取值范围内的值都可以存储在felt252中。注意⚠️：并不是 `-(2^251) ~ (2^251 - 1)`。

felt252既可以存整数，也可以存储字符串，下面👇是存储整数和字符串的例子：

```
use debug::PrintTrait;

fn main() {
	// let关键字声明，直接用字面量赋值，默认类型应该是felt252
    let x: felt252 = 5;
    let y: felt252 = 'ppppppppppppppppppppppppppp';
    let z: felt252 = 'ppppppppppppppppppppppppppp99999999999999'; // 溢出
    x.print();
}
```

> 注意⚠️：是252不是256，而且felt后面接其他数字或者不接都会编译报错，例如`felt256 felt`

### 短字符串
短字符串用单引号表示，并且长度不能超过31个字符。短字符串本质上是felt252类型，只是表现形式为字符串，计算机通过ASCII协议将字符转换成数字。短字符串长度不能超过31个字符，本质上是不能超过felt252的最大值。

```
let mut my_first_initial = 'C';
```

### felt252与整型的区别
Cairo1.0中，felt252不支持除法运算，也不支持取余，整型可以。

以下是**Cairo 0.1**中关于felt的描述：

flet是field elements的缩写，可以翻译为域元素。felt252与整型的区别主要体现在除法运算上。当出现不能整除的运算时，例如 7/3，整型运算的结果通常是 2，但是felt252不是。felt252 会始终满足 x*3 = 7 这个等式，由于只能是整数，所以 x*3 的值将会是一个巨大的整数，以至于溢出，溢出后的值刚好是 7。

在Cairo1.0中，felt252被禁止使用除法

```
use debug::PrintTrait;

fn main() {
    let x = 7 / 3;
    x.print();
}

// 以上代码将会的到如下错误
error: Trait has no implementation in context: core::traits::Div::<core::felt252>
 --> f_felt252.cairo:4:13
    let x = 7 / 3;
            ^***^

Error: failed to compile: src/f_felt252.cairo
```

## 整型
核心库中包含了这些整型变量： `u8, u16, u32 (usize), u64, u128, and u256`。他们都是用 felt252 实现的，并且自带整数溢出检测，溢出后触发Panic错误。声明整型变量时，如果不指定变量类型，默认就是 felt252 类型，代码如下：

```
let y = 2;
```

指定 `u8, u16` 等，需要标明变量的类型：

```
let x:u8 = 2;
```

其中 u256 类型比较复杂，创建 u256 类型需要使用其他类型来构建。u256在核心库里是一个结构体，其中两个字段 high 和 low 都是u128类型，因为一个存储槽（felt252）无法装下 u256 类型的数据，所以需要拆成两个存储槽来存储。
```
let z: u256 = u256 { high: 0, low: 10 }
```

其中涉及到 **高地址段** 和 **低地址段** 的概念，大家感兴趣可以查询相关资料。

### 运算符
整型支持大多数运算符，并且自带溢出检测，支持如下：

```
fn test_u8_operators() {
	// 计算
    assert(1_u8 + 3_u8 == 4_u8, '1 + 3 == 4');
    assert(3_u8 + 6_u8 == 9_u8, '3 + 6 == 9');
    assert(3_u8 - 1_u8 == 2_u8, '3 - 1 == 2');
    assert(1_u8 * 3_u8 == 3_u8, '1 * 3 == 3');
    assert(2_u8 * 4_u8 == 8_u8, '2 * 4 == 8');
    assert(19_u8 / 7_u8 == 2_u8, '19 / 7 == 2');
    assert(19_u8 % 7_u8 == 5_u8, '19 % 7 == 5');
    assert(231_u8 - 131_u8 == 100_u8, '231-131=100');

	// 比较
    assert(1_u8 == 1_u8, '1 == 1');
    assert(1_u8 != 2_u8, '1 != 2');
    assert(1_u8 < 4_u8, '1 < 4');
    assert(1_u8 <= 4_u8, '1 <= 4');
    assert(5_u8 > 2_u8, '5 > 2');
    assert(5_u8 >= 2_u8, '5 >= 2');
    assert(!(3_u8 > 3_u8), '!(3 > 3)');
    assert(3_u8 >= 3_u8, '3 >= 3');
}
```

另外，u256同样也支持这些运算符：

```
use debug::PrintTrait;

fn main() {
    let x:u256 = u256{high:3, low: 3};
    let y:u256 = u256{high:3, low: 3};

    let z = x + y;
    assert(z == 2 * y, 'z == 2 * y');
    assert(0 == x - y, '0 == x - y');
    assert(1 == x / y, '0 == x - y');
    assert(0 == x % y, '0 == x % y');

    assert(x == y, 'x == y');
    assert(x <= y, 'x <= y');
    assert(x >= y, 'x <= y');
    assert(x - 1 < y, 'x - 1 < y');
    assert(x + 1 > y, 'x + 1 >= y');
    assert(x != y - 1, 'x != y');
}
```

## Boolean
可以使用如下方式进行声明

```
let is_morning:bool = true;
let is_evening:bool = false;
```

## Float
暂不支持
