# Implementation Report: Modernizing ib-interface with Protobuf

## 1. Introduction

### 1.1 Background

**ib-insync** (now `ib-interface`) was created as an improved alternative to the official Interactive Brokers TWS API. Its core value propositions include:

- **asyncio-native**: Non-blocking I/O with Python's native async/await
- **Reactive events**: EventKit-based streaming with RxPy-like operators
- **Higher-level abstractions**: Convenience methods like `qualifyContracts()`, `bracketOrder()`
- **Dataclass-based objects**: Immutable, type-hinted data structures
- **Automatic request throttling**: Built-in rate limiting
- **Simplified connection**: No need to wait for `nextValidId`

However, the repository has fallen into archive status and is now significantly behind the official API.

### 1.2 The Protobuf Imperative

Per Interactive Brokers' official documentation:

> Beginning with TWSAPI version 10.35.01, Interactive Brokers has begun to produce the TWS API using Google's Protocol Buffer. As a result, many new objects are produced using protocol buffer classes directly that developers will need to utilize and understand in order to produce effective code that can access all systems provided by the TWSAPI.

**Protobuf is not optional**—it is required for accessing new API features. This report outlines how to integrate Protobuf while preserving ib-interface's architectural advantages.

---

## 2. Current State Analysis

### 2.1 ib-interface Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  User Application                                           │
│  (async/await, Event subscriptions)                         │
├─────────────────────────────────────────────────────────────┤
│  IB (High-level facade)                                     │
│  - qualifyContracts(), placeOrder(), bracketOrder()         │
│  - Event streams: pendingTickersEvent, orderStatusEvent     │
├─────────────────────────────────────────────────────────────┤
│  Client (asyncio)         │  Wrapper (State management)     │
│  - connect()              │  - Callback implementations     │
│  - placeOrder()           │  - Internal state (tickers,     │
│  - reqMktData()           │    orders, positions)           │
├─────────────────────────────────────────────────────────────┤
│  Decoder (Message parsing)                                  │
│  - handlers = {1: priceSizeTick, 2: tickSize, ...}          │
│  - Legacy string protocol only                              │
├─────────────────────────────────────────────────────────────┤
│  Connection (asyncio Protocol)                              │
│  - Non-blocking socket I/O                                  │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Current Limitations

| Component | Current State | Gap |
|-----------|--------------|-----|
| `client.py` | `MaxClientVersion = 178` | Should be 222+ |
| `decoder.py` | Message IDs 1-107 | Missing 108+ and Protobuf |
| `order.py` | ~50 attributes | Missing 15+ attributes |
| `contract.py` | Basic ContractDetails | Missing fund fields, etc. |
| Protobuf | None | Required for new features |

### 2.3 Advantages to Preserve

1. **asyncio architecture**: The core differentiator from official API
2. **EventKit integration**: Reactive event streaming
3. **High-level IB facade**: Convenience methods
4. **Dataclass objects**: Type-safe, immutable data structures
5. **Automatic throttling**: Built-in rate limiting
6. **Simplified connection**: Blocking connect with auto-readiness

---

## 3. Implementation Strategy

### 3.1 Design Principles

1. **Protobuf as first-class citizen**: Native integration, not bolted-on
2. **Preserve asyncio**: All Protobuf operations must be async-compatible
3. **Maintain event streaming**: Protobuf messages feed into EventKit
4. **Keep dataclass interface**: Convert Protobuf objects to dataclasses at boundaries
5. **Backwards compatibility**: Legacy string protocol support for older TWS versions

### 3.2 Architecture Evolution

```
┌─────────────────────────────────────────────────────────────┐
│  User Application                                           │
│  (async/await, Event subscriptions) - UNCHANGED             │
├─────────────────────────────────────────────────────────────┤
│  IB (High-level facade) - ENHANCED                          │
│  + getConfig(), updateConfig()                              │
│  + New order attributes, fund data                          │
├─────────────────────────────────────────────────────────────┤
│  Client (asyncio)         │  Wrapper (State management)     │
│  + Protobuf send methods  │  + Protobuf callbacks           │
│  + reqConfig()            │  + configResponse()             │
│  + Version 222 support    │  + Enhanced state               │
├───────────────────────────┴─────────────────────────────────┤
│  Decoder (Dual-protocol)                     ┌──────────────┤
│  - interpret() detects protocol              │ ProtobufCodec│
│  - Legacy handlers (IDs 1-107)               │ - Encode     │
│  - Protobuf handlers (ID 0 + type)           │ - Decode     │
│  - Object conversion layer                   │ - Convert    │
├─────────────────────────────────────────────┬┴──────────────┤
│  Connection (asyncio Protocol)              │ Protobuf      │
│  - UNCHANGED                                │ Messages      │
│                                             │ (204 types)   │
└─────────────────────────────────────────────┴───────────────┘
```

---

## 4. Implementation Details

### 4.1 Phase 1: Protobuf Foundation

#### 4.1.1 Add Dependencies

