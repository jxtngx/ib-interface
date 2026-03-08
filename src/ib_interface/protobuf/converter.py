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
Convert between Protobuf messages and ib-interface dataclasses.

This module is the bridge that allows ib-interface to maintain its
dataclass-based API while internally using Protobuf for communication.

Design Philosophy:
- Protobuf is used for wire protocol only
- All internal state uses ib-interface dataclasses
- User-facing API never exposes Protobuf types
"""

from decimal import Decimal

from ib_interface.api.contract import Contract
from ib_interface.api.order import Order
from ib_interface.api.objects import BarData

from ibapi.protobuf.Order_pb2 import Order as OrderProto
from ibapi.protobuf.Contract_pb2 import Contract as ContractProto
from ibapi.protobuf.HistoricalDataBar_pb2 import HistoricalDataBar as BarProto


class ProtobufConverter:
    """Bidirectional converter between Protobuf and dataclasses."""

    @staticmethod
    def order_from_proto(proto: OrderProto) -> Order:
        """Convert Protobuf Order to ib-interface Order dataclass."""
        order = Order()
        
        # Core fields
        order.orderId = proto.orderId if proto.HasField('orderId') else 0
        order.clientId = proto.clientId if proto.HasField('clientId') else 0
        order.permId = proto.permId if proto.HasField('permId') else 0
        order.action = proto.action if proto.HasField('action') else ""
        order.totalQuantity = Decimal(str(proto.totalQuantity)) if proto.HasField('totalQuantity') else Decimal(0)
        order.orderType = proto.orderType if proto.HasField('orderType') else ""
        order.lmtPrice = proto.lmtPrice if proto.HasField('lmtPrice') else 0.0
        order.auxPrice = proto.auxPrice if proto.HasField('auxPrice') else 0.0
        order.tif = proto.tif if proto.HasField('tif') else ""
        
        # Extended fields (v178+)
        if proto.HasField('customerAccount'):
            order.customerAccount = proto.customerAccount
        if proto.HasField('professionalCustomer'):
            order.professionalCustomer = proto.professionalCustomer
        if proto.HasField('includeOvernight'):
            order.includeOvernight = proto.includeOvernight
        
        # Attached orders (v218+)
        if proto.HasField('slOrderId'):
            order.slOrderId = proto.slOrderId
        if proto.HasField('ptOrderId'):
            order.ptOrderId = proto.ptOrderId
        
        return order

    @staticmethod
    def order_to_proto(order: Order) -> OrderProto:
        """Convert dataclass Order to Protobuf."""
        raise NotImplementedError("PROTO-008")

    @staticmethod
    def contract_from_proto(proto: ContractProto) -> Contract:
        """Convert Protobuf Contract to dataclass."""
        raise NotImplementedError("PROTO-009")

    @staticmethod
    def bar_data_from_proto(proto: BarProto) -> BarData:
        """Convert Protobuf bar to dataclass."""
        raise NotImplementedError("PROTO-010")
