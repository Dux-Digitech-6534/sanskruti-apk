import React from 'react';
import { BrandAvatar } from '../brand/BrandAvatar.jsx';

/**
 * ThinkingIndicator — the working state shown while DUX queries records.
 * A card with a sweeping brand-gradient top bar, a pulsing brand mark, a
 * shimmering headline and a sub-line. Inject @keyframes once via <ThinkingKeyframes/>.
 */
export function ThinkingIndicator({
  head = 'Reading your operations data…',
  sub = 'Parsing intent · matching filters · querying records',
  markLight, markWhite, style = {},
}) {
  return (
    <div style={{ display: 'flex', gap: 13, alignItems: 'flex-start', ...style }}>
      <ThinkingKeyframes />
      <div style={{
        flex: '1 1 auto', position: 'relative', overflow: 'hidden',
        padding: '15px 17px', borderRadius: 'var(--r-md)',
        background: 'var(--surface-2)', border: '1px solid var(--border-subtle)',
        boxShadow: 'var(--shadow-card)',
      }}>
        <span aria-hidden="true" style={{ position: 'absolute', top: 0, left: 0, right: 0, height: 2, background: 'var(--brand-grad)', opacity: .85 }} />
        <div style={{ display: 'flex', alignItems: 'center', gap: 13 }}>
          <span style={{ animation: 'duxBob 2.4s var(--ease) infinite', display: 'grid' }}>
            <BrandAvatar size={40} markLight={markLight} markWhite={markWhite} />
          </span>
          <div>
            <div style={{ fontSize: 13.5, fontWeight: 'var(--fw-medium)' }}>
              <span style={{
                background: 'linear-gradient(90deg, var(--fg-3) 30%, var(--fg-1) 50%, var(--fg-3) 70%)',
                backgroundSize: '200% 100%', WebkitBackgroundClip: 'text', backgroundClip: 'text',
                color: 'transparent', animation: 'duxShim 2.2s linear infinite',
              }}>{head}</span>
            </div>
            <div style={{ fontSize: 12, color: 'var(--text-muted)', marginTop: 5 }}>{sub}</div>
          </div>
        </div>
      </div>
    </div>
  );
}

export function ThinkingKeyframes() {
  return (
    <style>{`
      @keyframes duxBob { 0%,100%{transform:translateY(0);} 50%{transform:translateY(-3px);} }
      @keyframes duxShim { to { background-position:-200% 0; } }
    `}</style>
  );
}