```toml
# pyproject.toml
[project]
dependencies = [
    "matplotlib>=3.10.8",
    "numpy>=2.4.2",
    "pandas>=3.0.1",
    "protobuf>=5.29.0",  # ADD: Required for TWS API 10.35+
]
```

#### 4.1.2 Create Protobuf Module Structure

```
src/ib_interface/
├── api/
│   ├── client.py
│   ├── decoder.py
│   ├── wrapper.py
│   └── ...
├── protobuf/                    # NEW: Protobuf support
│   ├── __init__.py
│   ├── codec.py                 # Encode/decode utilities
│   ├── converter.py             # Protobuf ↔ dataclass conversion
│   └── messages/                # Generated protobuf files
│       ├── __init__.py
│       ├── ConfigRequest_pb2.py
│       ├── Order_pb2.py
│       └── ... (200+ files)
└── ...
```

#### 4.1.3 Implement Protobuf Codec

```python
# src/ib_interface/protobuf/codec.py
"""
Protobuf encoding/decoding utilities for TWS API.

This module provides the core infrastructure for Protocol Buffer
communication while preserving ib-interface's asyncio architecture.
"""

import struct
from typing import TypeVar, Type
from google.protobuf.message import Message

T = TypeVar('T', bound=Message)

# Protobuf message ID used by TWS API
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
        
        Args:
            msg: The protobuf message to encode
            msg_type_id: The TWS message type identifier
            
        Returns:
            Framed bytes ready for transmission
        """
        payload = msg.SerializeToString()
        # Frame: [length:4][msgId:1][typeId:2][payload:n]
        header = struct.pack('>IBH', len(payload) + 3, PROTOBUF_MSG_ID, msg_type_id)
        return header + payload
    
    @staticmethod
    def decode(data: bytes, msg_class: Type[T]) -> T:
        """
        Decode a Protobuf message received from TWS.
        
        Args:
            data: Raw protobuf bytes (after framing removed)
            msg_class: The protobuf message class to decode into
            
        Returns:
            Decoded protobuf message instance
        """
        msg = msg_class()
        msg.ParseFromString(data)
        return msg
    
    @staticmethod
    def is_protobuf_message(fields: list) -> bool:
        """
        Detect if incoming fields represent a Protobuf message.
        
        The TWS API uses message ID 0 to indicate protobuf format.
        """
        return len(fields) > 0 and fields[0] == '0'
```

#### 4.1.4 Implement Object Converter

```python
# src/ib_interface/protobuf/converter.py
"""
Convert between Protobuf messages and ib-interface dataclasses.

This module is the bridge that allows ib-interface to maintain its
dataclass-based API while internally using Protobuf for communication.
"""

from dataclasses import fields as dataclass_fields
from typing import TypeVar, Type, Any
from decimal import Decimal

from ib_interface.api.contract import Contract, ContractDetails
from ib_interface.api.order import Order, OrderState
from ib_interface.api.objects import BarData, Execution

# Protobuf imports (generated files)
from ib_interface.protobuf.messages.Order_pb2 import Order as OrderProto
from ib_interface.protobuf.messages.Contract_pb2 import Contract as ContractProto
from ib_interface.protobuf.messages.OrderStatus_pb2 import OrderStatus as OrderStatusProto

T = TypeVar('T')


class ProtobufConverter:
    """
    Bidirectional converter between Protobuf messages and dataclasses.
    
    Design Philosophy:
    - Protobuf is used for wire protocol only
    - All internal state uses ib-interface dataclasses
    - User-facing API never exposes Protobuf types
    """
    
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
        if proto.HasField('slOrderType'):
            order.slOrderType = proto.slOrderType
        if proto.HasField('ptOrderId'):
            order.ptOrderId = proto.ptOrderId
        if proto.HasField('ptOrderType'):
            order.ptOrderType = proto.ptOrderType
        
        return order
    
    @staticmethod
    def order_to_proto(order: Order) -> OrderProto:
        """Convert ib-interface Order dataclass to Protobuf Order."""
        proto = OrderProto()
        
        # Use reflection to map dataclass fields to proto fields
        for field in dataclass_fields(order):
            value = getattr(order, field.name)
            if value is not None and hasattr(proto, field.name):
                if isinstance(value, Decimal):
                    setattr(proto, field.name, float(value))
                else:
                    setattr(proto, field.name, value)
        
        return proto
    
    @staticmethod
    def contract_from_proto(proto: ContractProto) -> Contract:
        """Convert Protobuf Contract to ib-interface Contract dataclass."""
        contract = Contract()
        
        contract.conId = proto.conId if proto.HasField('conId') else 0
        contract.symbol = proto.symbol if proto.HasField('symbol') else ""
        contract.secType = proto.secType if proto.HasField('secType') else ""
        contract.lastTradeDateOrContractMonth = proto.lastTradeDateOrContractMonth if proto.HasField('lastTradeDateOrContractMonth') else ""
        contract.strike = proto.strike if proto.HasField('strike') else 0.0
        contract.right = proto.right if proto.HasField('right') else ""
        contract.multiplier = proto.multiplier if proto.HasField('multiplier') else ""
        contract.exchange = proto.exchange if proto.HasField('exchange') else ""
        contract.currency = proto.currency if proto.HasField('currency') else ""
        contract.localSymbol = proto.localSymbol if proto.HasField('localSymbol') else ""
        contract.primaryExchange = proto.primaryExchange if proto.HasField('primaryExchange') else ""
        contract.tradingClass = proto.tradingClass if proto.HasField('tradingClass') else ""
        contract.includeExpired = proto.includeExpired if proto.HasField('includeExpired') else False
        contract.secIdType = proto.secIdType if proto.HasField('secIdType') else ""
        contract.secId = proto.secId if proto.HasField('secId') else ""
        contract.description = proto.description if proto.HasField('description') else ""
        contract.issuerId = proto.issuerId if proto.HasField('issuerId') else ""
        
        return contract
    
    @staticmethod
    def bar_data_from_proto(proto) -> BarData:
        """Convert Protobuf historical bar to ib-interface BarData."""
        return BarData(
            date=proto.time if proto.HasField('time') else "",
            open=proto.open if proto.HasField('open') else 0.0,
            high=proto.high if proto.HasField('high') else 0.0,
            low=proto.low if proto.HasField('low') else 0.0,
            close=proto.close if proto.HasField('close') else 0.0,
            volume=Decimal(str(proto.volume)) if proto.HasField('volume') else Decimal(0),
            barCount=proto.barCount if proto.HasField('barCount') else 0,
            average=proto.wap if proto.HasField('wap') else 0.0,
        )
```

