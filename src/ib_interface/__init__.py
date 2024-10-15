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

"""Python sync/async framework for Interactive Brokers API"""

import dataclasses
import sys

import ib_interface.eventkit as eventkit  # noqa: F401
import ib_interface.nest_asyncio as nest_asyncio  # noqa: F401
from ib_interface.api import util
from ib_interface.api.client import Client
from ib_interface.api.contract import (
    Bag,
    Bond,
    CFD,
    ComboLeg,
    Commodity,
    ContFuture,
    Contract,
    ContractDescription,
    ContractDetails,
    Crypto,
    DeltaNeutralContract,
    Forex,
    Future,
    FuturesOption,
    Index,
    MutualFund,
    Option,
    ScanData,
    Stock,
    TagValue,
    Warrant,
)
from ib_interface.api.flexreport import FlexError, FlexReport
from ib_interface.api.ib import IB
from ib_interface.api.ibcontroller import IBC, Watchdog
from ib_interface.api.objects import (
    AccountValue,
    BarData,
    BarDataList,
    CommissionReport,
    ConnectionStats,
    DepthMktDataDescription,
    Dividends,
    DOMLevel,
    Execution,
    ExecutionFilter,
    FamilyCode,
    Fill,
    FundamentalRatios,
    HistogramData,
    HistoricalNews,
    HistoricalSchedule,
    HistoricalSession,
    HistoricalTick,
    HistoricalTickBidAsk,
    HistoricalTickLast,
    MktDepthData,
    NewsArticle,
    NewsBulletin,
    NewsProvider,
    NewsTick,
    OptionChain,
    OptionComputation,
    PnL,
    PnLSingle,
    PortfolioItem,
    Position,
    PriceIncrement,
    RealTimeBar,
    RealTimeBarList,
    ScanDataList,
    ScannerSubscription,
    SmartComponent,
    SoftDollarTier,
    TickAttrib,
    TickAttribBidAsk,
    TickAttribLast,
    TickByTickAllLast,
    TickByTickBidAsk,
    TickByTickMidPoint,
    TickData,
    TradeLogEntry,
    WshEventData,
)
from ib_interface.api.order import (
    BracketOrder,
    ExecutionCondition,
    LimitOrder,
    MarginCondition,
    MarketOrder,
    Order,
    OrderComboLeg,
    OrderCondition,
    OrderState,
    OrderStatus,
    PercentChangeCondition,
    PriceCondition,
    StopLimitOrder,
    StopOrder,
    TimeCondition,
    Trade,
    VolumeCondition,
)
from ib_interface.api.ticker import Ticker
from ib_interface.api.version import __version__, __version_info__
from ib_interface.api.wrapper import RequestError, Wrapper
from ib_interface.eventkit import Event

__all__ = [
    "Event",
    "util",
    "Client",
    "Bag",
    "Bond",
    "CFD",
    "ComboLeg",
    "Commodity",
    "ContFuture",
    "Contract",
    "ContractDescription",
    "ContractDetails",
    "Crypto",
    "DeltaNeutralContract",
    "Forex",
    "Future",
    "FuturesOption",
    "Index",
    "MutualFund",
    "Option",
    "ScanData",
    "Stock",
    "TagValue",
    "Warrant",
    "FlexError",
    "FlexReport",
    "IB",
    "IBC",
    "Watchdog",
    "AccountValue",
    "BarData",
    "BarDataList",
    "CommissionReport",
    "ConnectionStats",
    "DOMLevel",
    "DepthMktDataDescription",
    "Dividends",
    "Execution",
    "ExecutionFilter",
    "FamilyCode",
    "Fill",
    "FundamentalRatios",
    "HistogramData",
    "HistoricalNews",
    "HistoricalTick",
    "HistoricalTickBidAsk",
    "HistoricalTickLast",
    "HistoricalSchedule",
    "HistoricalSession",
    "MktDepthData",
    "NewsArticle",
    "NewsBulletin",
    "NewsProvider",
    "NewsTick",
    "OptionChain",
    "OptionComputation",
    "PnL",
    "PnLSingle",
    "PortfolioItem",
    "Position",
    "PriceIncrement",
    "RealTimeBar",
    "RealTimeBarList",
    "ScanDataList",
    "ScannerSubscription",
    "SmartComponent",
    "SoftDollarTier",
    "TickAttrib",
    "TickAttribBidAsk",
    "TickAttribLast",
    "TickByTickAllLast",
    "WshEventData",
    "TickByTickBidAsk",
    "TickByTickMidPoint",
    "TickData",
    "TradeLogEntry",
    "BracketOrder",
    "ExecutionCondition",
    "LimitOrder",
    "MarginCondition",
    "MarketOrder",
    "Order",
    "OrderComboLeg",
    "OrderCondition",
    "OrderState",
    "OrderStatus",
    "PercentChangeCondition",
    "PriceCondition",
    "StopLimitOrder",
    "StopOrder",
    "TimeCondition",
    "Trade",
    "VolumeCondition",
    "Ticker",
    "__version__",
    "__version_info__",
    "RequestError",
    "Wrapper",
]


# compatibility with old Object
for obj in locals().copy().values():
    if dataclasses.is_dataclass(obj):
        obj.dict = util.dataclassAsDict
        obj.tuple = util.dataclassAsTuple
        obj.update = util.dataclassUpdate
        obj.nonDefaults = util.dataclassNonDefaults

del sys
del dataclasses
