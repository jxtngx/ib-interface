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
Protobuf encoding/decoding utilities for TWS API.

This module provides the core infrastructure for Protocol Buffer
communication while preserving ib-interface's asyncio architecture.
"""

import struct

from google.protobuf.message import Message

PROTOBUF_MSG_ID = 0


class ProtobufCodec:
    """
    Encode and decode Protobuf messages for TWS API communication.

    The TWS API uses a specific framing format:
    - 4-byte length prefix (big-endian)
    - Message ID (0 for protobuf)
    - Message type identifier
    - Serialized protobuf bytes
    """

    @staticmethod
    def encode(msg: Message, msg_type_id: int) -> bytes:
        """
        Encode a Protobuf message for transmission to TWS.

        Frame format: [length:4][msgId:1][typeId:2][payload:n]

        Args:
            msg: The protobuf message to encode.
            msg_type_id: The TWS message type identifier.

        Returns:
            Bytes ready for socket transmission.
        """
        payload = msg.SerializeToString()
        header = struct.pack(">IBH", len(payload) + 3, PROTOBUF_MSG_ID, msg_type_id)
        return header + payload