### 4.2 Phase 2: Dual-Protocol Decoder

#### 4.2.1 Update Decoder for Protobuf Support

```python
# src/ib_interface/api/decoder.py (modifications)
"""
Dual-protocol decoder supporting both legacy string and Protobuf formats.

The decoder automatically detects the message format and routes to
the appropriate handler while maintaining the same wrapper interface.
"""

import logging
from typing import Any, Callable, Dict

from ib_interface.protobuf.codec import ProtobufCodec, PROTOBUF_MSG_ID
from ib_interface.protobuf.converter import ProtobufConverter

# Protobuf message imports
from ib_interface.protobuf.messages.OrderStatus_pb2 import OrderStatus as OrderStatusProto
from ib_interface.protobuf.messages.OpenOrder_pb2 import OpenOrder as OpenOrderProto
from ib_interface.protobuf.messages.TickPrice_pb2 import TickPrice as TickPriceProto
from ib_interface.protobuf.messages.ConfigResponse_pb2 import ConfigResponse as ConfigResponseProto
# ... additional imports


class Decoder:
    """
    Decode IB messages and invoke corresponding wrapper methods.
    
    Supports dual-protocol operation:
    - Legacy string protocol (message IDs 1-107)
    - Protobuf protocol (message ID 0 + type identifier)
    """

    # Protobuf message type IDs (from official API)
    PROTO_ORDER_STATUS = 1
    PROTO_OPEN_ORDER = 2
    PROTO_TICK_PRICE = 10
    PROTO_CONFIG_RESPONSE = 100
    # ... additional type IDs

    def __init__(self, wrapper, serverVersion: int):
        self.wrapper = wrapper
        self.serverVersion = serverVersion
        self.logger = logging.getLogger("ib_interface.Decoder")
        self.converter = ProtobufConverter()
        
        # Legacy string protocol handlers (existing)
        self.handlers: Dict[int, Callable] = {
            1: self.priceSizeTick,
            2: self.wrap("tickSize", [int, int, float]),
            3: self.wrap("orderStatus", [int, str, float, float, float, int, int, float, int, str, float], skip=1),
            # ... existing handlers 4-107
        }
        
        # Protobuf message handlers (NEW)
        self.proto_handlers: Dict[int, Callable] = {
            self.PROTO_ORDER_STATUS: self._handle_order_status_proto,
            self.PROTO_OPEN_ORDER: self._handle_open_order_proto,
            self.PROTO_TICK_PRICE: self._handle_tick_price_proto,
            self.PROTO_CONFIG_RESPONSE: self._handle_config_response_proto,
            # ... additional protobuf handlers
        }

    def interpret(self, fields):
        """
        Decode fields and invoke corresponding wrapper method.
        
        Automatically detects protocol type and routes appropriately.
        """
        try:
            msgId = int(fields[0])
            
            if msgId == PROTOBUF_MSG_ID:
                # Protobuf message - extract type and decode
                self._interpret_protobuf(fields)
            else:
                # Legacy string protocol
                handler = self.handlers.get(msgId)
                if handler:
                    handler(fields)
                else:
                    self.logger.warning(f"Unknown message ID: {msgId}")
                    
        except Exception:
            self.logger.exception(f"Error handling fields: {fields}")

    def _interpret_protobuf(self, fields):
        """
        Handle Protobuf-encoded messages.
        
        Fields format: ['0', proto_type_id, proto_bytes...]
        """
        try:
            proto_type_id = int(fields[1])
            proto_data = fields[2] if len(fields) > 2 else b''
            
            handler = self.proto_handlers.get(proto_type_id)
            if handler:
                handler(proto_data)
            else:
                self.logger.warning(f"Unknown protobuf type: {proto_type_id}")
                
        except Exception:
            self.logger.exception(f"Error handling protobuf message")

    # Protobuf message handlers
    
    def _handle_order_status_proto(self, data: bytes):
        """Handle Protobuf OrderStatus message."""
        proto = ProtobufCodec.decode(data, OrderStatusProto)
        
        # Convert and invoke wrapper (same interface as legacy)
        self.wrapper.orderStatus(
            orderId=proto.orderId,
            status=proto.status,
            filled=float(proto.filled),
            remaining=float(proto.remaining),
            avgFillPrice=proto.avgFillPrice,
            permId=proto.permId,
            parentId=proto.parentId,
            lastFillPrice=proto.lastFillPrice,
            clientId=proto.clientId,
            whyHeld=proto.whyHeld,
            mktCapPrice=proto.mktCapPrice,
        )
    
    def _handle_open_order_proto(self, data: bytes):
        """Handle Protobuf OpenOrder message."""
        proto = ProtobufCodec.decode(data, OpenOrderProto)
        
        # Convert protobuf to dataclasses
        contract = self.converter.contract_from_proto(proto.contract)
        order = self.converter.order_from_proto(proto.order)
        order_state = OrderState()  # Convert from proto.orderState
        
        # Invoke wrapper with converted objects
        self.wrapper.openOrder(proto.orderId, contract, order, order_state)
    
    def _handle_tick_price_proto(self, data: bytes):
        """Handle Protobuf TickPrice message."""
        proto = ProtobufCodec.decode(data, TickPriceProto)
        
        # Invoke wrapper (same interface)
        self.wrapper.priceSizeTick(
            proto.reqId,
            proto.tickType,
            proto.price,
            proto.size if proto.HasField('size') else 0,
        )
    
    def _handle_config_response_proto(self, data: bytes):
        """Handle Protobuf ConfigResponse message (NEW feature)."""
        proto = ProtobufCodec.decode(data, ConfigResponseProto)
        
        # NEW wrapper method for configuration
        if hasattr(self.wrapper, 'configResponse'):
            self.wrapper.configResponse(proto.reqId, proto)
```

