# 16\_Cairo1\.0中的泛型\(Generic\)
> 此文章使用的Cairo编译器版本：2.0.0-rc0。因为Cairo正在快速更新，所以不同版本的语法会有些许不同，未来将会将文章内容更新到稳定版本。

泛型是一种编程语言特性，它允许在编写代码时使用类型参数，这些类型参数可以在代码实例化时被具体类型替换。

实际编程中，我们设计好了一套算法来高效地处理业务上的一些问题。如果没有泛型的话，每个类型就需要复制一份同一套算法的代码。理想情况下，算法应是和数据结构以及类型无关的，各种特殊的数据类型理应做好自己分内的工作，算法只关心一个标准的实现。

所以，泛型很酷😎

Cairo中，泛型可以用在：函数、结构体、枚举 和 Trait中的Method里面。

## 函数中的泛型
函数中如果传入包含泛型的参数，需要在参数前面的 `<>` 中声明泛型，而且这将作为函数签名的一部分。接下来我们来实现一个”找出泛型数组中最小的泛型元素”的功能：

```
use debug::PrintTrait;
use array::ArrayTrait;

// PartialOrd 实现泛型变量之间的比较
fn smallest_element<T, impl TPartialOrd: PartialOrd<T>, impl TCopy: Copy<T>, impl TDrop: Drop<T>>(
    list: @Array<T>
) -> T {
	// 这里使用了 * ，所以 T 必须实现了 copy trait
    let mut smallest = *list[0];

    let mut index = 1;

    loop {
        if index >= list.len() {
            break smallest;
        }
        // 这里是两个泛型变量之间的比较，需要实现 PartialOrd
        if *list[index] < smallest {
            smallest = *list[index];
        }
        index = index + 1;
    }
}

fn main() {
    let mut list: Array<u8> = ArrayTrait::new();
    list.append(5);
    list.append(3);
    list.append(10);

    let s = smallest_element(@list);
    assert(s == 3, 0);
    s.print();
}
```

可以看到，我们在泛型声明区域，对泛型 `T` 添加了许多修饰（可以取名为T，也可以取其他的名）。泛型可以是任意数据类型，如果数据类型能符合通用算法，势必就会对传入的数据类型有一定的约束，而我们在 `<>` 里添加的 impl，就是对传入此函数的泛型的约束。

1. 首先，我们从 T 的 snapshot 中取值了，那么 T 就必须实现了 Copy trait；
2. 其次，T 类型变量 smallest 最终作为函数的返回值，返回到main函数中，这步即包含了 move 操作，同时也有 Drop 操作，所以需要实现 Drop trait；
3. 最后，我们需要比较两个泛型的大小，所以需要实现 PartialOrd trait。

所以我们看到函数中声明泛型的部位有这么一段： `<T, impl TPartialOrd: PartialOrd<T>, impl TCopy: Copy<T>, impl TDrop: Drop<T>>`。调用这个函数时，参数数组中的所有元素都必须实现这三个约束中描述的 trait。

## 结构体中的泛型
结构体元素中也可以放入泛型字段，如：

```
struct Wallet<T> {
    balance: T
}

impl WalletDrop<T, impl TDrop: Drop<T>> of Drop<Wallet<T>>;
```

```
#[derive(Drop)]
struct Wallet<T> {
    balance: T
}
```

以上两种方式，应该都可以。Cairo book 中说第二种方式不会将类型 T 声明为：实现了 Drop trait，但是没有给出一些案例代码。我实验了几次，目前都没有发现有什么区别，后续发现了再加上。

### 结构体Method中使用泛型

以下代码我们可以看到，在struct、trait 和 impl 中都需要声明泛型，impl中因为存储了算法逻辑，所以需要添加约束。

```
use debug::PrintTrait;

#[derive(Copy,Drop)]
struct Wallet<T> {
    balance: T
}

trait WalletTrait<T> {
    fn balance(self: @Wallet<T>) -> T;
}

impl WalletImpl<T, impl TCopy: Copy<T>> of WalletTrait<T>{
    fn balance(self: @Wallet<T>) -> T{
        *self.balance
    }
}

fn main() {
    let w = Wallet{balance:'100 000 000'};

    w.balance().print();
}
```

再看一个同时使用两个不同泛型的例子：

```
use debug::PrintTrait;

#[derive(Copy,Drop)]
struct Wallet<T, U> {
    balance: T,
    address: U,
}

trait WalletTrait<T, U> {
    fn getAll(self: @Wallet<T, U>) -> (T, U);
}

impl WalletImpl<T, impl TCopy: Copy<T>, U, impl UCopy: Copy<U>> of WalletTrait<T, U>{
    fn getAll(self: @Wallet<T, U>) -> (T, U){
        (*self.balance,*self.address)
    }
}

fn main() {
    let mut w = Wallet{
        balance: 100,
        address: '0x0000aaaaa'
    };

    let (b,a) = w.getAll();
    b.print();
    a.print();
}
```

## 枚举中的泛型
刚好Option就是一个使用了泛型的枚举：

```
enum Option<T> {
    Some: T,
    None: (),
}
```
