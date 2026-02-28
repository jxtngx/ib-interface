# Feasibility Report: Modernizing ib-interface to Official TWS API Parity

## Executive Summary

This report analyzes the feasibility of bringing `ib-interface` (a monorepo of archived community versions derived from `ib_insync`) up to par with the official Interactive Brokers TWS Python API (`pythonclient/`).

**Key Finding**: The two codebases follow fundamentally different architectural paradigms. Full parity would require a near-complete rewrite. However, a **pragmatic hybrid approach** is feasible and recommended.

| Aspect | Official API | ib-interface | Gap Severity |
|--------|-------------|--------------|--------------|
| Server Version | 100-222 | 157-178 | **CRITICAL** |
| Protobuf Support | 204 messages | None | **CRITICAL** |
| Architecture | Threaded + EReader | asyncio + Events | Different |
| Order Attributes | 60+ | ~50 | HIGH |
| Contract Attributes | ~35 | ~25 | MEDIUM |
| Configuration API | Full | None | HIGH |
| TWSSyncWrapper | Yes | No | MEDIUM |

---

## 1. Architectural Comparison

### 1.1 Official API Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     User Application                        │
├─────────────────────────────────────────────────────────────┤
│  TWSSyncWrapper (Sync convenience)                          │
│       OR                                                    │
│  EClient + EWrapper (Async callback pattern)                │
├─────────────────────────────────────────────────────────────┤
│  EReader (Message parsing thread)                           │
├─────────────────────────────────────────────────────────────┤
│  Connection (Socket management)                             │
├─────────────────────────────────────────────────────────────┤
│  Protobuf Messages (204 types) + Legacy String Protocol     │
└─────────────────────────────────────────────────────────────┘
```

**Characteristics:**
- Threaded model with dedicated reader thread
- Callback-based via EWrapper method overrides
- Dual protocol support: Legacy string-based + Protobuf
- TWSSyncWrapper for simplified synchronous operations

### 1.2 ib-interface Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     User Application                        │
├─────────────────────────────────────────────────────────────┤
│  IB (High-level facade with convenience methods)            │
├─────────────────────────────────────────────────────────────┤
│  Client (asyncio Protocol) + Wrapper (State management)     │
├─────────────────────────────────────────────────────────────┤
│  EventKit (Reactive event streaming with operators)         │
├─────────────────────────────────────────────────────────────┤
│  Connection (asyncio Protocol)                              │
├─────────────────────────────────────────────────────────────┤
│  Legacy String Protocol Only                                │
└─────────────────────────────────────────────────────────────┘
```

**Characteristics:**
- asyncio-native with non-blocking I/O
- Event-driven with reactive operators (RxPy-like)
- High-level convenience methods (qualifyContracts, bracketOrder, etc.)
- Dataclass-based objects with helper methods

---

## 2. Feature Gap Analysis

### 2.1 Server Version Support

| Version | Feature | Official | ib-interface |
|---------|---------|----------|--------------|
| 178 | PENDING_PRICE_REVISION | ✅ | ✅ (max) |
| 179 | FUND_DATA_FIELDS | ✅ | ❌ |
| 180 | MANUAL_ORDER_TIME_EXERCISE_OPTIONS | ✅ | ❌ |
| 181 | OPEN_ORDER_AD_STRATEGY | ✅ | ❌ |
| 182 | LAST_TRADE_DATE | ✅ | ❌ |
| 183 | CUSTOMER_ACCOUNT | ✅ | ❌ |
| 184 | PROFESSIONAL_CUSTOMER | ✅ | ❌ |
| 185 | BOND_ACCRUED_INTEREST | ✅ | ❌ |
| 186 | INELIGIBILITY_REASONS | ✅ | ❌ |
| 187-190 | RFQ_FIELDS | ✅ | ❌ |
| 191 | PERM_ID_AS_LONG | ✅ | ❌ |
| 192-193 | CME_TAGGING_FIELDS | ✅ | ❌ |
| 194 | ERROR_TIME | ✅ | ❌ |
| 195 | FULL_ORDER_PREVIEW_FIELDS | ✅ | ❌ |
| 196 | HISTORICAL_DATA_END | ✅ | ❌ |
| 197 | CURRENT_TIME_IN_MILLIS | ✅ | ❌ |
| 198 | SUBMITTER | ✅ | ❌ |
| 199 | IMBALANCE_ONLY | ✅ | ❌ |
| 200 | PARAMETRIZED_DAYS_OF_EXECUTIONS | ✅ | ❌ |
| **201** | **PROTOBUF** | ✅ | ❌ |
| 202-222 | Various Protobuf enhancements | ✅ | ❌ |