### 4.3 Phase 3: Client Updates

#### 4.3.1 Update Version Constants

```python
# src/ib_interface/api/client.py (modifications)

class Client:
    """
    Asyncio-based client for TWS API communication.
    
    Now supports both legacy string protocol and Protobuf (v10.35+).
    """
    
    # Updated for TWS API 10.44+ (current latest)
    MinClientVersion = 100
    MaxClientVersion = 222  # Was 178
    
    # Protobuf support threshold
    MIN_PROTOBUF_VERSION = 201  # Server version that introduced protobuf
```

#### 4.3.2 Add Protobuf Send Methods

```python
# src/ib_interface/api/client.py (additions)

from ib_interface.protobuf.codec import ProtobufCodec
from ib_interface.protobuf.converter import ProtobufConverter
from ib_interface.protobuf.messages.PlaceOrderRequest_pb2 import PlaceOrderRequest
from ib_interface.protobuf.messages.ConfigRequest_pb2 import ConfigRequest
from ib_interface.protobuf.messages.UpdateConfigRequest_pb2 import UpdateConfigRequest


class Client:
    # ... existing code ...
    
    def _supports_protobuf(self) -> bool:
        """Check if connected server supports Protobuf protocol."""
        return self._serverVersion >= self.MIN_PROTOBUF_VERSION
    
    async def _send_protobuf(self, msg, msg_type_id: int):
        """
        Send a Protobuf message to TWS.
        
        Preserves asyncio compatibility with non-blocking send.
        """
        data = ProtobufCodec.encode(msg, msg_type_id)
        await self.conn.sendAsync(data)
    
    # Configuration API (NEW - requires Protobuf)
    
    def reqConfig(self, reqId: int = None):
        """
        Request current TWS/Gateway API configuration.
        
        This is a Protobuf-only feature (TWS API 10.35+).
        
        Args:
            reqId: Request identifier (auto-generated if not provided)
        """
        if not self._supports_protobuf():
            raise RuntimeError("reqConfig requires TWS API 10.35+ with Protobuf support")
        
        if reqId is None:
            reqId = self.getReqId()
        
        msg = ConfigRequest()
        msg.reqId = reqId
        
        run(self._send_protobuf(msg, MSG_TYPE_CONFIG_REQUEST))
        return reqId
    
    def updateConfig(self, reqId: int, **settings):
        """
        Update TWS/Gateway API configuration.
        
        This is a Protobuf-only feature (TWS API 10.35+).
        
        Args:
            reqId: Request identifier
            **settings: Configuration settings to update
        """
        if not self._supports_protobuf():
            raise RuntimeError("updateConfig requires TWS API 10.35+ with Protobuf support")
        
        msg = UpdateConfigRequest()
        msg.reqId = reqId
        
        # Apply settings to protobuf message
        for key, value in settings.items():
            if hasattr(msg, key):
                setattr(msg, key, value)
        
        run(self._send_protobuf(msg, MSG_TYPE_UPDATE_CONFIG_REQUEST))
    
    # Enhanced placeOrder with new attributes
    
    def placeOrder(self, orderId: int, contract: Contract, order: Order):
        """
        Place an order with full attribute support.
        
        Uses Protobuf for servers v201+ when advantageous.
        """
        if self._supports_protobuf() and self._should_use_protobuf_order(order):
            self._placeOrderProtobuf(orderId, contract, order)
        else:
            self._placeOrderLegacy(orderId, contract, order)
    
    def _should_use_protobuf_order(self, order: Order) -> bool:
        """Determine if order benefits from Protobuf encoding."""
        # Use protobuf if order uses new attributes not in legacy protocol
        new_attrs = ['customerAccount', 'professionalCustomer', 'includeOvernight',
                     'slOrderId', 'ptOrderId', 'whatIfType']
        return any(getattr(order, attr, None) for attr in new_attrs)
    
    def _placeOrderProtobuf(self, orderId: int, contract: Contract, order: Order):
        """Place order using Protobuf protocol."""
        converter = ProtobufConverter()
        
        msg = PlaceOrderRequest()
        msg.orderId = orderId
        msg.contract.CopyFrom(converter.contract_to_proto(contract))
        msg.order.CopyFrom(converter.order_to_proto(order))
        
        run(self._send_protobuf(msg, MSG_TYPE_PLACE_ORDER))
    
    def _placeOrderLegacy(self, orderId: int, contract: Contract, order: Order):
        """Place order using legacy string protocol (existing implementation)."""
        # ... existing placeOrder implementation ...
        pass
```

