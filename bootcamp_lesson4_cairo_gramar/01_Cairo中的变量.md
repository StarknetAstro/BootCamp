# 01\_Cairo中的变量
> 此文章使用的Cairo编译器版本：2.0.0-rc0。因为Cairo正在快速更新，所以不同版本的语法会有些许不同，未来将会将文章内容更新到稳定版本。

变量是编程语言中最基本的元素。

## 基本使用
创建一个变量

```
use debug::PrintTrait;

fn main() {
    let x = 5;
    x.print();
}
```

使用let关键字来创建一个变量。PrintTrait是官方库提供的打印工具库。

## 变量的可变性
Cairo使用的是不可变的内存模型(immutable memory model)，当一个内存空间被赋值后，就不可以再覆盖写入，只可以被读取。

这意味着Cairo中所有变量默认都是不可变的(听起来有点反直觉🙃️)。

尝试运行如下代码(使用命令：`cairo-run --path $FILE_CAIRO`)

```
use debug::PrintTrait;
fn main() {
    let x = 5;
    x.print();
    x = 6;
    x.print();
}
```

会得到如下错误

```
error: Cannot assign to an immutable variable.
 --> c01_var.cairo:5:5
    x = 6;
    ^***^

Error: failed to compile: src/c01_var.cairo
```

那么要使得变量可变，需要使用 mut 关键字

```
use debug::PrintTrait;
fn main() {
    let mut x = 5;
    x.print();
    x = 6;
    x.print();
}
```

上面👆x变量前面加了 mut 关键字，这样就可以正常运行了。

不可变的变量和🔗[常量](brain://6DBBKn239UaB5EKug2ATZw/Cairo%E4%B8%AD%E7%9A%84%E5%B8%B8%E9%87%8F)有几分相似，那它是否可以被当作常量使用呢？

## Shadowing
Cairo中的Shadowing与Rust中的类似，就是可以实现：不同的变量使用相同变量名的效果。我们来看看具体的例子：<br>
```
use debug::PrintTrait;
fn main() {
    let mut x = 5_u32;
    let x: felt252 = 10;
    {
	    // 只会影响大括号内的变量，不影响括号以外的
        let x = x * 2;
        'Inner scope x value is:'.print();
        x.print()
    }
    'Outer scope x value is:'.print();
    x.print();
}
```

上述例子中`let x: felt252 = 10;`中定义的x变量将前一行的x完全遮盖，这也是Shadowing这个名称的由来。具有如下特征：

1. 使用let关键字进行重新定义；
2. 重新定义可以使用不同的数据类型，与之前的类型无关；
3. Shadowing只影响同一命名空间中的变量；
4. 无论变量是 immutable 还是 mutable，都可以被 shadowed，

注意⚠️：在使用Shadowing的时候，尽量避免在不同的命名空间使用相同的变量名，这样会很难定位bug。
