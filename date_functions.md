Here is a categorized list of the most essential date and time functions in SQL (focusing on MySQL, as it matches your previous queries). Mastering these will cover 95% of your daily data manipulation needs.

### 1. Getting Current Date & Time

* **`CURRENT_DATE()`** or **`CURDATE()`**: Returns today's date (e.g., `2026-08-17`).
* **`NOW()`** or **`CURRENT_TIMESTAMP`**: Returns the current date *and* time (e.g., `2026-08-17 22:06:59`).
* **`CURTIME()`**: Returns just the current time (e.g., `22:06:59`).

### 2. Extracting Parts of a Date

* **`YEAR(date)`**, **`MONTH(date)`**, **`DAY(date)`**: Returns the respective integer part of the date.
* **`DAYNAME(date)`**: Returns the weekday name (e.g., `'Monday'`).
* **`DAYOFWEEK(date)`**: Returns the weekday index (1 = Sunday, 2 = Monday, etc.).
* **`EXTRACT(unit FROM date)`**: The ANSI-standard way to get parts of a date.
* *Example:* `EXTRACT(YEAR FROM trans_date)`



### 3. Date Math & Manipulation (Crucial for Analytics)

* **`DATEDIFF(date1, date2)`**: Returns the number of days between two dates (`date1 - date2`).
* *Example:* `DATEDIFF('2026-08-17', '2026-08-01')` returns `16`.


* **`DATE_ADD(date, INTERVAL expr unit)`**: Adds a specific time interval to a date.
* *Example:* `DATE_ADD(trans_date, INTERVAL 1 MONTH)`


* **`DATE_SUB(date, INTERVAL expr unit)`**: Subtracts a specific time interval from a date.
* *Example:* `DATE_SUB(NOW(), INTERVAL 7 DAY)` (Great for pulling "last 7 days" of data).


* **`LAST_DAY(date)`**: Returns the last date of the month for a given date (useful for calculating end-of-month reporting).
* *Example:* `LAST_DAY('2026-08-17')` returns `2026-08-31`.



### 4. Formatting and Conversion

* **`DATE(datetime)`**: Strips the time portion off a datetime stamp, leaving just `YYYY-MM-DD`.
* **`DATE_FORMAT(date, format)`**: Formats a date into a custom string (as we looked at previously).
* **`STR_TO_DATE(string, format)`**: The exact opposite of `DATE_FORMAT`. It converts a messy text string into a proper SQL date object.
* *Example:* `STR_TO_DATE('August 17, 2026', '%M %d, %Y')` becomes `2026-08-17`.


---

> **Pro-Tip for Filtering:** When querying for a specific date range, using `>=` and `<` is generally safer and faster than using `BETWEEN`, especially if your column contains time stamps.
> *Good:* `WHERE trans_date >= '2026-08-01' AND trans_date < '2026-09-01'`