### 4.4 Phase 4: Data Model Updates

#### 4.4.1 Update Order Dataclass

```python
# src/ib_interface/api/order.py (additions)

from dataclasses import dataclass, field
from decimal import Decimal
from typing import List, Optional

from ib_interface.api.util import UNSET_DOUBLE, UNSET_INTEGER


@dataclass
class Order:
    """
    Order specification with full TWS API 10.44+ attribute support.
    
    Preserves ib-interface's dataclass design while adding all
    attributes required for current TWS API compatibility.
    """
    
    # Existing core fields
    orderId: int = 0
    clientId: int = 0
    permId: int = 0
    action: str = ""
    totalQuantity: Decimal = Decimal(0)
    orderType: str = ""
    lmtPrice: float = UNSET_DOUBLE
    auxPrice: float = UNSET_DOUBLE
    tif: str = ""
    
    # ... existing fields ...
    
    # NEW: Regulatory / Compliance (v183+)
    customerAccount: str = ""
    professionalCustomer: bool = False
    bondAccruedInterest: str = ""
    
    # NEW: Overnight / Extended Hours (v189+)
    includeOvernight: bool = False
    
    # NEW: Manual Order Indicators (v198+)
    manualOrderIndicator: int = UNSET_INTEGER
    submitter: str = ""
    
    # NEW: Post-Only / Auction (v216+)
    postOnly: bool = False
    allowPreOpen: bool = False
    ignoreOpenAuction: bool = False
    deactivate: bool = False
    seekPriceImprovement: Optional[bool] = None
    
    # NEW: What-If Extensions (v195+)
    whatIfType: int = UNSET_INTEGER
    
    # NEW: Attached Orders (v218+)
    slOrderId: int = UNSET_INTEGER
    slOrderType: str = ""
    ptOrderId: int = UNSET_INTEGER
    ptOrderType: str = ""
```

#### 4.4.2 Update ContractDetails Dataclass

