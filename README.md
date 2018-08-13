# RunloopAddBigImage
runloop 加载本地大图的一点疑问


RunLoop
对管理输入源的对象的编程接口。


概述
RunLoop对象处理来自窗口系统、端口对象和NSConnection对象的源(如鼠标和键盘事件)的输入。RunLoop对象还处理计时器事件。

您的应用程序既不创建也不显式管理RunLoop对象。每个线程对象(包括应用程序的主线程)都有一个RunLoop对象根据需要自动创建。
如果需要访问当前线程的运行循环，可以使用类方法current进行访问。

请注意，从RunLoop的角度来看，计时器对象不是一种“输入”——它们是一种特殊类型，其中一件事就是它们在触发时不会导致run loop返回。


警告
一般不认为RunLoop类是线程安全的，它的方法只能在当前线程的上下文中调用。永远不要尝试调用在不同线程中运行的RunLoop对象的方法，
因为这样做可能会导致意想不到的结果。



Timer
一个计时器，在某一特定时间间隔后触发，向目标对象发送指定的消息。


概述
定时器与run loop一起工作。run loop维护对其计时器的强引用，因此在将计时器添加到run loop后，您不必维护自己对计时器的强引用。
要有效地使用计时器，您应该知道run loops是如何操作的。有关更多信息，请参阅"线程编程指南"。(线程编程指南)[https://developer.apple.com/documentation/foundation/timer]
