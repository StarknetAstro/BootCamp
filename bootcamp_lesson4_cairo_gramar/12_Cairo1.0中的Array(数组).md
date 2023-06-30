# 12\_Cairo1\.0中的Array\(数组\)
> 此文章使用的Cairo编译器版本：2.0.0-rc0。因为Cairo正在快速更新，所以不同版本的语法会有些许不同，未来将会将文章内容更新到稳定版本。

数组是一种非常常用的数据结构，通常代表一组相同类型的数据元素集合。无论是传统可执行程序，还是智能合约，都会使用到数组。

## 基本介绍

Cairo中的数组是从核心库 `array` 中导出的一个数组类型，有着许多不一样的特性：

1. 由于Cairo内存模型的特殊性，内存空间一旦被写入就无法覆盖重写，所以Cairo数组中的元素不可以修改的，只可以读取。这一点和大多数编程语言不一样
2. 可以在数组的最后面添加一个元素
3. 还可以从数组的最前面删除一个元素

## 创建数组
所有的数组都是可变变量，所以需要mut关键字：

```
fn create_array() -> Array<felt252> {
    let mut a = ArrayTrait::new(); 
    a.append(0);
    a.append(1);
    a
}
```

数组中可以包含任意类型的元素，因为 Array 里面是一个泛型变量。我们在创建数组的时候，需要指定类型。

```
use array::ArrayTrait;

fn main() {
    let mut a = ArrayTrait::new();
    // error: Type annotations needed.
}
```

上面代码中，编译器不知道 a 这个数组应该装什么类型的数据进去，所以报了错。我们可以这样指定类型：

```
use array::ArrayTrait;

fn main() {
    let mut a = ArrayTrait::new();
    a.append(1);
}
```

上面通过添加 felt252 类型数据到数组里，指明数组是 Array<felt252> 类型的。还可以这样指定：

```
use array::ArrayTrait;

fn main() {
    let b = ArrayTrait::<usize>::new(); 
}
```

以上两种方法都可以。

## 读取数组大小信息
可以读取数组的长度 `len()`，也可以判断数组是否为空 `is_empty()`。

```
use array::ArrayTrait;
use debug::PrintTrait;
use option::OptionTrait;

fn main() {
    let mut a = ArrayTrait::new();

    a.append(1);

    // 判断数组是否为空
    a.is_empty().print();

    // 查看数组的长度
    a.len().print();
}
```

## 添加&删除元素
前文提到，Cairo中的数组只可以在 末尾添加元素 和 开头删除元素。那我们就来看看相关的代码案例：

```
use array::ArrayTrait;
use debug::PrintTrait;
use option::OptionTrait;

fn main() {
    let mut a = ArrayTrait::new();

	// 末尾添加元素
    a.append(1);
    
    // 删除第一个元素
    let k = a.pop_front();
    k.unwrap().print();
}
```

