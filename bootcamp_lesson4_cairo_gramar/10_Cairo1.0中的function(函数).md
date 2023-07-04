# 10\_Cairo1\.0中的function\(函数\)
> 此文章使用的Cairo编译器版本：2.0.0-rc0。因为Cairo正在快速更新，所以不同版本的语法会有些许不同，未来将会将文章内容更新到稳定版本。
## 基本用法
函数是任何一门编程语言必不可少的基础构建。一个函数一般包括：函数名、参数 和 返回值。在Cairo中，约定俗成的规定是将函数名和变量名使用”蛇形命名法”来命名，就像： `my_function_name`。

```
use debug::PrintTrait;

fn another_function() {
    'Another function.'.print();
}

fn main() {
    'Hello, world!'.print();
    another_function();
}
```

函数被调用的方式也和大多数语言一样，`another_function()` 是调用普通函数的写法， `'Hello, world!'.print()` 是调用 trait 中函数的写法。
 
## 参数 & 返回值
Cairo是一门静态语言，函数的每个参数和返回值都需要显式指定类型。不指定将会报错，就像：

```
fn add(a: felt252, b) {
    let c = a + b;
    return c;
}

fn main() -> felt252 {
   add(3, 5) 
}
```

上面有两个错误点：

1. 参数 b 没有指定类型
2. 函数 add 没有指定返回值类型，但是却用了return语句将c变量返回

正确代码：

```
fn add(a: felt252, b: felt252) -> felt252{
    let c = a + b;
    return c;
}

fn main() -> felt252 {
   add(3, 5) 
}
```

### 返回语句
可以使用 return 显试返回，也可以使用不加分号的语句返回。如：

```
fn add(a: felt252, b: felt252) -> felt252 {
	// 返回 a + b
    a + b
}

fn sub(a: felt252, b: felt252) -> felt252 {
    return a - b;
}

fn main() -> felt252 {
   add(3, 5);
   sub(11, 7)
}
```
