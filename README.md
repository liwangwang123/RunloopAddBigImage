# RunloopAddBigImage
runloop 加载本地大图的一点疑问


#### RunLoop
对管理输入源的对象的编程接口。


##### 概述
RunLoop对象处理来自窗口系统、端口对象和NSConnection对象的源(如鼠标和键盘事件)的输入。RunLoop对象还处理计时器事件。

您的应用程序既不创建也不显式管理RunLoop对象。每个线程对象(包括应用程序的主线程)都有一个RunLoop对象根据需要自动创建。
如果需要访问当前线程的运行循环，可以使用类方法current进行访问。

请注意，从RunLoop的角度来看，计时器对象不是一种“输入”——它们是一种特殊类型，其中一件事就是它们在触发时不会导致run loop返回。


##### 警告
一般不认为RunLoop类是线程安全的，它的方法只能在当前线程的上下文中调用。永远不要尝试调用在不同线程中运行的RunLoop对象的方法，
因为这样做可能会导致意想不到的结果。



#### Timer
一个计时器，在某一特定时间间隔后触发，向目标对象发送指定的消息。


##### 概述
定时器与run loop一起工作。run loop维护对其计时器的强引用，因此在将计时器添加到run loop后，您不必维护自己对计时器的强引用。
要有效地使用计时器，您应该知道run loops是如何操作的。有关更多信息，请参阅 [线程编程指南](https://developer.apple.com/documentation/foundation/timer)

计时器不是实时机制。如果计时器的触发时间发生在长时间调用run loop期间，或者当run loop处于不监视计时器的模式时，计时器直到下一次run loop检查计时器时才会触发。因此，计时器触发的实际时间可以明显延迟。参见[Timer Tolerance](https://developer.apple.com/documentation/foundation/timer)

Timer 与Core Foundation中的[CFRunLoopTimer](https://developer.apple.com/documentation/foundation/timer)对象桥接对应

##### 比较重复和非重复计时器
在创建时你可以指定计时器是重复的还是非重复的。非重复计时器触发一次，然后自动失效，从而防止计时器再次触发。相反，一个重复的计时器会触发，然后在
同一个run loop上重新调度自己。重复计时器总是根据预定的发射时间来调度自己，而不是实际的发射时间。例如，如果一个定时器计划在某个特定时间触发，并且每隔5秒就触发一次，即使实际触发时间被延迟，预定的触发时间也总是落在最初的5秒时间间隔上。如果发射时间延迟到超过一个或多个预定发射时间，则该计时器只在该时间段内发射一次;然后，在触发之后，计时器将被重新调度，用于以后的下一个预定的触发时间。

##### Timer Tolerance(公差)
在ios7和更高版本以及macOS 10.9和更高版本中，您可以指定计时器的tolerance(公差)。当计时器触发时的这种灵活性提高了系统的优化能力，从而提高了电能节约和响应能力。定时器可以在其预定的触发时间和预定的触发时间之间的任何时间加上公差。计时器不会在预定的触发时间之前触发。对于重复定时器，下一个触发时间从原始触发时间开始计算，而不考虑在每次触发时应用的公差，以避免漂移。默认值为零，这意味着不应用额外的公差。系统保留对某些计时器应用少量公差的权利，而不管公差属性的值如何。

作为计时器的用户，您可以确定计时器的适当容忍度。对于重复计时器，一般规则是将公差设置为间隔的至少10%。即使是少量的公差也会对应用程序的功耗产生显著的积极影响。系统可以强制执行公差的最大值。

var tolerance: TimeInterval { get set }

例子: 设置 timer 每5秒执行一次,在执行方法里添加一个让线程停止6秒的方法,这个时候,定时器是10秒执行一次,当错过预定时间,就会等下一次预期时间到来才可以执行. 
```
number:555832862.4579
number:555832872.076101
number:555832882.075639
number:555832892.074258
number:555832902.074344
```
例子: 和上面的例子一样,只是在第二次执行 timer 事件的时候,让线程停止6秒,设置 timer 的 tolerance = 2 ,只会在第二次的间隔为5 + 2秒,之后的间隔还是5秒,这样就可以保证定时器的准确度,即使在某一次的执行中,有一点点延时,也可以不用错过当次的方法执行
```
number:555834064.590296
number:555834071.552524
number:555834081.408324
number:555834086.551873
number:555834091.551736
number:555834095.84592
number:555834099.571294对应的RunLoop对象。
number:555834104.571263
```

##### 在Run Loops中调度计时器

可以一次只在一个 run loop 中注册一个计时器，尽管它可以添加到 run loop 中的多个运行循环模式中。有三种方法来创建计时器:

- 用 [scheduledTimer(timeInterval:invocation:repeats:)](https://developer.apple.com/documentation/foundation/timer)或者[scheduledTimer(timeInterval:target:selector:userInfo:repeats:)](https://developer.apple.com/documentation/foundation/timer)
类方法来创建计时器，并在当前 run loop 中以默认模式对其进行调度。

- 用 [init(timeInterval:invocation:repeats:)](https://developer.apple.com/documentation/foundation/timer)或者[init(timeInterval:target:selector:userInfo:repeats:) ](https://developer.apple.com/documentation/foundation/timer)
类方法创建计时器对象没有把它调度到run loop上。(在创建它之后，您必须通过对应的RunLoop对象调用[add(_:forMode:)](https://developer.apple.com/documentation/foundation/timer)方法。)

- 分配空间并初始化用 [init(fireAt:interval:target:selector:userInfo:repeats:)](https://developer.apple.com/documentation/foundation/timer)方法。(在创建它之后，您必须通过对应的RunLoop对象调用[add(_:forMode:)](https://developer.apple.com/documentation/foundation/timer)方法。)

一旦在 run loop 上调度，计时器将在指定的时间间隔触发，直到它失效。非重复计时器在触发后立即失效。但是，对于重复计时器，您必须通过调用其invalidate()方法使计时器对象自己失效。调用此方法要求从当前 run loop 中删除计时器;因此，您应该总是在创建计时器的线程中调用invalidate()方法。销毁计时器使其立即失效，不再影响 run loop 。然后run loop 删除计时器(以及它对计时器的强烈引用)要么就在invalidate()方法返回之前，要么就在稍后的某个时候。一旦失效，计时器对象就不能被重用。

在重复的计时器触发后，它会在指定的公差范围内为最近的未来日期安排下一次触发，该日期是上一次预定的触发日期之后的计时器间隔的整数倍。如果调用执行选择器或调用所花费的时间超过指定的时间间隔，则计时器只安排下一次触发;也就是说，计时器不会试图补偿在调用指定的选择器或调用时可能发生的任何遗漏的触发。
