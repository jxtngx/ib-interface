# Introduction

The goal of the IB Interface library is to make working with the
[Trader Workstation API](https://ibkrcampus.com/campus/ibkr-api-page/twsapi-doc/)
from Interactive Brokers as easy as possible.

The main features are:

* An easy to use linear style of programming;
* An `IB component` that automatically keeps in sync with the TWS or IB Gateway application;
* A fully asynchonous framework based on `asyncio` for advanced users;
* Interactive operation with live data in Jupyter notebooks.

Be sure to take a look at the [`notebooks`](notebooks/) and [`recipes`](docs/api/docs/recipes.rst).


# Installation

```bash
pip install ib-interface
```

Requirements:

* Python 3.9 or higher;
* A running TWS or IB Gateway application (version 1023 or higher).
  Make sure the [API port is enabled](https://ibkrcampus.com/campus/ibkr-api-page/twsapi-doc/#tws-config-api) and 'Download open orders on connection' is checked.

The ibapi package from IB is not needed.

# Example

This is a complete script to download historical data:

```python
from ib_insync import *

# util.startLoop()  # uncomment this line when in a notebook

ib = IB()
ib.connect("127.0.0.1", 7497, clientId=1)

contract = Forex("EURUSD")
bars = ib.reqHistoricalData(
    contract, endDateTime="", durationStr="30 D", barSizeSetting="1 hour", whatToShow="MIDPOINT", useRTH=True
)

# convert to pandas dataframe (pandas needs to be installed):
df = util.df(bars)
print(df)
```

Output
```
                  date      open      high       low     close  volume  \
0   2019-11-19 23:15:00  1.107875  1.108050  1.107725  1.107825      -1
1   2019-11-20 00:00:00  1.107825  1.107925  1.107675  1.107825      -1
2   2019-11-20 01:00:00  1.107825  1.107975  1.107675  1.107875      -1
3   2019-11-20 02:00:00  1.107875  1.107975  1.107025  1.107225      -1
4   2019-11-20 03:00:00  1.107225  1.107725  1.107025  1.107525      -1
..                  ...       ...       ...       ...       ...     ...
705 2020-01-02 14:00:00  1.119325  1.119675  1.119075  1.119225      -1
```