**Gap**: ib-interface is **44 server versions behind** (178 vs 222).

### 2.2 Order Attributes Comparison

**Missing in ib-interface:**

```python
# Regulatory / Compliance
customerAccount: str = ""
professionalCustomer: bool = False
bondAccruedInterest: str = ""

# Overnight / Extended Hours
includeOvernight: bool = False

# Manual Order Indicators
manualOrderIndicator: int = UNSET_INTEGER
submitter: str = ""

# Post-Only / Auction
postOnly: bool = False
allowPreOpen: bool = False
ignoreOpenAuction: bool = False
deactivate: bool = False
seekPriceImprovement = None

# What-If Extensions
whatIfType: int = UNSET_INTEGER

# Attached Orders (NEW in recent versions)
slOrderId: int = UNSET_INTEGER
slOrderType: str = ""
ptOrderId: int = UNSET_INTEGER
ptOrderType: str = ""
```

**Count**: ~15 missing order attributes

### 2.3 Contract/ContractDetails Attributes

**Missing in ib-interface:**

```python
# Contract
lastTradeDate: str = ""  # Separate from lastTradeDateOrContractMonth

# ContractDetails
minAlgoSize: Decimal
lastPricePrecision: Decimal
lastSizePrecision: Decimal
fundName: str
fundFamily: str
fundType: str
fundFrontLoad: str
fundBackLoad: str
fundBackLoadTimeInterval: str
fundManagementFee: str
fundClosed: bool
fundClosedForNewInvestors: bool
fundClosedForNewMoney: bool
fundNotifyAmount: str
fundMinimumInitialPurchase: str
fundSubsequentMinimumPurchase: str
fundBlueSkyStates: str
fundBlueSkyTerritories: str
fundDistributionPolicyIndicator: FundDistributionPolicyIndicator
fundAssetType: FundAssetType
ineligibilityReasonList: list
eventContract1: str
eventContractDescription1: str
eventContractDescription2: str
```

**Count**: ~25 missing ContractDetails attributes

### 2.4 Protobuf Message Types

The official API includes **204 Protobuf message definitions**:

| Category | Count | Examples |
|----------|-------|----------|
| Market Data | 25+ | TickPrice, TickSize, MarketDepth, etc. |
| Orders | 20+ | PlaceOrderRequest, OrderStatus, OpenOrder, etc. |
| Account/Positions | 15+ | AccountValue, Position, PortfolioValue, etc. |
| Historical Data | 15+ | HistoricalData, HistoricalTicks, etc. |
| News | 10+ | NewsArticle, HistoricalNews, etc. |
| Configuration | 8+ | ConfigRequest, UpdateConfigRequest, etc. |
| Scanner | 8+ | ScannerParameters, ScannerData, etc. |
| Other | 100+ | Various request/response types |

**ib-interface has ZERO Protobuf support.**

### 2.5 TWSSyncWrapper

The official API now includes `TWSSyncWrapper` - a synchronous convenience wrapper:

```python
class TWSSyncWrapper(EWrapper, EClient):
    """Synchronous wrapper combining EClient and EWrapper."""
    
    def connect_and_start(self, host, port, client_id): ...
    def get_contract_details(self, contract, timeout=5): ...
    def place_order_sync(self, contract, order, timeout=None): ...
    def get_market_data_snapshot(self, contract, ...): ...
    def get_historical_data(self, contract, ...): ...
    # ... etc
```

ib-interface has similar functionality in its `IB` class, but via asyncio instead of threading.

---

## 3. Feasibility Options

### Option A: Full Parity (NOT RECOMMENDED)

**Approach**: Rewrite ib-interface to match official API architecture.

**Pros:**
- 100% feature parity
- Same programming model as official docs

**Cons:**
- Loses all ib-interface advantages (asyncio, reactive events, convenience methods)
- Essentially abandons the project's value proposition
- Community would be better served using official API directly

**Effort**: 3-6 months full-time
**Recommendation**: ❌ NOT RECOMMENDED

### Option B: Protocol/Feature Parity Only (RECOMMENDED)

**Approach**: Keep asyncio architecture but add:
1. Server version updates (178 → 222)
2. Missing object attributes
3. Protobuf support (optional/parallel)
4. Configuration API

**Pros:**
- Preserves ib-interface's unique value (asyncio, events, convenience)
- Achievable incrementally
- Community can contribute

