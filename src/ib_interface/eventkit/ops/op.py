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

from typing import Union

from ib_interface.eventkit.event import Event


class Op(Event):
    """
    Base functionality for operators.

    The Observer pattern is implemented by the following three methods::

        on_source(self, *args)
        on_source_error(self, source, error)
        on_source_done(self, source)

    The default handlers will pass along source emits, errors and done events.
    This makes ``Op`` also suitable as an identity operator.
    """

    __slots__ = ()

    def __init__(self, source: Union[Event, None] = None):
        Event.__init__(self)
        if source is not None:
            self.set_source(source)

    on_source = Event.emit

    def on_source_error(self, source, error):
        if len(self.error_event):
            self.error_event.emit(source, error)
        else:
            Event.logger.exception(error)

    def on_source_done(self, _source):
        if self._source is not None:
            self._disconnect_from(self._source)
            self._source = None
        self.set_done()

    def set_source(self, source):
        source = Event.create(source)
        if self._source is None:
            self._source = source
            self._connect_from(source)
        else:
            self._source.set_source(source)

    def _connect_from(self, source: Event):
        if source.done():
            self.set_done()
        else:
            source.connect(self.on_source, self.on_source_error, self.on_source_done, keep_ref=True)

    def _disconnect_from(self, source: Event):
        source.disconnect(self.on_source, self.on_source_error, self.on_source_done)