```python
# src/ib_interface/api/contract.py (additions)

from dataclasses import dataclass, field
from decimal import Decimal
from enum import Enum
from typing import List, Optional


class FundAssetType(Enum):
    """Fund asset type classification."""
    NONE = ("None", "None")
    OTHERS = ("000", "Others")
    MONEY_MARKET = ("001", "Money Market")
    FIXED_INCOME = ("002", "Fixed Income")
    MULTI_ASSET = ("003", "Multi-asset")
    EQUITY = ("004", "Equity")
    SECTOR = ("005", "Sector")
    GUARANTEED = ("006", "Guaranteed")
    ALTERNATIVE = ("007", "Alternative")


class FundDistributionPolicyIndicator(Enum):
    """Fund distribution policy classification."""
    NONE = ("None", "None")
    ACCUMULATION = ("N", "Accumulation Fund")
    INCOME = ("Y", "Income Fund")


@dataclass
class ContractDetails:
    """
    Detailed contract information with full TWS API 10.44+ support.
    
    Includes new fund data fields and ineligibility reasons.
    """
    
    # Existing fields
    contract: Contract = field(default_factory=Contract)
    marketName: str = ""
    minTick: float = 0.0
    orderTypes: str = ""
    validExchanges: str = ""
    priceMagnifier: int = 0
    underConId: int = 0
    longName: str = ""
    contractMonth: str = ""
    industry: str = ""
    category: str = ""
    subcategory: str = ""
    timeZoneId: str = ""
    tradingHours: str = ""
    liquidHours: str = ""
    evRule: str = ""
    evMultiplier: int = 0
    aggGroup: int = 0
    underSymbol: str = ""
    underSecType: str = ""
    marketRuleIds: str = ""
    realExpirationDate: str = ""
    lastTradeTime: str = ""
    stockType: str = ""
    
    # NEW: Size precision fields (v164+)
    minSize: Decimal = Decimal(0)
    sizeIncrement: Decimal = Decimal(0)
    suggestedSizeIncrement: Decimal = Decimal(0)
    minAlgoSize: Decimal = Decimal(0)
    lastPricePrecision: Decimal = Decimal(0)
    lastSizePrecision: Decimal = Decimal(0)
    
    # Bond fields (existing)
    cusip: str = ""
    ratings: str = ""
    descAppend: str = ""
    bondType: str = ""
    couponType: str = ""
    callable: bool = False
    putable: bool = False
    coupon: float = 0.0
    convertible: bool = False
    maturity: str = ""
    issueDate: str = ""
    nextOptionDate: str = ""
    nextOptionType: str = ""
    nextOptionPartial: bool = False
    notes: str = ""
    
    # NEW: Fund fields (v179+)
    fundName: str = ""
    fundFamily: str = ""
    fundType: str = ""
    fundFrontLoad: str = ""
    fundBackLoad: str = ""
    fundBackLoadTimeInterval: str = ""
    fundManagementFee: str = ""
    fundClosed: bool = False
    fundClosedForNewInvestors: bool = False
    fundClosedForNewMoney: bool = False
    fundNotifyAmount: str = ""
    fundMinimumInitialPurchase: str = ""
    fundSubsequentMinimumPurchase: str = ""
    fundBlueSkyStates: str = ""
    fundBlueSkyTerritories: str = ""
    fundDistributionPolicyIndicator: FundDistributionPolicyIndicator = FundDistributionPolicyIndicator.NONE
    fundAssetType: FundAssetType = FundAssetType.NONE
    
    # NEW: Ineligibility reasons (v186+)
    ineligibilityReasonList: List[str] = field(default_factory=list)
    
    # NEW: Event contracts (v179+)
    eventContract1: str = ""
    eventContractDescription1: str = ""
    eventContractDescription2: str = ""
```

### 4.5 Phase 5: Wrapper Updates

#### 4.5.1 Add Protobuf Callbacks

```python
# src/ib_interface/api/wrapper.py (additions)

from ib_interface.protobuf.messages.ConfigResponse_pb2 import ConfigResponse


class Wrapper:
    """
    Wrapper with Protobuf callback support.
    
    New callbacks are added for Protobuf-only features while
    maintaining the existing event-driven architecture.
    """
    
    # ... existing code ...
    
    # NEW: Configuration API callbacks
    
    def configResponse(self, reqId: int, config: ConfigResponse):
        """
        Callback for configuration response.
        
        This is a Protobuf-only feature (TWS API 10.35+).
        
        Args:
            reqId: The request identifier
            config: The ConfigResponse protobuf message
        """
        # Convert to dict for easier handling
        config_dict = {
            'api': {
                'readOnly': config.api.readOnly if config.HasField('api') else None,
                'masterApiEnabled': config.api.masterApiEnabled if config.HasField('api') else None,
            },
            'orders': {
                # ... extract order config
            },
            'lockAndExit': {
                # ... extract lock config  
            },
        }
        
        # Emit event for reactive subscribers
        self.configResponseEvent.emit(reqId, config_dict)
    
    def updateConfigResponse(self, reqId: int, success: bool, warnings: list):
        """
        Callback for configuration update response.
        
        Args:
            reqId: The request identifier
            success: Whether the update was successful
            warnings: List of warning messages
        """
        self.updateConfigResponseEvent.emit(reqId, success, warnings)
    
    # Updated error callback (v194+)
    
    def error(
        self,
        reqId: int,
        errorTime: int,  # NEW in v194
        errorCode: int,
        errorString: str,
        advancedOrderRejectJson: str = "",
    ):
        """
        Error callback with timestamp support (v194+).
        
        Args:
            reqId: The request identifier (-1 for connection errors)
            errorTime: Error timestamp in epoch seconds (NEW)
            errorCode: The error code
            errorString: The error message
            advancedOrderRejectJson: JSON with advanced rejection details
        """
        # ... existing error handling ...
        pass
```

### 4.6 Phase 6: High-Level IB Interface Updates

