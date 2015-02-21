---
layout: post
title: "CoffeeScript 常用语法介绍"
date: 2013-05-05 20:45
comments: true
category: javascript
tags: ['CoffeeScript']
---


本篇文章假定大家对[CoffeeScript](http://coffeescript.org)有一点的了解或者[Python](http://www.python.org/)、[Ruby](http://www.ruby-lang.org/)也行

## 同步查看编译结果
前提已安装[nodejs](http://nodejs.org/)和[npm](https://npmjs.org/)模块

```
npm install -g coffee-script
rem 该命令会在当前目录生成experimental.js
coffee --watch --compile experimental.coffee
```

## 注释添加

``` coffee
# A comment

##
  A multiline comment, perhaps a LICENSE.
###
```


## 变量定义

``` coffee
myVariable = "test"

# 对象定义
object2 = one: 1
object2 = one: 1, two: 2
# 多行可不加逗号
object2 = 
  one: 1
  two: 2

# 数组定义
array1 = [1, 2, 3]
# 多行可不加逗号
array1 = [
  1
  2
  3
]

# 定义值为1到5的数组
range = [1..5]
#  编译后的javascript代码为：
# var range;
# range = [1, 2, 3, 4, 5];

# 重新赋值最后三个
range[2..4] = [-2, -3, -4]
my = "my string"[0..2]

firstTwo = ["one", "two", "three"][0..1]
# 编译后的javascript代码为：
# var firstTwo;
# firstTwo = ["one", "two", "three"].slice(0, 2);

# 全局变量定义
# without browsers
exports = @
exports.MyVariable = "foo-bar"

# window in browsers
window.MyVariable = "foo-bar"
```

## 别名和存在的操作

``` coffee
@saviour = true
# @代替this. 编译后的javascript代码为：
# this.saviour = true;

User::first = -> @records[0]
# ::代替.prototype. 编译后的javascript代码为：
#User.prototype.first = function() {
#  return this.records[0];
#};

praise if brian?
# 编译后的javascript代码为：
# if (typeof brian !== "undefined" && brian !== null) {
#  praise;
#}

# 注意不带问号的区别
praise if brian
# 编译后的javascript代码为：
# if (brian) {
#  praise;
#}
praise = brian ? "none"
# 不存在赋值"none" 编译后的javascript代码为：
# praise = typeof brian !== "undefined" && brian !== null ? brian : "none";

blackKnight.getLegs()?.kick()
# 如果blackKnight.getLegs()返回值存在则调用kick方法 编译后的javascript代码为：
# var _ref;
# if ((_ref = blackKnight.getLegs()) != null) {
#  _ref.kick();
#}

blackKnight.getLegs().kick?()
# 如果blackKnight.getLegs()返回值存在且是一个方法则调用kick方法 编译后的javascript代码为：
# var _base;
# if (typeof (_base = blackKnight.getLegs()).kick === "function") {
#   _base.kick();
# }
```

## 方法定义

``` coffee
# 单行
func = -> "bar"
# 多行
func = ->
  # An extra line
  "bar"
# 编译后的javascript代码为：
#  func = function() {
#    return "bar";
#  };

# 带参数
times = (a, b) -> a * b
# 编译后的javascript代码为：
#  times = function(a, b) {
#    return a * b;
#  };

# 参数带默认值
times = (a = 1, b = 2) -> a * b
# 编译后的javascript代码为：
#  times = function(a, b) {
#    if (a == null) {
#      a = 1;
#    }
#    if (b == null) {
#      b = 2;
#    }
#    return a * b;
#  };

# 数组参数支持其中nums为数组，类似java中的Object...
sum = (nums...) -> 
  result = 0
  nums.forEach (n) -> result += n
  result
# 编译后的javascript代码为：
#  sum = function() {
#    var nums, result;
#
#    nums = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
#    result = 0;
#    nums.forEach(function(n) {
#      return result += n;
#    });
#    return result;
#  };
```

## 方法调用

``` coffee
a = "Howdy!"

alert a
# 编译后的javascript代码为：
# alert(a)

alert inspect a
# 编译后的javascript代码为：
# alert(inspect(a))

# 匿名函数参数传递
clickHandler => alert "clicked"
# 编译后的javascript代码为：
#  clickHandler(function() {
#    return alert("clicked");
#  });


# 上下文保持一致免去 self=this的代码
@clickHandler = -> alert "clicked"
element.addEventListener "click", (e) => @clickHandler(e)

#建议括号在参数复杂的情况下不要省略
```

## 标识替换

``` coffee
favourite_color = "Blue. No, yel..."
# question中的#{favourite_color}将被替换
question = "Bridgekeeper: What... is your favourite color?
            Galahad: #{favourite_color}
            Bridgekeeper: Wrong!
            "
```

## 控制语句
对于表达式参考[这里](http://coffeescript.org/#operators)

``` coffee
# 单行
if a then alert a
if a then alert a else alert 'none'
alert a if a
# 多行
if a
	alert a
# 判断包含if in 
words = ["rattled", "roudy", "rebbles", "ranks"]
alert "Stop wagging me" if "ranks" in words 

# 循环
alert "Release #{name}" for name in ["Roger", "Roderick", "Brian"]
for name in ["Roger", "Roderick", "Brian"]
  alert "Release #{name}"

# 带序号表达式中i
for name, i in ["Roger the pickpocket", "Roderick the robber"]
  alert "#{i} - Release #{name}"

# 带过滤条件使用关键字when，以"B"开头
namelist = ["Roger", "Roderick", "Brian"]
alert "Release #{name}" for name in namelist when name[0] is "B"

# 注意when和if的区别
alert "Release #{name}" for name in namelist if namelist

# 遍历对象属性使用关键字of，别跟in混了
names = sam: seaborn, donna: moss
alert "#{first} #{last}" for first, last of names
# 编译后的javascript代码为：
#  names = {
#    sam: seaborn,
#    donna: moss
#  };
#  for (first in names) {
#    last = names[first];
#    alert("" + first + " " + last);
#  }

# 以数组的形式返回循环结果
num = 6
list = while num -= 1
  num + " Brave Sir Robin ran away"
```

详细查看The Little Book on CoffeeScript [Syntax](http://arcturo.github.io/library/coffeescript/02_syntax.html) 和[官方文档](http://coffeescript.org/#language)

## Classes

### 定于对象

``` coffee
class Animal

# 包含构造函数
class Animal
  constructor: (name) ->
    @name = name

# 自动赋值实例变量name
class Animal
  constructor: (@name) ->

# 包含实例属性
class Animal
  price: 5
  sell: (customer) ->
  	alert "Give me #{@price} shillings!"

# 使用=>确保this一定指向当前实例，即使存在继承
class Animal
  price: 5
  sell: (customer) =>
    alert "Give me #{@price} shillings!"
# 添加静态属性，使用@或者this
class Animal
  @price: 5
  @sell: (customer) ->
  	alert "Give me #{@price} shillings!"
```

### 创建实例

``` coffee
animal = new Animal
```

### 继承

``` coffee
class Animal
  constructor: (@name) ->

  alive: ->
    false

class Parrot extends Animal
  constructor: ->
    super("Parrot")

  dead: ->
    not @alive()
```

Mixins、Extending classes这个得理解才好用，大家还是看[原文](http://arcturo.github.io/library/coffeescript/03_classes.html)吧




