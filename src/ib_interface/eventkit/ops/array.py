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

from collections import deque

import numpy as np

from ib_interface.eventkit.ops.op import Op
from ib_interface.eventkit.util import NO_VALUE


class Array(Op):
    __slots__ = ("_count", "_q")

    def __init__(self, count, source=None):
        Op.__init__(self, source)
        self._count = count
        self._q = deque()

    def on_source(self, *args):
        self._q.append(args[0] if len(args) == 1 else args if args else NO_VALUE)
        if self._count and len(self._q) > self._count:
            self._q.popleft()
        self.emit(np.asarray(self._q))

    def min(self) -> "ArrayMin":  # type: ignore
        """
        Minimum value.
        """
        return ArrayMin(self)

    def max(self) -> "ArrayMax":  # type: ignore
        """
        Maximum value.
        """
        return ArrayMax(self)

    def sum(self) -> "ArraySum":  # type: ignore
        """
        Summation.
        """
        return ArraySum(self)

    def prod(self) -> "ArrayProd":
        """
        Product.
        """
        return ArrayProd(self)

    def mean(self) -> "ArrayMean":  # type: ignore
        """
        Mean value.
        """
        return ArrayMean(self)

    def std(self) -> "ArrayStd":  # type: ignore
        """
        Sample standard deviation.
        """
        return ArrayStd(self)

    def any(self) -> "ArrayAny":  # type: ignore
        """
        Test if any array value is true.
        """
        return ArrayAny(self)

    def all(self) -> "ArrayAll":  # type: ignore
        """
        Test if all array values are true.
        """
        return ArrayAll(self)


class ArrayMin(Op):
    __slots__ = ()

    def on_source(self, arg):
        self.emit(arg.min())


class ArrayMax(Op):
    __slots__ = ()

    def on_source(self, arg):
        self.emit(arg.max())


class ArraySum(Op):
    __slots__ = ()

    def on_source(self, arg):
        self.emit(arg.sum())


class ArrayProd(Op):
    __slots__ = ()

    def on_source(self, arg):
        self.emit(arg.prod())


class ArrayMean(Op):
    __slots__ = ()

    def on_source(self, arg):
        self.emit(arg.mean())


class ArrayStd(Op):
    __slots__ = ()

    def on_source(self, arg):
        self.emit(arg.std(ddof=1) if len(arg) > 1 else np.nan)


class ArrayAny(Op):
    __slots__ = ()

    def on_source(self, arg):
        self.emit(arg.any())


class ArrayAll(Op):
    __slots__ = ()

    def on_source(self, arg):
        self.emit(arg.all())
