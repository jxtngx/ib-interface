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

"""Event-driven data pipelines."""

from ib_interface.eventkit.event import Event
from ib_interface.eventkit.ops.aggregate import (
    All,
    Any,
    Count,
    Deque,
    Ema,
    List,
    Max,
    Mean,
    Min,
    Pairwise,
    Product,
    Reduce,
    Sum,
)
from ib_interface.eventkit.ops.array import Array, ArrayAll, ArrayAny, ArrayMax, ArrayMean, ArrayMin, ArrayStd, ArraySum
from ib_interface.eventkit.ops.combine import AddableJoinOp, Chain, Concat, Fork, Merge, Switch, Zip, Ziplatest
from ib_interface.eventkit.ops.create import Aiterate, Marble, Range, Repeat, Sequence, Timer, Timerange, Wait
from ib_interface.eventkit.ops.misc import EndOnError, Errors
from ib_interface.eventkit.ops.op import Op
from ib_interface.eventkit.ops.select import Changes, DropWhile, Filter, Last, Skip, Take, TakeUntil, TakeWhile, Unique
from ib_interface.eventkit.ops.timing import Debounce, Delay, Sample, Throttle, Timeout
from ib_interface.eventkit.ops.transform import (
    Chainmap,
    Chunk,
    ChunkWith,
    Concatmap,
    Constant,
    Copy,
    Deepcopy,
    Emap,
    Enumerate,
    Iterate,
    Map,
    Mergemap,
    Pack,
    Partial,
    PartialRight,
    Pluck,
    Previous,
    Star,
    Switchmap,
    Timestamp,
)
