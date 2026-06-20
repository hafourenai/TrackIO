# Features

## 1. Dashboard

The home screen provides a comprehensive financial overview.

| Widget | Description |
|---|---|
| **Balance Card** | Total balance with monthly income, expense, and savings summary |
| **Score Card** | Quick-access card to the Financial Score page (heart icon) |
| **Prediction Card** | Quick-access card to the Spending Prediction page (trending icon) |
| **Summary Section** | Monthly income vs. expense vs. remaining balance breakdown |
| **Weekly Expense Chart** | Bar chart (`fl_chart`) showing expenses divided into 4 weekly buckets |
| **Category Pie Chart** | Donut chart showing expense distribution by category with percentage labels |
| **Pull-to-Refresh** | Swipe down to reload all dashboard data |

**Data source:** All metrics are computed from the `transactions` table in real-time.

---

## 2. Transaction Management

Full CRUD for income and expense records.

| Action | Description |
|---|---|
| **Add Transaction** | Form with type (income/expense), title, amount, date, category, and optional note |
| **Edit Transaction** | Tap any transaction tile to modify its fields |
| **Delete Transaction** | Swipe left to delete with an **Undo** snackbar option |
| **Search** | Search bar filters transactions by title or note |
| **Filter** | Filter chips for type (all/income/expense), category, and date range |
| **Category Picker** | Bottom sheet with categorized icons for quick selection |

**Categories:**

| Income | Expense |
|---|---|
| Gaji (Salary) | Makan (Food) |
| Bonus | Transportasi (Transport) |
| Freelance | Belanja (Shopping) |
| | Hiburan (Entertainment) |
| | Kesehatan (Health) |
| | Pendidikan (Education) |
| | Lainnya (Others) |

---

## 3. AI Financial Advisor

Conversational AI assistant powered by Google Gemini 2.5 Flash.

**Features:**
- Context-aware responses based on the user's actual financial data
- Persistent chat history within a session
- Clear chat functionality
- Configurable API key (stored locally)

**System Prompt:** The AI is instructed to act as a **TrackIO Assistant** — an Indonesian-speaking financial advisor focused on budgeting, savings, expense management, and financial health.

**Context Provided to AI:**
- Current balance
- Monthly income and expense totals
- Largest spending category
- Target savings amount
- Financial health score and status

**Disclaimer:** The AI is instructed not to provide high-risk investment advice.

---

## 4. OCR Receipt Scanner

Scan paper receipts using the device camera or gallery to auto-fill transactions.

**How it works:**
1. Take a photo or select an image from the gallery
2. Google ML Kit processes the image and extracts text
3. The app analyzes the text to identify:
   - **Store name** (first non-numeric text line)
   - **Date** (via date pattern matching)
   - **Total amount** (priority-based detection: "total" keyword → "kembali" context → fallback)
4. Results are displayed in an editable form for manual correction
5. Confirm to save as a new expense transaction

**Smart Amount Detection (new):**
| Priority | Strategy |
|---|---|
| 1 | Lines containing "total" (excluding "jumlah item/barang") |
| 2 | Lines above "kembali" / change row |
| 3 | Lines above "tunai" / "cash" / "bayar" |
| 4 | Largest number in bottom 40% of receipt (≥ Rp1000) |

---

## 5. Financial Health Score

A 0-100 score evaluating the user's financial health across four dimensions.

| Component | Max Score | Criteria |
|---|---|---|
| **Saving Ratio** | 30 | Target: ≥20% of income saved |
| **Expense Ratio** | 25 | Target: <50% of income spent |
| **Income Consistency** | 25 | Stable income over time |
| **Balance Stability** | 20 | Positive savings maintained |

**Status Levels:**
- **Sangat Baik** (Excellent): 90+
- **Baik** (Good): 70-89
- **Cukup** (Fair): 40-69
- **Buruk** (Poor): <40

**Display:** Circular gauge with score, status badge, analysis description card, and detailed breakdown with linear progress bars.

---

## 6. Spending Prediction

Forecasts the end-of-month balance based on current spending trends.

**Calculation:**
1. Average daily expense = Total expenses so far / Days elapsed in month
2. Estimated remaining expense = Average daily × Days remaining
3. Predicted end balance = Current balance - Estimated remaining expense

**Display:**
- Large predicted balance (red if negative)
- Trend message (warning / caution / safe)
- Metrics card: current balance, average daily expense, estimated remaining, total estimated expense
- Line chart of daily expenses throughout the month

---

## 7. Smart Recommendations

AI-driven insights generated from spending analysis.

**Rule-based Engine:**
- Category overspend warnings (e.g., food >30%, shopping >20%, entertainment >15%)
- Savings rate alerts (below 10% of income)
- Month-over-month expense increase / decrease comparison
- Actionable recommendations for each insight

**Display:** Cards with warning/info icons, title, description, and tip section.
