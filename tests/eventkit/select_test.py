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

import unittest

from ib_interface.eventkit import Event

array = list(range(10))


class SelectTest(unittest.TestCase):
    def test_select(self):
        event = Event.sequence(array).filter(lambda x: x % 2)
        self.assertEqual(event.run(), [x for x in array if x % 2])

    def test_skip(self):
        event = Event.sequence(array).skip(5)
        self.assertEqual(event.run(), array[5:])

    def test_take(self):
        event = Event.sequence(array).take(5)
        self.assertEqual(event.run(), array[:5])

    def test_takewhile(self):
        event = Event.sequence(array).takewhile(lambda x: x < 5)
        self.assertEqual(event.run(), array[:5])

    def test_dropwhile(self):
        event = Event.sequence(array).dropwhile(lambda x: x < 5)
        self.assertEqual(event.run(), array[5:])

    def test_changes(self):
        array = [1, 1, 2, 1, 2, 2, 2, 3, 1, 4, 4]
        event = Event.sequence(array).changes()
        self.assertEqual(event.run(), [1, 2, 1, 2, 3, 1, 4])

    def test_unique(self):
        array = [1, 1, 2, 1, 2, 2, 2, 3, 1, 4, 4]
        event = Event.sequence(array).unique()
        self.assertEqual(event.run(), [1, 2, 3, 4])

    def test_last(self):
        event = Event.sequence(array).last()
        self.assertEqual(event.run(), [9])