```python
# src/ib_interface/api/ib.py (additions)

class IB:
    """
    High-level interface with Protobuf-powered features.
    
    Maintains the familiar ib-interface API while leveraging
    Protobuf for new functionality.
    """
    
    # ... existing code ...
    
    # NEW: Configuration API (Protobuf-only)
    
    async def getConfigAsync(self) -> dict:
        """
        Get current TWS/Gateway API configuration.
        
        Returns:
            Dictionary containing API configuration settings.
            
        Raises:
            RuntimeError: If connected TWS doesn't support Protobuf.
            
        Example:
            config = await ib.getConfigAsync()
            print(config['api']['readOnly'])
        """
        reqId = self._client.reqConfig()
        
        # Wait for response using existing event pattern
        config = await self._wait_for_event(
            self._wrapper.configResponseEvent,
            lambda r, c: r == reqId,
            timeout=10,
        )
        return config
    
    def getConfig(self) -> dict:
        """Blocking version of getConfigAsync."""
        return run(self.getConfigAsync())
    
    async def updateConfigAsync(self, **settings) -> bool:
        """
        Update TWS/Gateway API configuration.
        
        Args:
            **settings: Configuration settings to update.
            
        Returns:
            True if update was successful.
            
        Example:
            success = await ib.updateConfigAsync(
                readOnly=False,
                masterApiEnabled=True,
            )
        """
        reqId = self._client.getReqId()
        self._client.updateConfig(reqId, **settings)
        
        success, warnings = await self._wait_for_event(
            self._wrapper.updateConfigResponseEvent,
            lambda r, s, w: r == reqId,
            timeout=10,
        )
        
        if warnings:
            self._logger.warning(f"Config update warnings: {warnings}")
        
        return success
    
    def updateConfig(self, **settings) -> bool:
        """Blocking version of updateConfigAsync."""
        return run(self.updateConfigAsync(**settings))
```

---

## 5. Testing Strategy

### 5.1 Unit Tests

```python
# tests/test_protobuf.py

import pytest
from ib_interface.protobuf.codec import ProtobufCodec
from ib_interface.protobuf.converter import ProtobufConverter
from ib_interface.api.order import Order
from ib_interface.protobuf.messages.Order_pb2 import Order as OrderProto


class TestProtobufCodec:
    """Test Protobuf encoding/decoding."""
    
    def test_encode_decode_roundtrip(self):
        """Verify encode/decode preserves data."""
        proto = OrderProto()
        proto.orderId = 123
        proto.action = "BUY"
        proto.totalQuantity = 100.0
        
        encoded = ProtobufCodec.encode(proto, msg_type_id=1)
        decoded = ProtobufCodec.decode(encoded[7:], OrderProto)  # Skip header
        
        assert decoded.orderId == 123
        assert decoded.action == "BUY"
        assert decoded.totalQuantity == 100.0
    
    def test_is_protobuf_message(self):
        """Verify protobuf message detection."""
        assert ProtobufCodec.is_protobuf_message(['0', '1', b'...'])
        assert not ProtobufCodec.is_protobuf_message(['3', '123', 'BUY'])


class TestProtobufConverter:
    """Test Protobuf to dataclass conversion."""
    
    def test_order_conversion_roundtrip(self):
        """Verify order conversion preserves data."""
        order = Order()
        order.orderId = 456
        order.action = "SELL"
        order.totalQuantity = Decimal("50.5")
        order.customerAccount = "DU12345"
        order.includeOvernight = True
        
        converter = ProtobufConverter()
        proto = converter.order_to_proto(order)
        restored = converter.order_from_proto(proto)
        
        assert restored.orderId == order.orderId
        assert restored.action == order.action
        assert restored.customerAccount == order.customerAccount
        assert restored.includeOvernight == order.includeOvernight
    
    def test_new_attributes_preserved(self):
        """Verify new v218+ attributes are preserved."""
        order = Order()
        order.slOrderId = 100
        order.slOrderType = "STP"
        order.ptOrderId = 101
        order.ptOrderType = "LMT"
        
        converter = ProtobufConverter()
        proto = converter.order_to_proto(order)
        restored = converter.order_from_proto(proto)
        
        assert restored.slOrderId == 100
        assert restored.slOrderType == "STP"
        assert restored.ptOrderId == 101
        assert restored.ptOrderType == "LMT"
```

### 5.2 Integration Tests

```python
# tests/test_integration.py

import pytest
from ib_interface import IB


@pytest.mark.integration
@pytest.mark.asyncio
async def test_config_api():
    """Test configuration API with paper trading."""
    ib = IB()
    await ib.connectAsync('127.0.0.1', 7497, clientId=99)
    
    try:
        # Get config
        config = await ib.getConfigAsync()
        assert 'api' in config
        
        # Update config (if not read-only)
        if not config['api'].get('readOnly'):
            success = await ib.updateConfigAsync(
                masterApiEnabled=True
            )
            assert success
    finally:
        ib.disconnect()


@pytest.mark.integration  
@pytest.mark.asyncio
async def test_order_with_new_attributes():
    """Test order placement with v218+ attributes."""
    ib = IB()
    await ib.connectAsync('127.0.0.1', 7497, clientId=99)
    
    try:
        contract = Stock('AAPL', 'SMART', 'USD')
        await ib.qualifyContractsAsync(contract)
        
        order = LimitOrder('BUY', 1, 150.00)
        order.includeOvernight = True
        order.customerAccount = "test"
        
        # What-if to verify attribute transmission
        preview = await ib.whatIfOrderAsync(contract, order)
        assert preview is not None
    finally:
        ib.disconnect()
```

---

## 6. Migration Guide

