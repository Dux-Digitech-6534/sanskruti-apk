import React from 'react';

/**
 * Card — the DUX result-card chrome: hairline border, soft ambient shadow,
 * inset highlight, generous radius. Optional brand-gradient top accent line
 * (the "filter bar" treatment). Compose meta rows / tables inside.
 */
export function Card({ children, accent = false, padding = 0, style = {}, ...rest }) {
  return (
    <div
      style={{
        position: 'relative', background: 'var(--bg-card)',
        border: '1px solid var(--border-subtle)', borderRadius: 'var(--r-lg)',
        boxShadow: 'var(--shadow-card), var(--inset-hi)', overflow: 'hidden',
        padding, ...style,
      }}
      {...rest}
    >
      {accent && (
        <span aria-hidden="true" style={{
          position: 'absolute', left: 0, right: 0, top: 0, height: 2,
          background: 'var(--brand-grad)', opacity: .6,
        }} />
      )}
      {children}
    </div>
  );
}

/** Meta strip — count / summary row that sits below a card's header. */
export function CardMeta({ left, right, style = {} }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '11px 16px', borderBottom: '1px solid var(--border-subtle)',
      background: 'var(--meta-bg)', fontSize: 'var(--fs-meta)', ...style,
    }}>
      <span style={{ color: 'var(--text-secondary)' }}>{left}</span>
      <span style={{ color: 'var(--text-muted)' }}>{right}</span>
    </div>
  );
}
