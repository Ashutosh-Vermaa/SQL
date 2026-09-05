# Pandas Window Functions — SQL Equivalents

A practical guide to translating common SQL window functions into pandas.

## Sample DataFrame

We'll use this DataFrame throughout the examples:

```python
import pandas as pd

df = pd.DataFrame({
    "group": ["A", "A", "A", "A", "B", "B", "B", "B"],
    "date": pd.to_datetime([
        "2024-01-01", "2024-01-02", "2024-01-03", "2024-01-04",
        "2024-01-01", "2024-01-02", "2024-01-03", "2024-01-04"
    ]),
    "value": [10, 20, 20, 40, 5, 15, 15, 30]
})

df = df.sort_values(["group", "date"])
```

---

## 1. ROW_NUMBER()

Assign a unique sequential number within each group.

**SQL**
```sql
ROW_NUMBER() OVER (
    PARTITION BY group
    ORDER BY value DESC
)
```

**Pandas**
```python
df["row_number"] = (
    df.groupby("group")["value"]
      .rank(method="first", ascending=False)
)
```

**Parameters explained**
* `groupby("group")` — this is the `PARTITION BY` equivalent; it splits the data into independent groups so the ranking restarts for each one.
* `method="first"` — tells `rank()` how to break ties. `"first"` assigns ranks in the order rows appear in the DataFrame, which is exactly what `ROW_NUMBER()` does (no ties allowed).
* `ascending=False` — mirrors `ORDER BY value DESC`. Use `ascending=True` (the default) for `ORDER BY value ASC`.

**Example:**
```text
group  value  row_number
A       40       1
A       20       2
A       20       3
A       10       4
```

`method="first"` breaks ties according to their order in the DataFrame.

---

## 2. RANK()

Assign ranks while leaving gaps after ties.

**SQL**
```sql
RANK() OVER (
    PARTITION BY group
    ORDER BY value DESC
)
```

**Pandas**
```python
df["rank"] = (
    df.groupby("group")["value"]
      .rank(method="min", ascending=False)
)
```

**Parameters explained**
* `method="min"` — every row in a tied group gets the lowest rank in that group (e.g. two rows tied for 2nd both get `2`), and the *next* rank skips ahead to account for the tied rows. This is exactly `RANK()`'s "gap after ties" behavior.
* `ascending=False` — descending order, same role as in `ROW_NUMBER()` above.

**Example:**
```text
value    rank
40        1
20        2
20        2
10        4
```

Notice the gap after the tied values.

**SQL equivalent**
`RANK()` is equivalent to: `rank(method="min")`

---

## 3. DENSE_RANK()

Assign ranks without gaps after ties.

**SQL**
```sql
DENSE_RANK() OVER (
    PARTITION BY group
    ORDER BY value DESC
)
```

**Pandas**
```python
df["dense_rank"] = (
    df.groupby("group")["value"]
      .rank(method="dense", ascending=False)
)
```

**Parameters explained**
* `method="dense"` — like `"min"`, tied rows share a rank, but the next distinct value's rank increases by only 1 (no gap). This matches `DENSE_RANK()`'s behavior exactly.
* `ascending=False` — descending order.

**SQL equivalent**
`DENSE_RANK()` is equivalent to: `rank(method="dense")`

**Example:**
```text
value    dense_rank
40          1
20          2
20          2
10          3
```

**Compare:**
```text
Values:        40  20  20  10
RANK:           1   2   2   4
DENSE_RANK:     1   2   2   3
```

---

## 4. LAG()

Get the value from a previous row within the group.

**SQL**
```sql
LAG(value) OVER (
    PARTITION BY group
    ORDER BY date
)
```

**Pandas**
```python
df["prev_value"] = (
    df.groupby("group")["value"]
      .shift(1)
)
```

**Parameters explained**
* `shift(periods)` — `periods` is the number of rows to look back. `1` means "the row directly before this one," matching `LAG(value)` (which defaults to an offset of 1 in SQL).
* Rows with no prior row in their group (the first row of each partition) get `NaN`, just like SQL returns `NULL` in that case.

