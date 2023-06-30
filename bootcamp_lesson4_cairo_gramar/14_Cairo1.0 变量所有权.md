# 14\_Cairo1\.0 变量所有权
> 此文章使用的Cairo编译器版本：2.0.0-rc0。因为Cairo正在快速更新，所以不同版本的语法会有些许不同，未来将会将文章内容更新到稳定版本。


## 变量的作用域
变量的作用域，也可以理解为变量所有者的作用域，通常是指：变量的有效范围，或者可访问范围，它决定了变量的生命周期和可见性。我们来看个例子：

```
fn main() {
	...
    {
        // 在变量声明前不可以访问
        let mut v1 = 1; // 变量声明语句
        // 变量声明后，还未超出变量的作用域，可以访问
        v1 += 1;
    } // 花括号结尾，变量的作用域结束，下面将不可以再访问 v1 变量
    ...
}
```

上面变量v1在main函数内部的花括号代码块中被创建，所以v1的作用域就是：在v1被创建起，到花括号结束。这里的花括号使用的是普通的花括号， if、 loop 和 fn 的花括号同样适用。

## 变量所有权的由来
在编程中，会出现许多传递变量的情况。比如调用一个函数，将变量作为函数的参数传入。这个时候就出现了变量可以在多个作用域中穿梭的现象（注意⚠️：这里说的是现象，并非打破了变量作用域的规则）。

这个现象实现出来有两种方式：

1. **传递副本（传值）**。把一个变量的副本传到一个函数中，或是放到一个数据结构容器中，这时候就需要复制的操作。这个复制对于一个**对象**来说，需要深度复制才安全，否则就会出现各种问题，而**深度复制就会导致性能问题**。<br>
2. **传递对象本身（传引用）**。传引用也就是不需要考虑对象的复制成本，但是需要考虑对象在传递后，被多个地方引用的问题。比如：我们把一个对象的引用 写入到一个数组中 或 传入其它的一个函数。这意味着，大家对同一个对象都有控制权，如果有一个人释放了这个对象，那边其它人就遭殃了，所以，一般会采用**引用计数**的规则来共享一个对象。

这里提到的控制权，演变出了Cairo中的变量所有权的概念。

## Cairo变量所有权的规则
在Cairo中，Cairo强化了”所有权”的概念，下面是Cairo变量所有权的三大铁律：

1. Cairo 中的每一个值都有一个 **所有者**（owner）。
2. 同一时间只有一个所有者。
3. 当变量离开 所有者 作用域时，这个变量将被丢弃（Drop）。

为了体会以上三个规则对代码的影响，可以看下面这段Cairo代码：

```
use core::debug::PrintTrait;

struct User {
    name: felt252,
    age: u8
}

// takes_ownership 取得调用函数传入参数的所有权，因为不返回，所以变量进来了就出不去了
fn takes_ownership(s: User) {
    s.name.print();
} // 这里，变量 s 移出作用域并调用 drop 方法。占用的内存被释放

// gives_ownership 将返回值所有权 move 给调用它的函数
fn give_ownership(name: felt252,age: u8)->User{
    User{name,age}
}

fn main() {
    // gives_ownership 将返回值移给 s
    let s = gives_ownership();
    
    // 所有权转给了 takes_ownership 函数, s 不可用了
    takes_ownership(s);
    
    // 如果编译下面的代码，会出现s1不可用的错误
    // s.name.print();
}
```

把一个对象的所有权移动到给另外一个对象，这样的操作被称作move。这样的 Move 方式，在性能上和安全性上都是非常有效的，而Cairo的编译器会帮你检查出*使用了”所有权被move走的变量”的错误*。

注⚠️：现在基本类型的变量（felt252，u8 等）都已经实现了 Copy Trait，所以使用基本类型变量不会出现move的情况，所以，为了展现move的效果，上面使用了一个未实现 Copy Trait 的 struct 来作为 `takes_ownership` 函数的参数。

### 结构体字段也可以被单独move
结构体字段可以被move，所以在其他语言中看似很正常的代码，在Cairo中编译会报错：

