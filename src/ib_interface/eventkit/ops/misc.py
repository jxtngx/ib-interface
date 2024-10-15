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

from ib_interface.eventkit.event import Event
from ib_interface.eventkit.ops.op import Op


class Errors(Event):
    __slots__ = ("_source",)

    def __init__(self, source=None):
        Event.__init__(self)
        self._source = source
        if source is not None and source.done():
            self.set_done()
        else:
            source.error_event += self.emit


class EndOnError(Op):
    __slots__ = ()

    def __init__(self, source=None):
        Op.__init__(self, source)

    def on_source_error(self, error):
        self.disconnect_from(self._source)
        self.error_event.emit(error)
        self.set_done()