**Cons:**
- Different programming model than official API
- Must maintain dual implementations

**Effort**: 4-8 weeks focused development
**Recommendation**: ✅ RECOMMENDED

### Option C: Hybrid with Official API Dependency (ALTERNATIVE)

**Approach**: Use official `ibapi` as dependency, wrap with ib-interface's asyncio/event layer.

**Pros:**
- Automatic protocol updates from official API
- Focuses development on value-add features

**Cons:**
- Dependency on official API release cycle
- Potential version conflicts
- More complex integration

**Effort**: 2-4 weeks initial + ongoing maintenance
**Recommendation**: ⚠️ CONSIDER

---

## 4. Recommended Implementation Plan (Option B)

### Phase 1: Server Version & Attribute Updates (Priority: CRITICAL)

**Duration**: 1-2 weeks

**Tasks**:

1. **Update `server_versions.py` equivalent**
   ```python
   # client.py - Update version constants
   MinClientVersion = 100
   MaxClientVersion = 222  # Was 178
   ```

2. **Add missing Order attributes** (~15 attributes)
   ```python
   # order.py
   @dataclass
   class Order:
       # ... existing ...
       customerAccount: str = ""
       professionalCustomer: bool = False
       includeOvernight: bool = False
       manualOrderIndicator: int = UNSET_INTEGER
       submitter: str = ""
       postOnly: bool = False
       allowPreOpen: bool = False
       ignoreOpenAuction: bool = False
       deactivate: bool = False
       seekPriceImprovement: bool | None = None
       whatIfType: int = UNSET_INTEGER
       slOrderId: int = UNSET_INTEGER
       slOrderType: str = ""
       ptOrderId: int = UNSET_INTEGER
       ptOrderType: str = ""
   ```

3. **Add missing ContractDetails attributes** (~25 attributes)
   - Fund-related fields
   - Ineligibility reasons
   - Event contract fields

4. **Update Client.placeOrder() and other methods**
   - Add version checks for new attributes
   - Serialize new fields in protocol messages

**Deliverables**:
- [ ] Updated version constants
- [ ] Order dataclass with all attributes
- [ ] ContractDetails dataclass with all attributes
- [ ] Updated serialization in client.py

### Phase 2: Error Handling & API Enhancements (Priority: HIGH)

**Duration**: 1 week

**Tasks**:

1. **Update error callback signature**
   ```python
   # Current
   def error(self, reqId: int, errorCode: int, errorString: str, advancedOrderRejectJson: str):
   
   # Official API (v194+)
   def error(self, reqId: int, errorTime: int, errorCode: int, errorString: str, advancedOrderRejectJson: str = ""):
   ```

2. **Add `reqCurrentTimeInMillis()` support** (v197+)

3. **Add `commissionAndFeesReport` callback** (replaces `commissionReport`)

4. **Update decoder for new message formats**

### Phase 3: Protobuf Support (Priority: HIGH)

**Duration**: 2-3 weeks

**Tasks**:

1. **Add protobuf dependency**
   ```toml
   # pyproject.toml
   dependencies = [
       # ... existing ...
       "protobuf>=4.21.0",
   ]
   ```

2. **Copy/generate protobuf message files**
   - Either copy the 204 `*_pb2.py` files from official API
   - Or regenerate from `.proto` source files

3. **Implement dual-protocol decoder**
   ```python
   class Decoder:
       def interpret(self, fields):
           if self._is_protobuf_message(fields):
               return self._decode_protobuf(fields)
           else:
               return self._decode_legacy(fields)
   ```

4. **Add protobuf wrapper callbacks**
   ```python
   # wrapper.py
   def orderStatusProtoBuf(self, orderStatusProto):
       # Convert protobuf to internal objects
       ...
   ```

**Deliverables**:
- [ ] `protobuf/` directory with all message types
- [ ] Dual-protocol decoder
- [ ] Protobuf callback implementations

### Phase 4: Configuration API (Priority: MEDIUM)

**Duration**: 1 week

**Tasks**:

1. **Add configuration request methods**
   ```python
   # client.py
   def reqConfig(self, reqId: int):
       self.send(MSG_ID_REQ_CONFIG, reqId)
   
   def updateConfig(self, reqId: int, config: UpdateConfigRequest):
       # Serialize protobuf config
       ...
   ```

