Primary action control. Use `primary` (iris gradient) for the main action on a surface, `secondary` (hairline pill) for everything else, `ghost` for low-emphasis inline actions.

```jsx
<Button variant="primary" icon="plus">New search</Button>
<Button variant="secondary">Cancel</Button>
<Button variant="ghost" iconRight="chevron">Details</Button>
```

Sizes: sm | md | lg. Pills by default — pass `rounded="md"` for squared corners. One primary per view.
