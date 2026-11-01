export type BudgetExpense = { estimated_amount?: number | string | null; actual_amount?: number | string | null };
/** Estimated costs are forecasts; only actual_amount is counted as spent. */
export function summarizeBudget(budget: number, expenses: BudgetExpense[]) {
  const safeBudget = Number.isFinite(budget) ? budget : 0;
  const estimated = expenses.reduce((sum, item) => sum + Number(item.estimated_amount || 0), 0);
  const actual = expenses.reduce((sum, item) => sum + Number(item.actual_amount || 0), 0);
  return { budget: safeBudget, estimated, actual, remaining: safeBudget - actual, utilization: safeBudget > 0 ? Math.round(actual / safeBudget * 100) : 0 };
}
