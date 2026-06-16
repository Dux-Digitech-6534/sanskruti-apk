Document workflow-state chip with a leading dot. Auto-maps common ERPNext statuses to a tone (To Receive → pending, Completed → approved, Draft → draft).

```jsx
<StatusTag label="To Receive and Bill" />
<StatusTag tone="approved">Paid</StatusTag>
```

Override the auto-mapping with `tone`. Tones: approved (green), pending (amber), draft (grey).
