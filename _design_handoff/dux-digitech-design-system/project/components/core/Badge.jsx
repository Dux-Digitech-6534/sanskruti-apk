import React from 'react';

/**
 * Badge — small count / label chip. Tones map to brand + status colors.
 * For document workflow states use <StatusTag>; for query filters use
 * <FilterPill>. This is the generic neutral/brand chip.
 */
export function Badge({ children, tone = 'neutral', mono = false, style = {} }) {
  const tones = {
    neutral: { color: 'var(--text-secondary)', bg: 'var(--bg-sunken)' },
    iris:    { color: 'var(--iris)', bg: 'var(--iris-tint)' },
    cyan:    { color: 'var(--cyan)', bg: 'var(--cyan-tint)' },
    ok:      { color: 'var(--ok)', bg: 'var(--ok-bg)' },
    pending: { color: 'var(--pending)', bg: 'var(--pending-bg)' },
    err:     { color: 'var(--err)', bg: 'var(--err-bg)' },
  }[tone];
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 5,
      fontSize: 'var(--fs-micro)', fontWeight: 'var(--fw-semibold)', lineHeight: 1,
      padding: '4px 9px', borderRadius: 'var(--r-pill)',
      color: tones.color, background: tones.bg,
      fontFamily: mono ? 'var(--font-mono)' : 'var(--font-ui)',
      fontVariantNumeric: mono ? 'tabular-nums' : 'normal', ...style,
    }}>
      {children}
    </span>
  );
}
