# Introduction

The primary use cases of eventkit are

* to send events between loosely coupled components;
* to compose all kinds of event-driven data pipelines.

The interface is kept as Pythonic as possible,
with familiar names from Python and its libraries where possible.
For scheduling asyncio is used and there is seamless integration with it.

See the examples and the
`introduction notebook <https://github.com/erdewit/eventkit/tree/master/notebooks/eventkit_introduction.ipynb>`_
to get a true feel for the possibilities.

# Examples

**Create an event and connect two listeners**

```python
import eventkit as ev


def f(a, b):
    print(a * b)


def g(a, b):
    print(a / b)


event = ev.Event()
event += f
event += g
event.emit(10, 5)
```

**Create a simple pipeline**


```python
import eventkit as ev

event = ev.Sequence("abcde").map(str.upper).enumerate()

print(event.run())  # in Jupyter: await event.list()
```

Output
```
[(0, 'A'), (1, 'B'), (2, 'C'), (3, 'D'), (4, 'E')]
```

**Create a pipeline to get a running average and standard deviation**

```python
import random
import eventkit as ev

source = ev.Range(1000).map(lambda i: random.gauss(0, 1))

event = source.array(500)[ev.ArrayMean, ev.ArrayStd].zip()

print(event.last().run())  # in Jupyter: await event.last()
```

Output
```
[(0.00790957852672618, 1.0345673260655333)]
```

**Combine async iterators together**

```python
import asyncio
import eventkit as ev


async def ait(r):
    for i in r:
        await asyncio.sleep(0.1)
        yield i


async def main():
    async for t in ev.Zip(ait("XYZ"), ait("123")):
        print(t)


asyncio.get_event_loop().run_until_complete(main())  # in Jupyter: await main()
```

Output
```
    ('X', '1')
    ('Y', '2')
    ('Z', '3')
```
