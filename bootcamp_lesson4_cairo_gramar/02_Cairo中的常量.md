# 02\_Cairo中的常量
> 此文章使用的Cairo编译器版本：2.0.0-rc0。因为Cairo正在快速更新，所以不同版本的语法会有些许不同，未来将会将文章内容更新到稳定版本。
## 基本用法
```
use debug::PrintTrait;

const ONE_HOUR_IN_SECONDS: felt252 = 3600;

fn main(){
    ONE_HOUR_IN_SECONDS.print();
}
```

使用 const 关键字，并且指明了常量的类型，最后给出了常量的值。

## 与不可变变量的区别
常量有以下性质：

1. 不允许使用 mut 关键字
2. 只能在全局范围内声明
3. 只可以使用字面量给常量赋值

将常量声明在函数中试试

```
use debug::PrintTrait;

fn main(){
	const ONE_HOUR_IN_SECONDS: felt252 = 3600;
    ONE_HOUR_IN_SECONDS.print();
}
```

这样写会收到一大堆的错误🙅。

使用非字面量赋值也会报错

```
use debug::PrintTrait;

const TEST: felt252 = 3600;
const ONE_HOUR_IN_SECONDS: felt252 = TEST;

fn main(){
    ONE_HOUR_IN_SECONDS.print();
}
```

上述代码使用一个常量给另一个常量赋值，会收到如下错误

```
error: Only literal constants are currently supported.
 --> d_const.cairo:4:38
const ONE_HOUR_IN_SECONDS: felt252 = test;
                                     ^**^
```

## 变量与常量的总结
Cairo里的变量声明默认是“不可变的”，这个是比较有趣的。因为其它主流语言在声明变量时默认是可变的，而Cairo则是要反过来。这可以理解，”不可变”通常来说会有更好的稳定性，而可变的会代来不稳定性。所以，Cairo应该是想成为更安全的语言。再加上Cairo同样有 `const` 修饰的常量。于是，Cairo可以玩出这么些东西来：

* 常量：`const LEN:u32 = 1024;` 其中的 `LEN` 就是一个`u32` 的整型常量（无符号32位整型），是**编译时**用到的。
* 可变的变量： `let mut x = 5;` 这个就跟其它语言的类似， 在**运行时**用到。
* 不可变的变量：`let x = 5;` 对这种变量，你不可以修改它。但是，你可以使用 `let x = x + 10;` 这样的方式来重新定义一个新的 `x`。这个在Cairo里叫 Shadowing ，第二个 `x`  把第一个 `x` 给遮蔽了。

对于Cairo的Shadowing，使用起来可能会带来麻烦。使用同名变量（在嵌套的scope环境下）带来的bug还是很不好找的。一般来说，每个变量都应该有他最合适的名字，最好不要重名。

### 默认不可变的优势
不可变的变量对于程序的稳定运行是有帮助的，这是一种编程“契约”，当处理契约为不可变的变量时，程序就可以稳定很多，尤其是多线程的环境下，因为不可变意味着只读不写。

其他好处是，与易变对象相比，它们更易于理解和推理，并提供更高的安全性。有了这样的“契约”后，编译器也很容易在编译时查错了。这就是Cairo语言的编译器的编译期可以帮你检查很多编程上的问题。
