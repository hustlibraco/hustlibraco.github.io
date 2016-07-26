---
title: 支持select和input的JS组件
date: 2016-07-21 13:24:46
tags: [Javascript]
---

其实一直以来都不喜欢写JS，但是工作中又不可避免的要写一些前台的用户交互，之前每次都是现写现查，以至于写了不少前端代码都没有积累。既然不能逃避，不如选择接受，从现在起开始有意识得积累一些前端经验。<!-- more -->


JS作为一门语言，其设计品味不敢恭维，但是得益于多年在浏览器上的耕耘，无数前端工作者在其上面的工作令其大放异彩。从早期的JQuery到现在的AngularJS、ReactJS、NodeJS，JS自身的语义设计也随着ES6的发布变得越来越完善，也许JS未来会成为一门“真正”的好语言吧。

扯了那么多，现在进入正题。作为一个业余的JS开发者，自己开发组件显然不是一种好选择，在我碰到一个既可以让用户选择也能让用户自行输入的表单字段时陷入了困扰。在`github`上的搜索让我找到了`select2.js`这个组件，真的非常强大。

其中一个选项满足了我的业务：

```javascript
<!-- 必要文件的包含 -->
<script type="text/javascript" src="dist/js/select2.min.js"></script>
···

<!-- select 框 -->
<select name="handler" class="form-control js-example-tags" multiple="multiple">
    <option value="1">orange</option>
    <option value="2">purple</option>
    <option value="3">bule</option>
</select>

<!-- 启用组件 -->
$(".js-example-tags").select2({
  tags: true
})
```
效果：

![select-tag](/images/select-tag.png)


更多用法：http://select2.github.io/examples.html#tags