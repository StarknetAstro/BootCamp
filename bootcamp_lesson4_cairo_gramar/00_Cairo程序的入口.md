# 00\_Cairo程序的入口
> 此文章使用的Cairo编译器版本：2.0.0-rc0。因为Cairo正在快速更新，所以不同版本的语法会有些许不同，未来将会将文章内容更新到稳定版本。
## 单文件Cairo程序入口
与大多数编程语言类似，单文件的Cairo程序入口是main函数。

```
use debug::PrintTrait;

const ONE_HOUR_IN_SECONDS: felt252 = 3600;

fn main(){
    ONE_HOUR_IN_SECONDS.print();
}
```

运行命令：

```
cairo-run $file_path
```

main函数可以有返回值，如下：

```
fn main() -> felt252 {
   return 10; 
}
```

返回值会输出在这行的中括号里：<br>
```
Run completed successfully, returning [10]
```

## Starknet智能合约入口

使用 `#[starknet::contract]` 开头，在 mod 后面加上合约名。

```
#[starknet::contract]
mod ERC20 {
	...
}
```