2. **Add configuration wrapper callbacks**
   ```python
   # wrapper.py
   def configResponse(self, reqId: int, configJson: str):
       ...
   
   def updateConfigResponse(self, reqId: int, success: bool, warnings: list):
       ...
   ```

3. **High-level IB methods**
   ```python
   # ib.py
   def getConfig(self) -> dict:
       """Get current TWS/Gateway API configuration."""
       ...
   
   def updateConfig(self, **settings):
       """Update TWS/Gateway API configuration."""
       ...
   ```

### Phase 5: Testing & Documentation (Priority: HIGH)

**Duration**: 1-2 weeks

**Tasks**:

1. **Unit tests for new attributes**
   - Order serialization
   - ContractDetails parsing
   - Protobuf encoding/decoding

2. **Integration tests with paper trading**
   - Connection with new server versions
   - Order placement with new attributes
   - Configuration API

3. **Documentation updates**
   - API changelog
   - Migration guide
   - New feature examples

---

## 5. Effort Estimation Summary

| Phase | Duration | Complexity | Dependencies |
|-------|----------|------------|--------------|
| Phase 1: Server/Attributes | 1-2 weeks | Medium | None |
| Phase 2: Error/API | 1 week | Low | Phase 1 |
| Phase 3: Protobuf | 2-3 weeks | High | Phase 1 |
| Phase 4: Config API | 1 week | Medium | Phase 3 |
| Phase 5: Testing/Docs | 1-2 weeks | Medium | All |

**Total**: 6-10 weeks for full feature parity

**Minimum Viable**: 2-3 weeks (Phase 1 + Phase 2 only)

---

## 6. Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Protobuf integration issues | Medium | High | Test with paper trading first |
| Breaking changes to existing users | Medium | Medium | Semantic versioning, deprecation warnings |
| Official API version changes | High | Low | Monitor IB API releases |
| Performance regression | Low | Medium | Benchmark before/after |
| Incomplete documentation | Medium | Medium | Prioritize common use cases |

---

## 7. Recommendations

### Immediate Actions (Next 2 weeks)

1. **Update server version constants** to 222
2. **Add critical missing Order attributes** (includeOvernight, customerAccount, professionalCustomer)
3. **Add critical missing ContractDetails attributes** (fund fields, ineligibility reasons)
4. **Update client.placeOrder()** with version checks for new attributes

### Short-term (Next 4-6 weeks)

1. **Implement Protobuf support** with dual-protocol decoder
2. **Add Configuration API** methods
3. **Expand test coverage** for new features

### Long-term Considerations

1. **Consider Option C** (official API wrapper) for future major versions
2. **Establish release cadence** aligned with IB API releases
3. **Community contribution guidelines** for feature updates

---

## 8. Conclusion

Bringing `ib-interface` to full parity with the official TWS API is **feasible but requires significant effort**. The recommended approach (Option B) preserves the project's unique asyncio-based architecture while adding the missing protocol features.

The minimum viable update (Phases 1-2) can be completed in 2-3 weeks and would bring the library to functional parity for most use cases. Full Protobuf support (Phase 3) is recommended for production use cases requiring the latest IB features.

**Decision Matrix:**

| If your priority is... | Recommended approach |
|------------------------|---------------------|
| Quick functional parity | Phase 1-2 only (2-3 weeks) |
| Full feature parity | All phases (6-10 weeks) |
| Long-term maintainability | Consider Option C (official API wrapper) |
| Maximum compatibility | Use official `ibapi` directly |

---

## Appendix A: File Change Summary

| File | Changes Required | Priority |
|------|-----------------|----------|
| `client.py` | Version constants, new methods, serialization | CRITICAL |
| `order.py` | 15+ new attributes | CRITICAL |
| `contract.py` | 25+ new attributes in ContractDetails | HIGH |
| `objects.py` | New data classes | HIGH |
| `wrapper.py` | New callbacks, protobuf callbacks | HIGH |
| `decoder.py` | Dual-protocol support | HIGH |
| `pyproject.toml` | Add protobuf dependency | MEDIUM |
| `protobuf/` | New directory (204 files) | MEDIUM |
| `ib.py` | High-level config methods | LOW |
| `tests/` | Comprehensive test coverage | HIGH |

## Appendix B: Version Compatibility Matrix

| ib-interface Version | Official API Version | TWS Version | Notes |
|---------------------|---------------------|-------------|-------|
| Current (0.1.0) | ~10.19 | 10.19+ | v178 max |
| Target (0.2.0) | 10.44+ | 10.44+ | v222 max |
| Future | Track official | Track official | Ongoing |
