import { describe, expect, it } from 'vitest';
import { summarizeBudget } from './budget';
describe('summarizeBudget', () => {
 it('separates forecasts from actual spend', () => expect(summarizeBudget(10000,[{estimated_amount:3000,actual_amount:1000},{estimated_amount:2000,actual_amount:0}])).toEqual({budget:10000,estimated:5000,actual:1000,remaining:9000,utilization:10}));
 it('handles empty expenses and zero budget', () => expect(summarizeBudget(0,[])).toEqual({budget:0,estimated:0,actual:0,remaining:0,utilization:0}));
 it('shows overspending', () => expect(summarizeBudget(500,[{actual_amount:700}]).remaining).toBe(-200));
});