**Example:**
```text
group  value  prev_value
A       10       NaN
A       20      10
A       20      20
A       40      20

B        5       NaN
B       15       5
B       15      15
B       30      15
```

**LAG by more than one row**
```python
df.groupby("group")["value"].shift(2)
```
Equivalent to: `LAG(value, 2) OVER (...)`

**LAG with a default value**
SQL's three-argument form, `LAG(value, 1, 0)`, substitutes `0` instead of `NULL` when there's no previous row. In pandas, chain `fillna()`:
```python
df["prev_value_default"] = (
    df.groupby("group")["value"]
      .shift(1)
      .fillna(0)
)
```
`fillna(0)` replaces the `NaN`s produced by `shift()` with the SQL-style default.

---

## 5. LEAD()

Get the value from the next row within the group.

**SQL**
```sql
LEAD(value) OVER (
    PARTITION BY group
    ORDER BY date
)
```

**Pandas**
```python
df["next_value"] = (
    df.groupby("group")["value"]
      .shift(-1)
)
```

**Parameters explained**
* `shift(-1)` — a negative `periods` value looks *forward* instead of backward, so `-1` means "the next row," matching `LEAD(value)`.
* As with `LAG()`, a `LEAD(value, n, default)` form can be reproduced with `shift(-n).fillna(default)`.

`shift(-1)` means "next row."

---

## 6. FIRST_VALUE()

Get the first value within each group.

**SQL**
```sql
FIRST_VALUE(value) OVER (
    PARTITION BY group
    ORDER BY date
)
```

**Pandas**
```python
df["first_value"] = (
    df.groupby("group")["value"]
      .transform("first")
)
```

**Parameters explained**
* `transform("first")` — `"first"` is a built-in aggregation name meaning "the first row encountered per group." Because `transform()` broadcasts the group-level result back to every row, this matches a `PARTITION BY`-only window (no explicit frame).
* This depends entirely on row order, so make sure the DataFrame is sorted by your intended `ORDER BY` column(s) beforehand (see section 26).

**Example:**
```text
group  value  first_value
A       10        10
A       20        10
A       20        10
A       40        10
```

---

## 7. LAST_VALUE()

Get the last value within each group.

**SQL**
```sql
LAST_VALUE(value) OVER (
    PARTITION BY group
    ORDER BY date
)
```

**Pandas**
If you simply want the last value in each group:
```python
df["last_value"] = (
    df.groupby("group")["value"]
      .transform("last")
)
```

**Parameters explained**
* `transform("last")` — the counterpart to `"first"`; returns the value of the last row in each group and repeats it for every row in that group.

**Example:**
```text
group  value  last_value
A       10        40
A       20        40
A       20        40
A       40        40
```

*Note: SQL LAST_VALUE() is affected by the window frame. Pandas transform("last") gives the last value of the group, so the semantics are not always identical.*

**The default-frame gotcha**
Most SQL engines default an `ORDER BY` window to the frame `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`. Under that default, `LAST_VALUE()` doesn't actually return the group's true last row — it returns the *current* row (since nothing after "current row" is visible yet). This surprises a lot of people. If that's the behavior you're translating, the pandas equivalent is simply the column itself:
```python
df["last_value_default_frame"] = df["value"]
```
Only use `transform("last")` when the SQL frame is explicitly widened to `UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` (i.e., the whole partition is visible), which is what the example above assumes.

---

## 8. NTH_VALUE()

Get the value from a specific (n-th) row within each group.

**SQL**
```sql
NTH_VALUE(value, 2) OVER (
    PARTITION BY group
    ORDER BY date
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
)
```

**Pandas**
```python
df["nth_value"] = (
    df.groupby("group")["value"]
      .transform(lambda x: x.iloc[1])
)
```

**Parameters explained**
* `x.iloc[1]` — `iloc` uses 0-based positional indexing, so the SQL `NTH_VALUE(value, 2)` (1-based, "2nd row") corresponds to `x.iloc[1]`. In general, `NTH_VALUE(value, n)` → `x.iloc[n - 1]`.
* If a group might have fewer than `n` rows, guard against an `IndexError`:
```python
df["nth_value"] = (
    df.groupby("group")["value"]
      .transform(lambda x: x.iloc[1] if len(x) >= 2 else None)
)
```

