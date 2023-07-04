# 13\_Cairo1\.0中的Map\(映射\)
> 此文章使用的Cairo编译器版本：2.0.0-rc0。因为Cairo正在快速更新，所以不同版本的语法会有些许不同，未来将会将文章内容更新到稳定版本。

## 基本用法
Map也可以被称为字典(dictionary)，Cairo中就是以字典来称呼的。基本用法主要包括：创建、插入键值对数据 和 读取数据。先看一些例子：

```
use core::debug::PrintTrait;
use dict::Felt252DictTrait;
use traits::Default;

fn main(){
    let mut map : Felt252Dict<felt252> = Default::default();
    map.insert(1,'shalom');
    map[1].print();
}
```

首先创建一个字典，需要使用到  Default trait，它返回一个初始状态的字典，类型是Felt252Dict。同时也需要指明字典中的变量类型是什么。以上创建的map，类型就是 `Felt252Dict<felt252>`。

`Felt252Dict` 是目前Cairo支持的字典类型，它只可以使用 felt252 类型的变量作为键，值可以是多种类型：`u8`, `u16`, `u32`, `u64`, `u128`, `felt252`。所以它被命名为 Felt252Dict。

插入键值对数据则是使用 insert(key, value) 成员函数，第一个参数为key，第二个参数为value。

读取比较好理解，中括号里加入key `map[key]`。