末尾添加元素比较简单，删除第一个元素 pop_front 方法会将被删除的元素返回，并且是一个[Option](brain://JM1nYVnrY0S5W-7hhLFEAw/06Cairo%E4%B8%AD%E7%9A%84Option%E7%89%B9%E6%AE%8AEnum)类型的值。这里使用了 unwrap 方法将  Option 类型的值转换为原有的类型。

## 获取数组中的元素
有两种方法可以获取数组中的元素：get 函数 和 at 函数。

### get 函数
get 函数是一个相对安全的选项，它返回一个Option类型的值。如果访问的下标没有超出数组的范围，那么就是 Some；如果超出下标，就会返回 None。这样，我们就可以结合Match模式，来分别处理这两种情况，避免造成：读取超出下标元素的错误。

```
use array::ArrayTrait;
use debug::PrintTrait;
use option::OptionTrait;
use box::BoxTrait;

fn main() {
    let mut a = ArrayTrait::new();

    a.append(1);
    let s = get_array(0,a);
    s.print();
}

fn get_array(index: usize, arr: Array<felt252>) -> felt252 {
	// 下标是 usize 类型
    match arr.get(index) {
        Option::Some(x) => {
	        // * 是从副本中获取原值的符号
	        // 返回的是 BoxTrait，所以需要使用 unbox 解开包裹
            *x.unbox()
        },
        Option::None(_) => {
            panic(arr)
        }
    }
}
```

上面涉及到的 BoxTrait 会在未来讲解官方核心库的时候进行讲解，有关副本和引用相关的内容参看[Cairo1.0 中的值传递和引用传递](brain://api.thebrain.com/zBJh6lmfMEWrNhIe90B2qA/Uww_hVBIT0-xfQRuHl7BXA/Cairo10%E4%B8%AD%E7%9A%84%E5%80%BC%E4%BC%A0%E9%80%92%E5%92%8C%E5%BC%95%E7%94%A8%E4%BC%A0%E9%80%92)

### at 函数
at 函数将会直接返回对应**下标元素的 snapshot**，注意这里只是单个元素的snapshot，所以我们需要使用`*`操作符将这个snapshot背后的值取出来。另外，如果下标超出数组的范围，将会导致panic错误，所以使用它需要谨慎一些。

```
use array::ArrayTrait;
use debug::PrintTrait;
use option::OptionTrait;

fn main() {
    let mut a = ArrayTrait::new();

    a.append(100);
    let k = *a.at(0);
    k.print();
}
```

## snap函数
snap 函数将会获得数组的 snapshot 对象，这个在只读的场景中非常实用。

```
use core::array::SpanTrait;
use array::ArrayTrait;

fn main() {
    let mut a = ArrayTrait::new();
    a.append(100);
    let s = a.span();
}
```

## 数组作为函数的参数
数组是没有实现Copy trait的，所以数组作为函数的参数时，会发生move操作，所有权会发生变化。

```
use array::ArrayTrait;
fn foo(arr: Array<u128>) {}

fn bar(arr: Array<u128>) {}

fn main() {
    let mut arr = ArrayTrait::<u128>::new();
    foo(arr);
    // bar(arr);
}
```

上面如果将 bar(arr) 注释解除，就会报错。

## 数组的深拷贝
顾名思义，深拷贝是将一个对象的所有的元素、属性，和嵌套的子元素、属性，完全的拷贝出来，形成一个新的对象。这个新的对象的所有数据都和之前的一样，但是它在内存中的地址不一样，他们是数据一致的两个对象。

```
use array::ArrayTrait;
use clone::Clone;

fn foo(arr: Array<u128>) {}

fn bar(arr: Array<u128>) {}

fn main() {
    let mut arr = ArrayTrait::<u128>::new();
    let mut arr01 = arr.clone();
    foo(arr);
    bar(arr01);
}
```

上面代码延续了上一个例子。arr01就是由arr深拷贝出来的新数组，拷贝需要借助官方库中的 Clone trait。

我们从深拷贝的定义中就可以发现，它是非常消耗资源的。clone成员方法使用loop循环，将数组的元素一个个拷贝出来。所以执行这个cairo文件时，需要指定gas：

```
cairo-run --available-gas 200000 $cairo_file
```

## 总结
核心库导出了一个数组类型以及相关函数，使您可以轻松地获取您正在处理的数组的长度、并且添加元素或获取特定索引处的元素。尤其有趣的是使用`ArrayTrait :: get()`函数，因为它返回一个Option类型，这意味着如果您尝试访问超出边界的索引，它将返回None而不是退出程序，这意味着您可以实现错误管理功能。此外，您可以使用泛型类型与数组一起使用，使得与手动管理指针值的旧方式相比，数组更易于使用。


### 数组成员函数汇总

```
trait ArrayTrait<T> {
	// 创建一个数组
    fn new() -> Array<T>;
    
	// 给数组末尾添加一个元素
    fn append(ref self: Array<T>, value: T);
    
    // 删除数组最前面一个元素，并且将这个元素以option的形式返回
    fn pop_front(ref self: Array<T>) -> Option<T> nopanic;
    
    // 获得某个下标的option值，也是返回option类型
    fn get(self: @Array<T>, index: usize) -> Option<Box<@T>>;
    
    // 获得某个下标的值
    fn at(self: @Array<T>, index: usize) -> @T;
    
    // 返回数组长度
    fn len(self: @Array<T>) -> usize;
    
    // 判断数组是否为空
    fn is_empty(self: @Array<T>) -> bool;
    
    // 获得一个 snapshot
    fn span(self: @Array<T>) -> Span<T>;
}
```

大家加油💪！！
