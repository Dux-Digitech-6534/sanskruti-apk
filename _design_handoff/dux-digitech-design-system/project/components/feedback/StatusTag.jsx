import React from 'react';

/**
 * StatusTag — document workflow state chip with a leading dot. Auto-maps common
 * ERPNext statuses to a tone, or pass `tone` explicitly. Mirrors the chat
 * surface's statusTagClass() logic.
 */
const TONES = {
  approved: { color: 'var(--ok)', bg: 'var(--ok-bg)' },
  pending:  { color: 'var(--pending)', bg: 'var(--pending-bg)' },
  draft:    { color: 'var(--text-secondary)', bg: 'var(--bg-sunken)' },
};
function autoTone(label) {
  const s = String(label || '').toLowerCase();
  if (/draft|cancel|return|hold|rejected/.test(s)) return 'draft';
  if (/paid|approved|completed|closed|fulfilled|delivered|received and billed|active/.test(s)) return 'approved';
  return 'pending';
}

export function StatusTag({ children, label, tone, style = {} }) {
  const text = children ?? label;
  const t = TONES[tone || autoTone(text)];
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      fontSize: 'var(--fs-micro)', fontWeight: 'var(--fw-medium)', lineHeight: 1,
      padding: '3px 9px', borderRadius: 'var(--r-pill)', whiteSpace: 'nowrap',
      color: t.color, background: t.bg, ...style,
    }}>
      <span style={{ width: 5, height: 5, borderRadius: '50%', background: 'currentColor' }} />
      {text}
    </span>
  );
}
