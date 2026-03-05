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

"""
Protobuf support for TWS API communication.

This module provides Protocol Buffer encoding/decoding and conversion
utilities for the TWS API 10.35+ protobuf protocol.
"""

from ib_interface.protobuf.codec import PROTOBUF_MSG_ID, ProtobufCodec
from ib_interface.protobuf.converter import ProtobufConverter

__all__ = [
    "PROTOBUF_MSG_ID",
    "ProtobufCodec",
    "ProtobufConverter",
]
