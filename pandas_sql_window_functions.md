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
`shift(-1)` means "next row".

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

**Example:**
```text
group  value  last_value
A       10        40
A       20        40
A       20        40
A       40        40
```

*Note: SQL LAST_VALUE() is affected by the window frame. Pandas transform("last") gives the last value of the group, so the semantics are not always identical.*

---

## 8. SUM() OVER (PARTITION BY)

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

## 9. AVG() OVER (PARTITION BY)

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

---

## 10. MIN() OVER (PARTITION BY)

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

---

## 11. MAX() OVER (PARTITION BY)

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

---

## 12. COUNT() OVER (PARTITION BY)

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
The distinction is similar to:
*   `COUNT(column)`  -> ignores NULL
*   `COUNT(*)`       -> counts rows

---

## 13. Running SUM

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

## 14. Running AVG

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

Other useful cumulative operations:
```python
df.groupby("group")["value"].expanding().sum()
df.groupby("group")["value"].expanding().mean()
df.groupby("group")["value"].expanding().min()
df.groupby("group")["value"].expanding().max()
```

---

## 15. Rolling SUM

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
Result:
```text
10    10
20    30
20    50
40    80
```

---

## 16. Rolling AVG

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

---

## 17. NTILE()

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
This divides each group into approximately equal-sized buckets.

---

## 18. PERCENT_RANK()

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

---

## 19. Difference from Previous Row

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

## 20. Percentage Change from Previous Row

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

---

## 21. Running MAX

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

---

## 22. Running MIN

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

---

## 23. Running COUNT

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

## 24. Conditional Window Calculations

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

---

## 25. Multiple Partition Columns

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

The same applies to ranking:
```python
df["rank"] = (
    df.groupby(["group", "category"])["value"]
      .rank(method="min", ascending=False)
)
```

---

## 26. Ordering Before Window Operations

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

### 2. Previous / Next Row
Use `shift()`:
```python
# LAG()
df.groupby("group")["value"].shift(1)

# LEAD()
df.groupby("group")["value"].shift(-1)
```

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

### 4. Running / Rolling Calculations
For cumulative calculations:
```python
df.groupby("group")["value"].cumsum()
df.groupby("group")["value"].cummax()
df.groupby("group")["value"].cummin()
df.groupby("group").cumcount()
```
For moving windows:
```python
df.groupby("group")["value"].rolling(3).sum()
df.groupby("group")["value"].rolling(3).mean()
```

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
