# 11\_Cairo中的struct\(结构体\)
> 此文章使用的Cairo编译器版本：2.0.0-rc0。因为Cairo正在快速更新，所以不同版本的语法会有些许不同，未来将会将文章内容更新到稳定版本。
## 基本用法
定义一个struct：

```
#[derive(Copy, Drop)]
struct User {
    active: bool,
    username: felt252,
    email: felt252,
    sign_in_count: u64,
}
```

创建一个struct变量（注意⚠️：创建的时候，所有字段都需要赋值，漏了编译会报`error: Missing member`错误）：

```
#[derive(Copy, Drop)]
struct User {
    active: bool,
    username: felt252,
    email: felt252,
    sign_in_count: u64,
}

fn main() {
    let user1 = User {
        active: true, username: 'someusername123', email: 'someone@example.com', sign_in_count: 1
    };
}
```

使用struct变量的字段：

```
use debug::PrintTrait;

#[derive(Copy, Drop)]
struct User {
    active: bool,
    username: felt252,
    email: felt252,
    sign_in_count: u64,
}

fn main() {
    let user1 = User {
        active: true, 
        username: 'someusername123', 
        email: 'someone@example.com', 
        sign_in_count: 1
    };

    user1.active.print();
    user1.username.print();
}
```

修改struct变量字段的值。变量的可变性和不可变性同样约束着struct变量，所以如果要修改struct变量，该变量需要是可变变量（被 mut 关键词修饰）。如：

```
use debug::PrintTrait;

#[derive(Copy, Drop)]
struct User {
    active: bool,
    username: felt252,
    email: felt252,
    sign_in_count: u64,
}

fn main() {
    let mut user1 = User {
        active: true, 
        username: 'someusername123', 
        email: 'someone@example.com', 
        sign_in_count: 1
    };

    user1.username = 'shalom';
    user1.username.print();
}
```

以上user1变量是用了 `mut` 关键字修饰。注意⚠️：整个struct变量必须同时被修饰为 mutable，不可以只将其中的某几个字段单独修饰为 mutable。

## 一种实例化struct变量的便捷写法
在很多语言中，经常会用一个函数来专门实例化一个struct变量，如：

```
use debug::PrintTrait;

#[derive(Copy, Drop)]
struct User {
    active: bool,
    username: felt252,
    email: felt252,
    sign_in_count: u64,
}

fn init_user(active: bool, username: felt252, email: felt252, sign_in_count: u64) -> User {
    User { active: active, username: username, email: email, sign_in_count: sign_in_count }
}

fn main() {
    let mut user1 = init_user(true, 'someusername123', 'someone@example.com', 1);

    user1.username = 'shalom';
    user1.username.print();
}
```

以上代码中就使用了 `init_user` 函数来实例化 `User` struct 变量。

在这个 `init_user` 函数中，所有的参数和struct的字段名是一样的，所以我们可以这样简写：

```
fn init_user_simplify(active: bool, username: felt252, email: felt252, sign_in_count: u64) -> User {
	// 这里省略了 `active:` ...
    User { active, username, email, sign_in_count }
}
```

在函数内部给User字段赋值的时候，不需要再指明字段名了，直接使用相同名的函数参数就可以。

## 为struct定义成员方法(method)
大多数高级编程语言中都会有给 struct（或者称为object）定义成员方法的特性，Cairo也不例外。但是Cairo中实现这个功能需要借助[Trait](brain://7Ke1xxSUfUe9WtfovFXRZA/13Cairo%E4%B8%AD%E7%9A%84Trait)。如：

```
use debug::PrintTrait;

struct Rectangle {
    width: u32,
    high: u32
}

// 这里声明了一个 Trait
trait GeometryTrait {
    fn area(self: Rectangle) -> u32;
}

impl RectangleImpl of GeometryTrait {
	// 这里实现了 Trait 中的 area 方法，与 struct 产生联系的就是方法中的第一个参数
    fn area(self: Rectangle) -> u32 {
        self.width * self.high
    }
}

fn main() {
    let r = Rectangle {
        width: 10,
        high: 2,
    };

    r.area().print();
}
```

trait 提供方法的签名，也就是标识方法的名字、参数和返回值。impl 代码块中，将存放方法具体的逻辑，并且**需要包含 trait 中所有方法的逻辑**。

注意⚠️：impl中的代码与 struct 产生联系的要求比较苛刻：

1. **必须在方法的第一个参数指定关联的 struct**
2. **并且参数名必须为 self**
3. **一个impl里self变量需要是同一个struct**

可以理解为：impl是专属于一个struct类型的，且必须实现 trait 中所有方法的逻辑(trait的意思是特征)。
### trait 中的构造函数
trait中，不是所有的函数都是结构体成员，它可以包含不使用 self 参数的函数，而这一类函数也通常被用作 struct 的构造函数。如：

```
struct Rectangle {
    width: u32,
    high: u32
}

trait RectangleTrait {
    fn square(size: u32) -> Rectangle;
}

impl RectangleImpl of RectangleTrait {
    fn square(size: u32) -> Rectangle {
        Rectangle { width: size, high: size }
    }
}
```

以上 `square` 函数就是 Rectangle 的构造函数，它里面是没有 self 变量的。当我们需要实例化一个 Rectangle 变量时，就可以：`let square = RectangleImpl::square(10);`（这里使用的是 impl 哦！）。

### 一个 struct 关联多个 trait
struct 和 trait 之间相互独立，同一个 struct 可以实现多个 trait。如：

```
struct Rectangle {
    width: u32,
    high: u32
}

struct Rectangle2 {
    width: u32,
    high: u32
}

trait RectangleCalc {
    fn area(self: Rectangle) -> u32;
}
impl RectangleCalcImpl of RectangleCalc {
    fn area(self: Rectangle) -> u32 {
        (self.width) * (self.high)
    }
}

trait RectangleCmp {
    fn can_hold(self: Rectangle, other: Rectangle) -> bool;
}

impl RectangleCmpImpl of RectangleCmp {
    fn can_hold(self: Rectangle, other: Rectangle) -> bool {
        self.width > other.width && self.high > other.high
    }
}

fn main() {}
```

以上代码，Rectangle 就同时实现了 RectangleCalc 和 RectangleCmp 两个 trait。
