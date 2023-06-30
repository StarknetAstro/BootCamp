# 15\_Cairo1\.0 中的Snapshot和引用
> 此文章使用的Cairo编译器版本：2.0.0-rc0。因为Cairo正在快速更新，所以不同版本的语法会有些许不同，未来将会将文章内容更新到稳定版本。

在[14\_Cairo1.0 变量所有权](brain://api.thebrain.com/zBJh6lmfMEWrNhIe90B2qA/P2eL1eZxZkSCx7BAalDclQ/14Cairo10%E5%8F%98%E9%87%8F%E6%89%80%E6%9C%89%E6%9D%83)一文中我们有提到Copy trait，实现了Copy trait的对象在被传入函数中的时候，会自动将变量复制，并且将副本传入到函数里。另外，如果变量没有实现 Copy trait，被传入函数的时候就会发生move操作。但是，在编程过程中，我们往往想在上下文中保留变量的所有权，又不想发生复制操作，这时候就可以使用 snapshot 和 reference。

## Snapshot
Snapshot是变量在某一个时刻的值，具有不可变 和 只读两个特性，所以它适合用在传入参数到函数中，但是不修改参数的情况下使用（类似合约中的view函数）。
### 基本用法
Cairo是使用 `@` 操作符和 `*` 操作符来使用 snapshot 的，@用来获取快照，*用来读取快照的值。看：

```
use debug::PrintTrait;

#[derive(Drop, Copy)]
struct Student {
    name: felt252,
    age: u8,
}

fn print_student(s: @Student) {
    // s.name.print(); // 编译错误
    (*s).name.print();
}

fn main() {
    let mut s = Student { name: 'sam', age: 17 };

    let snapshot01 = @s;
    // 修改 s 的值，看看snapshot01会不会更改
    s.name = 'tom';
    print_student(snapshot01);
    print_student(@s);
}
```

上面代码中，我们创建了一个 可变的 Student 结构体变量 s，通过@操作符，获得了snapshot01。然后修改了s的name字段，并且使用 * 操作符，将 snapshot01 和最新的snapshot的name字段都打印出来。输出的结果是：一个是 sam，一个是 tom。可以知道，snapshot不会随着原本变量的变化而更改。

还有一个要求是：类型必须实现了 Copy trait 才可以使用 * 操作符读取 snapshot 的值。

注意⚠️：在 `(*s).name.print();` 链式调用中，*操作符的优先级是最低的，所以需要使用括号，优先将snapshot的值取出。

### 数组和Snapshot
在[12_Cairo1.0中的Array(数组)](brain://api.thebrain.com/zBJh6lmfMEWrNhIe90B2qA/HfHSeA5k8UKOYYnliP0A5Q/12Cairo10%E4%B8%AD%E7%9A%84Array%E6%95%B0%E7%BB%84)里我们讲到，数组没有实现 Copy trait，所以它作为函数参数时会产生move操作。另外，没有实现 Copy trait 的类型是不可以使用 `*` 操作符将值从快照中取出的。即使这样，我们依然可以使用 snapshot 来避免数组的move操作。如：

```
use debug::PrintTrait;
use array::ArrayTrait;

fn use_array(arr: @Array<usize>) {
    arr.len().print();
    let v_z = *arr.at(0);
    v_z.print();
}

fn main(){
    let mut arr = ArrayTrait::<usize>::new();
    arr.append(9);

    use_array(@arr);
}
```

数组的整体不可以使用 `*` 操作符，但是其中的元素是可以使用的。刚好 at 返回的是元素的snapshot，所以我们可以将所在的元素提取出来。

有一个比较神奇的点在于，数组的snapshot可以使用`[]`来代替`at`，我们来看看：

```
use debug::PrintTrait;
use array::ArrayTrait;

fn use_array(arr: @Array<usize>) {
    arr.len().print();
    // 这里使用 *arr[0] 代替了 *arr.at(0)
    let v_z = *arr[0];
    v_z.print();
}

fn main(){
    let mut arr = ArrayTrait::<usize>::new();
    arr.append(9);

    use_array(@arr);
}
```

依然可以编译通过，而且仅限于数组的snapshot，数组直接读取会报错。

另外数组中的 get 成员函数貌似无法使用，下面代码会编译报错：

```
use debug::PrintTrait;
use array::ArrayTrait;
use option::OptionTrait;

fn use_array(arr: @Array<usize>) {
    match arr.get(0) {
        Option::Some(v) => {
            // 这里无法使用 * 来读取相关的值
            let tem = *v.unbox();
            tem.print();
        },
        Option::None(_) => {}
    }
}

fn main() {
    let mut arr = ArrayTrait::<usize>::new();
    arr.append(9);

    use_array(@arr);
}
```
## 引用(reference)
当我们需要在函数中修改参数的值，又同时在调用函数的时候保留上下文，这时候就需要使用到引用。看看如何使用：

```
use core::debug::PrintTrait;

#[derive(Copy, Drop)]
struct Rectangle {
    width: felt252,
    high: felt252,
}

fn setWidth(ref r: Rectangle, new_width: felt252) {
    r.width = new_width;
}

fn main() {
    let mut r = Rectangle { width: 100, high: 200 };
    setWidth(ref r, 300);
    r.width.print();
}
```

以上代码，打印出来的 width 是 setWidth 函数中设置的值。我们可以看到，即使将变量 r 传入到函数setWidth中，依然不影响 main 函数读取 r 变量的值，而且打印出来的是经过函数setWidth设置的值。

引用是使用 ref 关键字指定的，在定义函数的时候就需要指定，传入参数的时候，也需要指定，表明传入的是引用。另外，使用 ref 标识的变量必须是可变变量。

在Cairo_book中写到：引用其实是两个move操作的简写，也就是将传入的变量 move 到调用的函数中，再隐式将所有权move回来的操作。

### 数组使用ref的例子

```
use debug::PrintTrait;
use array::ArrayTrait;

fn main() {
    let mut arr0 = ArrayTrait::new();
    fill_array(ref arr0);
    // 这里打印出 fill_array 添加的值
	arr0.print();
}

fn fill_array(ref arr0: Array<felt252>) {
    arr0.append(22);
    arr0.append(44);
    arr0.append(66);
}
```
