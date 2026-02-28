# Copyright Justin R. Goheen.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import asyncio
import itertools
import time

from ib_interface.eventkit.event import Event
from ib_interface.eventkit.ops.op import Op
from ib_interface.eventkit.util import get_event_loop, NO_VALUE, timerange


class Wait(Event):
    __slots__ = ("_task",)

    def __init__(self, future, name="wait"):
        Event.__init__(self, name)
        if future.done():
            self._task = None
            self.set_done()
        else:
            loop = get_event_loop()
            self._task = asyncio.ensure_future(future, loop=loop)
            future.add_done_callback(self._on_task_done)

    def _on_task_done(self, task):
        try:
            result = task.result()
        except Exception as error:
            result = NO_VALUE
            self.error_event.emit(self, error)
        self.emit(result)
        self._task = None
        self.set_done()

    def __del__(self):
        if self._task:
            self._task.cancel()


class Aiterate(Event):
    __slots__ = ("_task",)

    def __init__(self, ait):
        Event.__init__(self, ait.__qualname__)
        loop = get_event_loop()
        self._task = asyncio.ensure_future(self._looper(ait), loop=loop)

    async def _looper(self, ait):
        try:
            async for args in ait:
                self.emit(args)
        except Exception as error:
            self.error_event.emit(self, error)
        self._task = None
        self.set_done()

    def __del__(self):
        if self._task:
            self._task.cancel()


class Sequence(Aiterate):
    __slots__ = ()

    def __init__(self, values, interval=0, times=None):
        async def sequence():
            t0 = time.time()
            if times is not None:
                for t, value in zip(times, values):
                    delay = max(0, time.time() + t - t0)
                    await asyncio.sleep(delay)
                    yield value
            else:
                for i, value in enumerate(values):
                    delay = max(0, i * interval + t0 - time.time())
                    await asyncio.sleep(delay)
                    yield value

        Aiterate.__init__(self, sequence())


class Repeat(Sequence):
    __slots__ = ()

    def __init__(self, value, count, interval=0, times=None):
        Sequence.__init__(self, itertools.repeat(count), interval, times)


class Range(Sequence):
    __slots__ = ()

    def __init__(self, *args, interval=0, times=None):
        Sequence.__init__(self, range(*args), interval, times)


class Timerange(Aiterate):
    __slots__ = ()

    def __init__(self, start=0, end=None, step=1):
        Aiterate.__init__(self, timerange(start, end, step))


class Timer(Aiterate):
    __slots__ = ()

    def __init__(self, interval, count=None):
        async def timer():
            t0 = time.time()
            i = 0
            while count is None or i < count:
                i += 1
                delay = i * interval + t0 - time.time()
                await asyncio.sleep(delay)
                yield i * interval

        Aiterate.__init__(self, timer())


class Marble(Op):
    __slots__ = ()

    def __init__(self, s, interval=0, times=None):
        s = s.replace("_", "")
        source = Event.sequence(s, interval, times).filter(lambda c: c not in "- ").takewhile(lambda c: c != "|")
        Op.__init__(self, source)
