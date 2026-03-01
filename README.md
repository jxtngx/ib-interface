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

> [!WARNING]
> **ACTIVE DEVELOPMENT - NOT PRODUCTION READY**
> 
> This project is undergoing significant modernization and refactoring. Breaking changes are being introduced regularly as we update outdated ib-insync implementations. DO NOT use this in production environments.

> [!CAUTION]
> **EXPECT BROKEN FEATURES**
> 
> Many features may be partially or completely broken as we migrate from the archived ib-insync codebase. The original ib-insync implementation has not been maintained since its archival, and compatibility with current TWS/Gateway versions cannot be guaranteed.

> [!CAUTION]
> **BREAKING CHANGES WITHOUT NOTICE**
> 
> API contracts, module structure, and function signatures are subject to change without deprecation warnings during this development phase. Pinning specific versions is strongly recommended if you choose to experiment with this library.

## Project Status

This project is currently in **active modernization** with the following goals:

- Updating outdated dependencies and code patterns from ib-insync
- Implementing modern Python practices (type hints, async patterns, etc.)
- Adding observability and telemetry infrastructure
- Establishing comprehensive testing and documentation

**Current Phase**: Sprint 1 - Core modernization and dependency updates

The main features (when stable) will be:

* An easy to use linear style of programming
* An `IB component` that automatically keeps in sync with the TWS or IB Gateway application
* A fully asynchonous framework based on `asyncio`
* Interactive operation with live data in Jupyter notebooks

> [!IMPORTANT]
> This project is not affiliated with Interactive Brokers

> [!IMPORTANT]
> The ibapi package from IB is not needed

> [!NOTE]
> The original ib-insync project has been archived and is no longer maintained

## Installation

> [!WARNING]
> Installation is not recommended for production use during active development phase

```bash
# For experimental/development use only
pip install ib-interface
```

## Usage

> [!CAUTION]
> The API may not be stable. These usage patterns may change without notice.

The eventual goal is for `ib-insync` users to be able to simply refactor their imports as:

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

**Note**: During the modernization phase, some modules may be restructured, renamed, or removed entirely.

## Example

> [!WARNING]
> This example may not work with the current development version. It is provided as a reference for the intended API design.

> [!IMPORTANT]
> A running TWS or Gateway instance is needed to connect to the API

> [!IMPORTANT]
> Make sure the [API port is enabled](https://ibkrcampus.com/campus/ibkr-api-page/twsapi-doc/#tws-config-api) and 'Download open orders on connection' is checked.

This is an example script to download historical data (functionality subject to change):

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

Expected output format (example from ib-insync, may differ):
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

## Support Model

> [!NOTE]
> **This is an open-source project, not a product**
> 
> This project is maintained on a best-effort basis. Issues and feature requests are not guaranteed to be addressed. There are no SLAs, timelines, or commitments for fixes or features.

## Feature Requests

If you would like to request a feature or prioritize specific functionality:

**Consider sponsoring the project**

Sponsorship helps sustain development and allows dedicated time for feature implementation. Sponsored features receive priority consideration.

For sponsorship inquiries, please open a discussion on the project repository.

## Contributing

**Contributions are not accepted.**

This project is maintained through a partnership with agentic coding tools. Sponsorship proceeds are used to fund these tools for ongoing maintenance and feature development. This approach ensures consistent code quality and architectural coherence while allowing rapid iteration.

If you'd like to influence the project's direction, consider sponsoring instead of submitting pull requests.

## Reporting Issues

If you encounter broken features or compatibility issues, you may report them for visibility, but understand that:

- Issues may not be addressed immediately or at all
- Fixes will be prioritized based on project goals and available time
- This is not a support channel with guaranteed response times

When reporting issues:

1. Check if the issue is documented in existing project plans
2. Verify you're using a compatible TWS/Gateway version
3. Include your TWS/Gateway version, Python version, and a minimal reproduction example in your report

