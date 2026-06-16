import React from 'react';
import { Icon } from '../brand/Icon.jsx';

/**
 * FilterPill — the transparency chip that shows WHICH filter produced a result
 * ("Supplier: Bhandari", "Amount: > ₹50,000"). Icon tile + key + value. The
 * `tint` colors the icon tile; numeric values render in mono cyan.
 */
const TINTS = {
  iris:    { color: 'var(--iris)', bg: 'var(--iris-tint)' },
  cyan:    { color: 'var(--cyan)', bg: 'var(--cyan-tint)' },
  pending: { color: 'var(--pending)', bg: 'var(--pending-bg)' },
  ok:      { color: 'var(--ok)', bg: 'var(--ok-bg)' },
  mut:     { color: 'var(--text-secondary)', bg: 'var(--bg-sunken)' },
};

export function FilterPill({ icon = 'filter', label, value, tint = 'mut', num = false, style = {} }) {
  const t = TINTS[tint] || TINTS.mut;
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 7,
      padding: '6px 11px 6px 9px', borderRadius: 'var(--r-sm)', fontSize: 12.5,
      background: 'var(--pill-bg)', border: '1px solid var(--border-strong)',
      color: 'var(--text-primary)', ...style,
    }}>
      <span style={{
        width: 22, height: 22, borderRadius: 6, display: 'grid', placeItems: 'center',
        flex: '0 0 auto', color: t.color, background: t.bg,
      }}>
        <Icon name={icon} size={13} />
      </span>
      {label && <span style={{ color: 'var(--text-muted)' }}>{label}:</span>}
      <span style={{
        fontWeight: 'var(--fw-medium)',
        fontFamily: num ? 'var(--font-mono)' : 'inherit',
        fontVariantNumeric: num ? 'tabular-nums' : 'normal',
        color: num ? 'var(--cyan)' : 'inherit',
      }}>{value}</span>
    </span>
  );
}

/** Labelled bar that wraps a row of FilterPills (the "Showing results for" strip). */
export function FilterBar({ children, style = {} }) {
  return (
    <div style={{ padding: '14px 16px 13px', position: 'relative', ...style }}>
      <span aria-hidden="true" style={{ position: 'absolute', left: 0, right: 0, top: 0, height: 2, background: 'var(--brand-grad)', opacity: .6 }} />
      <div style={{
        display: 'flex', alignItems: 'center', gap: 7, marginBottom: 11,
        fontSize: 'var(--fs-label)', letterSpacing: 'var(--ls-label)', textTransform: 'uppercase',
        color: 'var(--text-muted)', fontWeight: 'var(--fw-semibold)',
      }}>
        <Icon name="filter" size={13} /> Showing results for
      </div>
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>{children}</div>
    </div>
  );
}
