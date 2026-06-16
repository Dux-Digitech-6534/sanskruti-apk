The DUX result-card chrome — hairline border, soft ambient shadow, inset highlight, 16px radius. Wrap tables, filter pills, or any grouped content.

```jsx
<Card accent>
  <CardMeta left={<><b>12</b> records found</>} right={<>Total ₹4,20,000</>} />
  {/* table … */}
</Card>
```

`accent` adds the brand-gradient top line. Default padding is 0 (for edge-to-edge tables); set `padding` for prose cards.