### 6.1 For Existing Users

```python
# Before (ib-interface 0.1.x)
from ib_interface import IB, Stock, LimitOrder

ib = IB()
ib.connect('127.0.0.1', 7497, clientId=1)

contract = Stock('AAPL', 'SMART', 'USD')
order = LimitOrder('BUY', 100, 150.00)
trade = ib.placeOrder(contract, order)

# After (ib-interface 0.2.x) - Same API, more features
from ib_interface import IB, Stock, LimitOrder

ib = IB()
ib.connect('127.0.0.1', 7497, clientId=1)

contract = Stock('AAPL', 'SMART', 'USD')
order = LimitOrder('BUY', 100, 150.00)

# NEW: Use new order attributes
order.includeOvernight = True
order.customerAccount = "MyAccount"

trade = ib.placeOrder(contract, order)

# NEW: Configuration API
config = ib.getConfig()
print(f"Read-only mode: {config['api']['readOnly']}")
```

### 6.2 Breaking Changes

| Change | Migration |
|--------|-----------|
| `pyproject.toml` adds `protobuf` dependency | Run `pip install -e .` or `uv sync` |
| `error()` callback has new `errorTime` parameter | Update wrapper overrides if any |
| Some internal imports changed | Only affects custom subclasses |

---

## 7. Project Structure After Implementation

```
src/ib_interface/
├── __init__.py                 # Public API exports
├── api/
│   ├── __init__.py
│   ├── client.py              # MODIFIED: v222, protobuf send
│   ├── connection.py          # UNCHANGED
│   ├── contract.py            # MODIFIED: new attributes
│   ├── decoder.py             # MODIFIED: dual-protocol
│   ├── flexreport.py          # UNCHANGED
│   ├── ib.py                  # MODIFIED: config API
│   ├── ibcontroller.py        # UNCHANGED
│   ├── objects.py             # MODIFIED: new fields
│   ├── order.py               # MODIFIED: new attributes
│   ├── ticker.py              # UNCHANGED
│   ├── util.py                # MINOR UPDATES
│   └── wrapper.py             # MODIFIED: new callbacks
├── eventkit/                   # UNCHANGED (preserved advantage)
│   ├── __init__.py
│   ├── event.py
│   └── ops/
├── nest_asyncio/              # UNCHANGED (preserved advantage)
│   └── ...
└── protobuf/                  # NEW MODULE
    ├── __init__.py
    ├── codec.py               # Encode/decode utilities
    ├── converter.py           # Proto ↔ dataclass conversion
    └── messages/              # 204 generated protobuf files
        ├── __init__.py
        ├── ConfigRequest_pb2.py
        ├── ConfigResponse_pb2.py
        ├── Order_pb2.py
        ├── Contract_pb2.py
        └── ... (200+ files)
```

---

## 8. Summary

### 8.1 Preserved Advantages

| Advantage | Status | Notes |
|-----------|--------|-------|
| asyncio architecture | ✅ PRESERVED | Core design unchanged |
| EventKit reactive events | ✅ PRESERVED | New events added |
| High-level IB facade | ✅ ENHANCED | Config API added |
| Dataclass objects | ✅ PRESERVED | Protobuf converted at boundary |
| Automatic throttling | ✅ PRESERVED | Unchanged |
| Simplified connection | ✅ PRESERVED | Unchanged |

### 8.2 New Capabilities

| Capability | Implementation |
|------------|----------------|
| Protobuf protocol | Native integration via codec/converter |
| Configuration API | `getConfig()`, `updateConfig()` |
| Server v222 support | Full attribute support |
| New order attributes | 15+ new fields |
| New contract attributes | 25+ new fields |
| Fund data | Complete fund detail support |

### 8.3 Implementation Timeline

| Phase | Duration | Deliverables |
|-------|----------|--------------|
| Phase 1: Protobuf Foundation | 1-2 weeks | codec.py, converter.py, messages/ |
| Phase 2: Dual-Protocol Decoder | 1 week | Updated decoder.py |
| Phase 3: Client Updates | 1 week | v222 support, config API |
| Phase 4: Data Models | 1 week | Updated order.py, contract.py |
| Phase 5: Wrapper Updates | 3 days | New callbacks |
| Phase 6: IB Interface | 3 days | High-level config methods |
| Testing & Documentation | 1 week | Tests, migration guide |

**Total: 6-8 weeks**

---

## 9. Conclusion

This implementation plan provides a path to modernize ib-interface with full Protobuf support while preserving all the architectural advantages that made ib-insync popular:

1. **Protobuf is integrated as a first-class citizen**, not bolted on
2. **The asyncio architecture is preserved** - this remains the core differentiator
3. **EventKit reactive streaming is maintained** - Protobuf messages feed into the same event system
4. **The dataclass API is unchanged** - users never interact with Protobuf directly
5. **Backwards compatibility is maintained** - legacy TWS versions still work

The result is a library that combines the best of both worlds: the modern Protobuf protocol and new features from the official API, with the developer-friendly asyncio/reactive architecture that made ib-insync the preferred choice for many Python traders.
