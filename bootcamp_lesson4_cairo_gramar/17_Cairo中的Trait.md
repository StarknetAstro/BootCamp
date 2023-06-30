# 17\_Cairo中的Trait
> 此文章使用的Cairo编译器版本：2.0.0-rc0。因为Cairo正在快速更新，所以不同版本的语法会有些许不同，未来将会将文章内容更新到稳定版本。

前面我们已经写了很多使用到 trait 的代码，我们现在就来将 trait 的用法总结一下。

Trait的字面意思是”特征”，相当于其他编程语言的 接口（interface）。可以使用 trait 定义一组方法作为这个 trait 具备的特征的具体内容，任何一个类型都可以实现这个 trait 中所有的方法，也就是拥有这个 trait 的特征。

## 基本用法
结构体实现一个 trait 时，需要实现 trait 中所有的方法，否则就不能算作为实现了这个 trait，编译的时候也会出错。看看一个例子：

```
use debug::PrintTrait;

#[derive(Copy, Drop)]
struct Rectangle {
    width: u64,
    high: u64
}

trait ShapeGeometry {
    fn new(width: u64, high: u64) -> Rectangle;
    fn boundary(self: @Rectangle) -> u64;
    fn area(self: @Rectangle) -> u64;
}

// 这里实现3个函数的逻辑
impl RectangleGeometryImpl of ShapeGeometry {
    fn new(width: u64, high: u64) -> Rectangle {
        Rectangle { width, high }
    }

    fn boundary(self: @Rectangle) -> u64 {
        2 * (*self.high + *self.width)
    }
    fn area(self: @Rectangle) -> u64 {
        *self.high * *self.width
    }
}

fn main() {
	// 这里直接使用 impl 调用 new 方法
    let r = RectangleGeometryImpl::new(10, 20);
    
    // 这里使用 结构体调用 boundary 和 area 方法
    r.boundary().print();
    r.area().print();

    // 使用 impl 直接调用 area 方法
    RectangleGeometryImpl::area(@r).print();
}
```

以上定义了一个名为 Rectangle 的结构体，接着定义了一个名为 ShapeGeometry 的 trait，trait 中包含三个方法的签名： `new`， `boundary` 和 `area` 。那么我们要为 结构体Rectangle 实现 trait ShapeGeometry ，就需要将 trait 中的3个函数的逻辑都写在 impl 中。

另外，我们在 main 函数中可以看到，我们还可以**直接使用impl调用成员函数**。

## 泛型 trait
上面的例子中，trait里面写明了 Rectangle 类型，那么这个trait就只可以被 Rectangle 实现。如果遇到多个类型有同一个 trait 特征的场景，就需要使用到泛型 trait。

```
use debug::PrintTrait;

#[derive(Copy, Drop)]
struct Rectangle {
    height: u64,
    width: u64,
}

#[derive(Copy, Drop)]
struct Circle {
    radius: u64
}

// 这个泛型 trait 可以被多个struct实现
trait ShapeGeometryTrait<T> {
    fn boundary(self: T) -> u64;
    fn area(self: T) -> u64;
}

// 被 Rectangle 类型实现
impl RectangleGeometryImpl of ShapeGeometryTrait<Rectangle> {
    fn boundary(self: Rectangle) -> u64 {
        2 * (self.height + self.width)
    }
    fn area(self: Rectangle) -> u64 {
        self.height * self.width
    }
}

// 被 Circle 类型实现
impl CircleGeometryImpl of ShapeGeometryTrait<Circle> {
    fn boundary(self: Circle) -> u64 {
        (2 * 314 * self.radius) / 100
    }
    fn area(self: Circle) -> u64 {
        (314 * self.radius * self.radius) / 100
    }
}

fn main() {
    let rect = Rectangle { height: 5, width: 7 };
    rect.area().print(); // 35
    rect.boundary().print(); // 24

    let circ = Circle { radius: 5 };
    circ.area().print(); // 78
    circ.boundary().print(); // 31
}
```

上面我们定义了 `ShapeGeometryTrait<T>` trait，它同时被 `Rectangle` 和 `Circle` 两个结构体实现，并且在main函数中使用相同名字的成员方法。
