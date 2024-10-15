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

import pytest

import ib_interface as ibi

pytestmark = pytest.mark.asyncio


async def test_request_error_raised(ib):
    contract = ibi.Forex("EURUSD")
    order = ibi.MarketOrder("BUY", 100)
    orderState = await ib.whatIfOrderAsync(contract, order)
    assert orderState.commission > 0

    ib.RaiseRequestErrors = True
    badContract = ibi.Stock("XXX")
    with pytest.raises(ibi.RequestError) as exc_info:
        await ib.whatIfOrderAsync(badContract, order)
    assert exc_info.value.code == 321


async def test_account_summary(ib):
    summary = await ib.accountSummaryAsync()
    assert summary
    assert all(isinstance(value, ibi.AccountValue) for value in summary)
