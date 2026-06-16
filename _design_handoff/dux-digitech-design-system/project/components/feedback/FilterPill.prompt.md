The transparency chip that shows which filter produced a result — DUX's signature "show your work" element. Wrap a row of them in `FilterBar`.

```jsx
<FilterBar>
  <FilterPill icon="clock" label="Status" value="Pending" tint="pending" />
  <FilterPill icon="truck" label="Supplier" value="Bhandari" tint="iris" />
  <FilterPill icon="rupee" label="Amount" value="> ₹50,000" tint="cyan" num />
</FilterBar>
```

Set `num` for amounts/numbers (mono cyan). Tints: iris, cyan, pending, ok, mut.
