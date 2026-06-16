The signature DUX ask-bar: sparkle lead glyph, auto-growing textarea, iris-gradient send button, and a keyboard-hint footer. Focus reveals a brand-gradient border halo.

```jsx
const [q, setQ] = React.useState('');
<Composer value={q} onChange={(e) => setQ(e.target.value)} onSubmit={() => ask(q)} />
```

⏎ submits, ⇧⏎ adds a newline. Send is disabled until there's trimmed text.