---

## 9. SUM() OVER (PARTITION BY)

Calculate the total for each group and repeat it for every row.

**SQL**
```sql
SUM(value) OVER (
    PARTITION BY group
)
```

**Pandas**
```python
df["group_sum"] = (
    df.groupby("group")["value"]
      .transform("sum")
)
```

**Parameters explained**
* `transform(func)` — `func` can be a string naming a built-in aggregation (`"sum"`, `"mean"`, `"min"`, `"max"`, `"count"`, `"first"`, `"last"`, `"size"`, etc.) or a custom callable. Unlike `agg()`, `transform()` always returns a result with the same number of rows as the input, which is what makes it the natural fit for `PARTITION BY`-only window functions (no `ORDER BY`, no frame).

**Example:**
```text
group  value  group_sum
A       10       90
A       20       90
A       20       90
A       40       90

B        5       65
B       15       65
B       15       65
B       30       65
```

**Why `transform()`?**
This is an important distinction.

`groupby().sum()` reduces the data:
```python
df.groupby("group")["value"].sum()
```
Result:
```text
group
A    90
B    65
```

Whereas:
```python
df.groupby("group")["value"].transform("sum")
```
keeps the original number of rows:
```text
90
90
90
90
65
65
65
65
```
This is what we generally want from a window function.

---

## 10. AVG() OVER (PARTITION BY)

Calculate the average for each group.

**SQL**
```sql
AVG(value) OVER (
    PARTITION BY group
)
```

**Pandas**
```python
df["group_avg"] = (
    df.groupby("group")["value"]
      .transform("mean")
)
```

**Parameters explained**
* `"mean"` — the aggregation name for average. Like `"sum"`, it's computed per group and broadcast back to every row in that group.

---

## 11. MIN() OVER (PARTITION BY)

**SQL**
```sql
MIN(value) OVER (
    PARTITION BY group
)
```

**Pandas**
```python
df["group_min"] = (
    df.groupby("group")["value"]
      .transform("min")
)
```

**Parameters explained**
* `"min"` — smallest value per group, broadcast to every row.

---

## 12. MAX() OVER (PARTITION BY)

**SQL**
```sql
MAX(value) OVER (
    PARTITION BY group
)
```

**Pandas**
```python
df["group_max"] = (
    df.groupby("group")["value"]
      .transform("max")
)
```

**Parameters explained**
* `"max"` — largest value per group, broadcast to every row.

---

## 13. COUNT() OVER (PARTITION BY)

Count non-null values within each group.

**SQL**
```sql
COUNT(value) OVER (
    PARTITION BY group
)
```

**Pandas**
```python
df["group_count"] = (
    df.groupby("group")["value"]
      .transform("count")
)
```

**Parameters explained**
* `"count"` — counts non-null entries per group only (mirrors `COUNT(column)`, which ignores `NULL`s).

**Count all rows**
For SQL:
```sql
COUNT(*) OVER (
    PARTITION BY group
)
```
use:
```python
df["group_count"] = (
    df.groupby("group")["value"]
      .transform("size")
)
```
* `"size"` — counts every row per group regardless of null values (mirrors `COUNT(*)`).

The distinction is similar to:
*   `COUNT(column)`  -> ignores NULL
*   `COUNT(*)`       -> counts rows

---

## 14. Running SUM

Calculate a cumulative sum within each group.

**SQL**
```sql
SUM(value) OVER (
    PARTITION BY group
    ORDER BY date
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)
```

**Pandas**
```python
df["running_sum"] = (
    df.groupby("group")["value"]
      .cumsum()
)
```