```
use core::debug::PrintTrait;

#[derive(Drop)]
struct User {
    name: felt252,
    age: u8,
    school: School
}

#[derive(Drop)]
struct School {
    name: felt252
}

fn give_ownership(name: felt252, age: u8, school_name: felt252) -> User {
    User { name: name, age: age, school: School { name: school_name } }
}

fn takes_ownership(school: School) {
    school.name.print();
}

fn use_User(user: User) {}

fn main() {
    let mut u = give_ownership('hello', 3, 'high school');
    takes_ownership(u.school); // 将结构体中的 school 字段单独传入，这样 school 字段就被 move

    // u.school.name.print(); // school字段已经被move，所以这里编译出错
    u.name.print(); // name字段还是可以照常访问

    // use_User(u); // 此时因为school字段被move，整个结构体都不可以被move了

    // 如果重新给结构体的school字段赋值，这个结构体变量又可以继续被move了
    u.school = School{
        name:'new_school'
    };
    use_User(u)
}
```

结构体中的成员是可以被Move掉的，如果访问 move 掉的成员会出现编译问题，但是依然可以访问结构体其他成员。

另外，其中一个字段被move，整个结构体将不可以再被move，如果将被move的字段重新赋值，结构体又可以继续被move了。


## Copy trait
Copy trait 就是值拷贝的特征（trait）。任何类型实现了 copy trait，那么当它作为函数参数传入时，就会传入一份拷贝的副本。给类型添加 copy trait 方式如下：

```
use core::debug::PrintTrait;

#[derive(Copy,Drop)]
struct User {
    name: felt252,
    age: u8
}

fn give_ownership(name: felt252,age: u8)->User{
    User{name,age}
}

fn takes_ownership(s: User) {
    s.name.print();
}

fn main() {
    let s = give_ownership('hello',3);
    s.age.print();
    takes_ownership(s);
    s.name.print(); // 由于 User 实现了 Copy trait，所以上面并没有转移 s 的所有权，这里依然可以访问 s
}
```

使用 Copy trait 时有一些限制需要注意：如果一个类型中包含没有实现 copy trait 的字段，那么这个类型就不可以被添加 copy trait。


## Drop trait
Drop trait 中包含的方法可以理解为一个析构函数（destructor），与构造函数（constructor）相对应。析构函数（destructor）在对象被销毁时自动调用，用于清理对象所占用的资源或状态。相反，构造函数用于初始化对象的状态。

前文提到变量的作用域，当一个变量要超出它的作用域时，就意味着这个变量到了生命周期的终点，此时就需要使用 Drop，来将这个变量占用的资源清理掉。如果一个类型没有实现  Drop trait，那么编译器会捕获到，并且抛出错误。如：

```
use core::debug::PrintTrait;

// #[derive(Drop)]
struct User {
    name: felt252,
    age: u8
}

fn give_ownership(name: felt252,age: u8)->User{
    User{name,age}
}

fn main() {
    let s = give_ownership('hello',3);
    //  ^ error: Variable not dropped.
}
```

上面代码将会编译报错，如果将 `#[derive(Drop)]` 注释解除，那么就为 `User` 类型添加了 Drop trait，此时它就可以被  Drop，编译就不会报错。另外，标量类型默认都实现了 Drop trait。

## Destruct trait
目前已知使用到 Destruct trait 的地方是字典。因为字典不能实现 Drop trait，但是实现了 Destruct trait，这让它在超过它的作用域的时候，可以自动的调用 squashed 方法进行内存释放。所以在写一个包含字典的struct的时候就需要注意，如：

```
use dict::Felt252DictTrait;
use traits::Default;

#[derive(Destruct)]
struct A{
    mapping: Felt252Dict<felt252>
}

fn main(){
    A { mapping: Default::default() };
}
```

结构体 A 需要指明实现了 Destruct trait，不然会编译报错；另外，也不可以是 Drop trait，因为 Felt252Dict 无法实现 Drop trait。

## 总结
将变量作为函数的参数传入，要么传入的是一个副本，要么传入的是变量本身，同时发生所有权的转移，作用域也随之改变。 另外函数的返回值同样也可以实现所有权转移。

当一个变量超出它的作用域，它就会被Drop或者Destruct。

以上的动作，就分别对应了 Copy、Drop 和 Destruct 三个 traits。

此文章部分内容参考一位大佬的文章，向他缅怀、致敬🫡
