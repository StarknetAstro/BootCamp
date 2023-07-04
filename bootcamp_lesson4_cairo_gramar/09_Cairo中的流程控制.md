# 09\_Cairo中的流程控制
> 此文章使用的Cairo编译器版本：2.0.0-rc0。因为Cairo正在快速更新，所以不同版本的语法会有些许不同，未来将会将文章内容更新到稳定版本。

## if语句
```
use debug::PrintTrait;

fn main() {
    let number = 3;

    if number == 3 {
        'condition was true'.print();
    } 
}
```

使用起来很简单，不需要用括号将条件括起来。

再来看看多个判断条件的情况：

```
use debug::PrintTrait;

fn main() {
    let number = 3;

    if number == 12 {
        'number is 12'.print();
    } else if number == 3 {
        'number is 3'.print();
    } else if number - 2 == 1 {
        'number minus 2 is 1'.print();
    } else {
        'number not found'.print();
    }
}
```

多个判断条件的执行顺序是：从上往下依次执行，遇到满足条件的，就会跳出不再进行下面的条件判断。就像上面的，第二个条件 `number == 3` 已经满足，第三个条件即使是 true ，也不会被执行。

### 特殊的if语句，实现与三目运算符相同的效果
这个语句是将 let 语句和 if 语句连在一起使用。

```
use debug::PrintTrait;

fn main() {
    let condition = true;
    let number = if condition {5} else {6};

    if number == 5 {
        'condition was true'.print();
    }
}
```

上述代码中，如果condition为true，那么number就被创建为5；如果condition为false，那么number就被创建为6；

solidity的三目运算符是这样：

```
bool condition = true;
uint256 a = condition ? 5 : 6;
```

## loop循环语句
loop可以让循环无限进行下去，控制循环可以使用`continue` 和 `break`。先看看一个案例：

```
use debug::PrintTrait;

fn main() {
    let mut i: usize = 0;
    loop {
        i += 1;

        if i < 10 {
            'again'.print();
            continue;
        }

        if i == 10 {
            break ();
        };
    }
}
```

以上代码中，i是自增的，小于10的时候会通过continue指令，直接进入下一次循环，continue一下的逻辑不会执行；当i等于10的时候，就使用break指令跳出循环。

* break后面需要添加返回值，没有返回值就使用空值类型`()`，但是不可以省略。

注意⚠️：在执行带有loop的Cairo代码时，需要使用 `--available-gas` 选项指定Gas上限。如：

```
cairo-run --available-gas 200000 $CairoFile
```

### 获取loop的返回值

上面说到break必须要带上返回值，我们可以获取这个返回值：

```
use debug::PrintTrait;

fn main() {
    let mut i: usize = 0;
    let t = loop {
        i += 1;

        if i >= 10 {
            break i;
        };
    };

    t.print();
}
```

上面 t 最终的值是10。

## if和loop的共性：获取表达式的计算结果
if 和 loop 都可以结合 let 来获取 表达式的计算结果，也就是花括号内代码的返回值。如上面提到的：

```
let number = if condition {5} else {6};
```

和

```
let t = loop {
    i += 1;

    if i >= 10 {
        break i;
    };
};
```

在Cairo中，通用的 获取表达式的计算结果 的方式，可以直接获取 `{}` 内代码块的返回值。

```
use debug::PrintTrait;

fn main() {
    let y = {
        let x = 3;
        x + 1
    };

    y.print();
}
```

我们可以将 if 和 loop 和 let 结合的写法可以理解为：他们都是基于通用的 获取表达式的计算结果 的方式的语法糖。
