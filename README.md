<!-- # Copyright Justin R. Goheen.
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
# limitations under the License. -->

# IB Interface

An adaption and continuation of [ib-insync](https://github.com/erdewit/ib_insync) for the Interactive Brokers Python TWS API.

The main features are:

* An easy to use linear style of programming
* An `IB component` that automatically keeps in sync with the TWS or IB Gateway application
* A fully asynchonous framework based on `asyncio`
* Interactive operation with live data in Jupyter notebooks

> [!IMPORTANT]
> this project is not affiliated with Interactive Brokers

> [!IMPORTANT]
> The ibapi package from IB is not needed

> [!NOTE]
> ib-insync has been archived

## Installation

```bash
pip install ib-interface
```

## Usage

The goal is for `ib-insync` users to be able to simply refactor their imports as:

```diff
- import ib_insync as ibi
+ import ib_interface as ibi
```

```diff
- from ib_insync import *
+ from ib_interface import *
```

```diff
- from ib_insync.{some module} import {some submodule or class or function}
+ from ib_interface.{some module} import {some submodule or class or function}
```

## Example

> [!IMPORTANT]
> a running TWS or Gateway instance is needed to connect to the API

> [!IMPORTANT]
> Make sure the [API port is enabled](https://ibkrcampus.com/campus/ibkr-api-page/twsapi-doc/#tws-config-api) and 'Download open orders on connection' is checked.

This is a complete script to download historical data:

```python
from ib_interface import *

# util.startLoop()  # uncomment this line when in a notebook

ib = IB()
ib.connect("127.0.0.1", 7497, clientId=1)

contract = Forex("EURUSD")
bars = ib.reqHistoricalData(
    contract,
    endDateTime="",
    durationStr="30 D",
    barSizeSetting="1 hour",
    whatToShow="MIDPOINT",
    useRTH=True,
)

# convert to pandas dataframe (pandas needs to be installed):
df = util.df(bars)
print(df)
```

Output
```
                  date      open      high       low     close  volume
0   2019-11-19 23:15:00  1.107875  1.108050  1.107725  1.107825      -1
1   2019-11-20 00:00:00  1.107825  1.107925  1.107675  1.107825      -1
2   2019-11-20 01:00:00  1.107825  1.107975  1.107675  1.107875      -1
3   2019-11-20 02:00:00  1.107875  1.107975  1.107025  1.107225      -1
4   2019-11-20 03:00:00  1.107225  1.107725  1.107025  1.107525      -1
..                  ...       ...       ...       ...       ...     ...
705 2020-01-02 14:00:00  1.119325  1.119675  1.119075  1.119225      -1
```

# Acknowledgements

Thank you to Ewald de Wit for creating and maintaining ib-insync, eventkit, and nest-asyncio.
