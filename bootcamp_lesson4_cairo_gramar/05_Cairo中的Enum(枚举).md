# 05\_Cairo中的Enum\(枚举\)
> 此文章使用的Cairo编译器版本：2.0.0-rc0。因为Cairo正在快速更新，所以不同版本的语法会有些许不同，未来将会将文章内容更新到稳定版本。

Cairo中的枚举是一组类型的枚举，或者可以说是多个子类型公用一个枚举类型。适用的场景是：一组有着共同点的类型，但是每个类型又有许多不同，而且同一时刻相互之间互斥。

## 基本使用介绍
比如：IP有两个版本，IPV6 & IPV4。这两个版本同样是IP的版本号，并且同一个值只会是其中一种类型，那么这时候就可以使用枚举。定义方式如下。

```
enum IpAddrKind {
    V4:(),
    V6:(),
}
```

使用Enum实例化变量

```
let four = IpAddrKind::V4(());
let six = IpAddrKind::V6(());
```

V4和V6在函数传参的时候，都可以算作一个类型 IpAddrKind。

```
#[derive(Drop)] 
enum IpAddrKind {
    V4: (),
    V6: (),
}

fn route(ip_kind: IpAddrKind) {}

fn main() {
    route(IpAddrKind::V4(()));
    route(IpAddrKind::V6(()));
}
```

## 在枚举中添加类型
和Rust一样，我们可以将各种类型都添加到枚举中，枚举中的每个元素就像是类型的别名。

```
#[derive(Drop)]
enum Message {
    Quit: (),
    Echo: felt252,
    Move: (usize, usize),
    ChangeColor: (u8, u8, u8)
}

fn route(msg: Message) {}

fn main() {
    route(Message::Quit(()));
    route(Message::Echo(20));
    route(Message::Move((32_usize, 32_usize)));
    route(Message::ChangeColor((8_u8, 8_u8, 8_u8)));
}
```

上面将 felt252、tuple 添加到了 Message 这个 enum 中，并且将对应类型的变量作为 route 的参数。

## 给enum添加impl
我们可以给[struct](brain://fddw8wapEEmJOwehjI5XaA/Rust%E4%B8%AD%E7%9A%84Struct)添加impl，定义funcitons，同样也可以使用在enum上。代码案例如下：

```
use debug::PrintTrait;

#[derive(Drop)]
enum Message {
    Quit: (),
    Echo: felt252,
    Move: (usize, usize),
    ChangeColor: (u8, u8, u8)
}

trait Processing {
    fn process(self: Message);
}

impl ProcessingImpl of Processing {
    fn process(self: Message) {
        match self {
            Message::Quit(()) => {
                'quitting'.print();
            },
            Message::Echo(value) => {
                value.print();
            },
            Message::Move((x, y)) => {
                'moving'.print();
            },
            Message::ChangeColor((x, y, z)) => {
                'ChangeColor'.print();
            },
        }
    }
}
```

这样给数据类型带来了极大的丰富性。