**Parameters explained**
* `cumsum()` takes no window-size argument — it always accumulates from the start of each group up to the current row, which is exactly the `UNBOUNDED PRECEDING AND CURRENT ROW` frame.
* By default it propagates `NaN`s once encountered; pass `skipna=False` explicitly only if you want that behavior (it's actually the default — use `skipna=True`, the default, to ignore `NaN`s while accumulating).

**Example:**
```text
group  value  running_sum
A       10       10
A       20       30
A       20       50
A       40       90

B        5        5
B       15       20
B       15       35
B       30       65
```

---

## 15. Running AVG

Calculate the cumulative average within each group.

**SQL**
```sql
AVG(value) OVER (
    PARTITION BY group
    ORDER BY date
)
```

**Pandas**
```python
df["running_avg"] = (
    df.groupby("group")["value"]
      .expanding()
      .mean()
      .reset_index(level=0, drop=True)
)
```

**Parameters explained**
* `expanding()` — creates a window that grows to include every row from the start of the group up to (and including) the current row, matching the default `ORDER BY`-only frame. It optionally accepts `min_periods` (default `1`) to control how many observations are required before returning a non-NaN result.
* `.reset_index(level=0, drop=True)` — `expanding()`/`rolling()` on a grouped Series return a `MultiIndex` (group key + original index). This drops the group-key level so the result aligns back onto the original DataFrame's index.

Other useful cumulative operations:
```python
df.groupby("group")["value"].expanding().sum()
df.groupby("group")["value"].expanding().mean()
df.groupby("group")["value"].expanding().min()
df.groupby("group")["value"].expanding().max()
```

---

## 16. Rolling SUM

Calculate the sum over a fixed-size moving window.
For example, current row + previous 2 rows:

**SQL**
```sql
SUM(value) OVER (
    PARTITION BY group
    ORDER BY date
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
)
```

**Pandas**
```python
df["rolling_sum"] = (
    df.groupby("group")["value"]
      .rolling(3)
      .sum()
      .reset_index(level=0, drop=True)
)
```

**Parameters explained**
* `rolling(window)` — `window=3` means "3 rows total" (current + 2 preceding), matching `2 PRECEDING AND CURRENT ROW`. In general, `N PRECEDING AND CURRENT ROW` → `rolling(N + 1)`.
* By default, `rolling()` requires the full window to be present before it returns a value — earlier rows that don't have enough history return `NaN`.

For:
`A: 10, 20, 20, 40`
the result is:
```text
10     NaN
20     NaN
20    50
40    80
```

**Allow incomplete windows**
Use `min_periods=1`:
```python
df["rolling_sum"] = (
    df.groupby("group")["value"]
      .rolling(3, min_periods=1)
      .sum()
      .reset_index(level=0, drop=True)
)
```
* `min_periods=1` — allows the calculation to run with as few as 1 observation, so the first couple of rows in each group get a partial-window result instead of `NaN`. This is closer to how SQL's `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` behaves at the start of a partition (it just uses however many preceding rows exist).

Result:
```text
10    10
20    30
20    50
40    80
```

---

## 17. Rolling AVG

**SQL**
```sql
AVG(value) OVER (
    PARTITION BY group
    ORDER BY date
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
)
```

**Pandas**
```python
df["rolling_avg"] = (
    df.groupby("group")["value"]
      .rolling(3, min_periods=1)
      .mean()
      .reset_index(level=0, drop=True)
)
```

**Parameters explained**
* Same `window=3` / `min_periods=1` logic as the rolling sum above, just paired with `.mean()` instead of `.sum()`.

---

## 18. NTILE()

Divide rows within each group into approximately equal-sized buckets.

**SQL**
```sql
NTILE(4) OVER (
    PARTITION BY group
    ORDER BY value
)
```

**Pandas**
There is no direct `ntile()` equivalent, but `qcut()` can be used:
```python
df["quartile"] = (
    df.groupby("group")["value"]
      .transform(
          lambda x: pd.qcut(
              x.rank(method="first"),
              4,
              labels=False
          ) + 1
      )
)
```

**Parameters explained**
* `x.rank(method="first")` — `qcut()` needs strictly ordered, tie-free input to split evenly; ranking first (breaking ties by row order) avoids `qcut` raising an error on duplicate bin edges.
* `pd.qcut(data, q, labels=False)` — `q=4` requests quartiles (4 buckets); `labels=False` returns integer bucket indices (`0`–`3`) instead of interval labels.
* `+ 1` — SQL's `NTILE()` buckets are 1-indexed, so this shifts pandas' 0-indexed buckets to match.

This divides each group into approximately equal-sized buckets.

---

## 19. PERCENT_RANK()

**SQL**
```sql
PERCENT_RANK() OVER (
    PARTITION BY group
    ORDER BY value
)
```

**Pandas**
A simple approximation:
```python
df["percent_rank"] = (
    df.groupby("group")["value"]
      .rank(pct=True, method="min")
)
```

**Parameters explained**
* `pct=True` — returns ranks as a fraction between 0 and 1 (rank divided by group size) instead of an integer rank.
* `method="min"` — tie-handling, same as in the `RANK()` section. Note this is an *approximation*: `rank(pct=True)` divides by the group's row count, whereas SQL's `PERCENT_RANK()` divides by `(count - 1)`, so the two only match exactly when there are no ties and group sizes are large.

For strict SQL-equivalent behavior:
```python
df["percent_rank"] = (
    df.groupby("group")["value"]
      .transform(
          lambda x:
              (x.rank(method="min") - 1) / (x.count() - 1)
              if x.count() > 1 else 0
      )
)
```
* `(rank - 1) / (count - 1)` — this is `PERCENT_RANK()`'s exact formula: it rescales ranks so the lowest value is always `0` and the highest is always `1`.
* `if x.count() > 1 else 0` — guards against division by zero when a group has only one row (SQL defines `PERCENT_RANK()` as `0` in that case).

---

## 20. CUME_DIST()

Calculate the cumulative distribution (fraction of rows with a value less than or equal to the current row's value).

**SQL**
```sql
CUME_DIST() OVER (
    PARTITION BY group
    ORDER BY value
)
```

**Pandas**
```python
df["cume_dist"] = (
    df.groupby("group")["value"]
      .rank(pct=True, method="max")
)
```

**Parameters explained**
* `pct=True` — same as in `PERCENT_RANK()`, converts ranks to a 0–1 fraction.
* `method="max"` — the key difference from `PERCENT_RANK()`: tied rows all receive the *highest* rank among the tied group before converting to a percentage, which matches `CUME_DIST()`'s definition ("fraction of rows with value ≤ this row's value," so ties are all counted together).

---

## 21. Difference from Previous Row

A common SQL pattern is:

**SQL**
```sql
value - LAG(value) OVER (
    PARTITION BY group
    ORDER BY date
)
```

**Pandas**
```python
df["change"] = (
    df["value"]
    - df.groupby("group")["value"].shift(1)
)
```

**Parameters explained**
* `shift(1)` — same as in the `LAG()` section; the previous row's value within the group.
* Subtracting it from the raw column reproduces `value - LAG(value)` directly, row for row.

**Result:**
```text
group  value  change
A       10      NaN
A       20       10
A       20        0
A       40       20

B        5      NaN
B       15       10
B       15        0
B       30       15
```

---

## 22. Percentage Change from Previous Row

**SQL**
Conceptually:
```sql
(
    value - LAG(value) OVER (...)
) / LAG(value) OVER (...)
```

**Pandas**
```python
df["pct_change"] = (
    df.groupby("group")["value"]
      .pct_change()
)
```

**Parameters explained**
* `pct_change(periods=1)` — `periods` (default `1`) controls how many rows back the comparison is made against, same idea as `shift()`'s `periods`. `periods=2` would compare against two rows prior.
* Internally this is `(current - previous) / previous`, exactly the SQL formula above, computed within each group.

---

## 23. Running MAX

**SQL**
```sql
MAX(value) OVER (
    PARTITION BY group
    ORDER BY date
)
```

**Pandas**
```python
df["running_max"] = (
    df.groupby("group")["value"]
      .cummax()
)
```

**Parameters explained**
* `cummax()` — like `cumsum()`, it has no window-size argument; it always tracks the running maximum from the start of the group through the current row (`UNBOUNDED PRECEDING AND CURRENT ROW`).

---

## 24. Running MIN

**SQL**
```sql
MIN(value) OVER (
    PARTITION BY group
    ORDER BY date
)
```

**Pandas**
```python
df["running_min"] = (
    df.groupby("group")["value"]
      .cummin()
)
```

**Parameters explained**
* `cummin()` — the running-minimum counterpart to `cummax()`.

---

## 25. Running COUNT

**SQL**
```sql
COUNT(*) OVER (
    PARTITION BY group
    ORDER BY date
)
```

**Pandas**
```python
df["running_count"] = (
    df.groupby("group")
      .cumcount() + 1
)
```

**Parameters explained**
* `cumcount()` — returns a 0-based running count of rows seen so far within each group, so `+ 1` converts it to the 1-based count that `COUNT(*) OVER (ORDER BY ...)` produces.
* `cumcount(ascending=False)` — pass `ascending=False` to count *down* from the group's total instead (useful for "rows remaining" style calculations).

**Result:**
```text
group  running_count
A           1
A           2
A           3
A           4
B           1
B           2
B           3
B           4
```

---

## 26. Conditional Window Calculations

SQL often combines a window function with CASE WHEN.

**SQL**
```sql
SUM(
    CASE WHEN value > 10 THEN value ELSE 0 END
) OVER (
    PARTITION BY group
)
```

**Pandas**
First create the conditional values:
```python
df["conditional_value"] = df["value"].where(
    df["value"] > 10,
    0
)
```

**Parameters explained**
* `Series.where(cond, other)` — keeps the original value wherever `cond` is `True`, and replaces it with `other` wherever `cond` is `False`. This is the inverse of how `CASE WHEN` reads: `WHERE cond, keep it; ELSE, use other`.

Then:
```python
df["conditional_sum"] = (
    df.groupby("group")["conditional_value"]
      .transform("sum")
)
```

You can also write this more compactly:
```python
df["conditional_sum"] = (
    df["value"]
      .where(df["value"] > 10, 0)
      .groupby(df["group"])
      .transform("sum")
)
```
* `.groupby(df["group"])` — grouping directly by an external Series (rather than a column name on the same frame) is handy when chaining operations like this, since `.where()` returns a standalone Series that's no longer attached to `df`.

---

## 27. Multiple Partition Columns

SQL can partition by multiple columns:

**SQL**
```sql
SUM(value) OVER (
    PARTITION BY group, category
)
```

**Pandas**
```python
df.groupby(["group", "category"])["value"].transform("sum")
```

**Parameters explained**
* `groupby([...])` — passing a list of column names partitions by the combination of all of them, exactly like listing multiple columns after `PARTITION BY`.

The same applies to ranking:
```python
df["rank"] = (
    df.groupby(["group", "category"])["value"]
      .rank(method="min", ascending=False)
)
```

---

## 28. Ordering Before Window Operations

SQL explicitly specifies ordering:
```sql
LAG(value) OVER (
    PARTITION BY group
    ORDER BY date
)
```

In pandas, you generally need to explicitly sort first:
```python
df = df.sort_values(["group", "date"])

df["prev_value"] = (
    df.groupby("group")["value"]
      .shift(1)
)
```

**Parameters explained**
* `sort_values([...])` — sorts by the listed columns in order, matching `ORDER BY group, date`. This step is what makes `shift()`, `cumsum()`, `rolling()`, etc. line up with the correct "previous"/"next" rows.
* Note: `groupby()` itself has a separate `sort` parameter (default `True`), which controls whether *group keys* come out in sorted order in the result — it does **not** sort rows *within* each group. Row order within a group is preserved from the input DataFrame, which is why sorting beforehand is still required.
* For reproducible tie-breaking, consider `df.sort_values([...], kind="stable")` — pandas' default sort isn't guaranteed stable for all algorithms, and a stable sort ensures rows that are tied on your sort columns keep their original relative order.

This is particularly important for:
*   `shift()`
*   `cumsum()`
*   `cummax()`
*   `cummin()`
*   `rolling()`
*   `rank()`

---

## SQL → Pandas Cheat Sheet

| SQL Window Function | Pandas Equivalent |
| :--- | :--- |
| `ROW_NUMBER()` | `groupby().rank(method="first")` |
| `RANK()` | `groupby().rank(method="min")` |
| `DENSE_RANK()` | `groupby().rank(method="dense")` |
| `LAG()` | `groupby().shift(1)` |
| `LEAD()` | `groupby().shift(-1)` |
| `FIRST_VALUE()` | `groupby().transform("first")` |
| `LAST_VALUE()` | `groupby().transform("last")` |
| `NTH_VALUE()` | `groupby().transform(lambda x: x.iloc[n-1])` |
| `SUM() OVER(PARTITION BY)` | `groupby().transform("sum")` |
| `AVG() OVER(PARTITION BY)` | `groupby().transform("mean")` |
| `MIN() OVER(PARTITION BY)` | `groupby().transform("min")` |
| `MAX() OVER(PARTITION BY)` | `groupby().transform("max")` |
| `COUNT() OVER(PARTITION BY)` | `groupby().transform("count")` |
| `Running SUM()` | `groupby().cumsum()` |
| `Running MAX()` | `groupby().cummax()` |
| `Running MIN()` | `groupby().cummin()` |
| `Running COUNT()` | `groupby().cumcount()` |
| `Running AVG()` | `groupby().expanding().mean()` |
| `Rolling SUM()` | `groupby().rolling().sum()` |
| `Rolling AVG()` | `groupby().rolling().mean()` |
| `PERCENT_RANK()` | `groupby().rank(pct=True)` |
| `CUME_DIST()` | `groupby().rank(pct=True, method="max")` |
| `NTILE()` | `groupby().transform(lambda...)` |

---

## The 4 Patterns to Remember

Most SQL window functions can be mapped to four major pandas patterns.

### 1. Ranking
```python
df.groupby("group")["value"].rank(...)
```
**Examples:**
```python
# RANK()
df.groupby("group")["value"].rank(method="min")

# DENSE_RANK()
df.groupby("group")["value"].rank(method="dense")

# ROW_NUMBER()
df.groupby("group")["value"].rank(method="first")
```
The `method` parameter is what changes the behavior — `"min"` leaves gaps after ties, `"dense"` doesn't, and `"first"` forbids ties altogether by breaking them on row order.

### 2. Previous / Next Row
Use `shift()`:
```python
# LAG()
df.groupby("group")["value"].shift(1)

# LEAD()
df.groupby("group")["value"].shift(-1)
```
`shift()`'s single argument is a signed offset: positive looks backward (`LAG`), negative looks forward (`LEAD`).

### 3. Group-Level Value Repeated on Every Row
Use `transform()`:
```python
# SUM() OVER (PARTITION BY ...)
df.groupby("group")["value"].transform("sum")

# AVG()
df.groupby("group")["value"].transform("mean")

# MIN()
df.groupby("group")["value"].transform("min")

# MAX()
df.groupby("group")["value"].transform("max")
```
`transform()` always returns one output row per input row, which is what lets a group-level aggregate be "spread back out" onto every row — the pandas analogue of a `PARTITION BY`-only window.

### 4. Running / Rolling Calculations
For cumulative calculations:
```python
df.groupby("group")["value"].cumsum()
df.groupby("group")["value"].cummax()
df.groupby("group")["value"].cummin()
df.groupby("group").cumcount()
```
These take no window-size parameter — they always run from the start of the group to the current row.

For moving windows:
```python
df.groupby("group")["value"].rolling(3).sum()
df.groupby("group")["value"].rolling(3).mean()
```
`rolling(window)` takes a fixed window size (`window`), plus an optional `min_periods` to allow partial windows at the edges of each group.

---

## Quick Mental Model

When translating SQL window functions to pandas, ask:

*   **Is it a ranking?**
    ↓
    `rank()`

*   **Is it previous/next row?**
    ↓
    `shift()`

*   **Is it a group-level aggregate repeated on every row?**
    ↓
    `transform()`

*   **Is it cumulative?**
    ↓
    `cumsum()` / `cummax()` / `cummin()` / `cumcount()`

*   **Is it a moving window?**
    ↓
    `rolling()`

*   **Is it an expanding window?**
    ↓
    `expanding()`

These patterns cover a large majority of common SQL window-function use cases in pandas.
