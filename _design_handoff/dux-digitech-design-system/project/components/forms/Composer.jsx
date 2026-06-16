import React from 'react';
import { Icon } from '../brand/Icon.jsx';

/**
 * Composer — the signature DUX "ask bar": a sparkle lead glyph, an auto-growing
 * textarea, and the iris-gradient send button. Focus reveals a brand-gradient
 * border halo. ⏎ submits, ⇧⏎ inserts a newline.
 */
export function Composer({
  value, onChange, onSubmit, placeholder = 'Ask about purchase orders, suppliers, amounts…',
  disabled = false, style = {},
}) {
  const [focus, setFocus] = React.useState(false);
  const ref = React.useRef(null);
  const grow = () => { const el = ref.current; if (!el) return; el.style.height = 'auto'; el.style.height = Math.min(el.scrollHeight, 140) + 'px'; };
  React.useEffect(grow, [value]);
  const canSend = !!(value && value.trim()) && !disabled;

  return (
    <div style={style}>
      <div style={{
        position: 'relative', display: 'flex', alignItems: 'flex-end', gap: 10,
        padding: '11px 11px 11px 16px', borderRadius: 'var(--r-xl)',
        background: 'var(--bg-surface)',
        border: `1px solid ${focus ? 'transparent' : 'var(--border-strong)'}`,
        boxShadow: 'var(--shadow-pop), var(--inset-hi)',
        transition: 'border-color var(--dur-slow) var(--ease)',
      }}>
        {focus && (
          <span aria-hidden="true" style={{
            position: 'absolute', inset: -1, borderRadius: 'inherit', padding: 1,
            background: 'var(--brand-grad)', opacity: .9, pointerEvents: 'none',
            WebkitMask: 'linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0)',
            WebkitMaskComposite: 'xor', maskComposite: 'exclude',
          }} />
        )}
        <span style={{ flex: '0 0 auto', width: 22, height: 22, marginBottom: 6, display: 'grid', placeItems: 'center' }}>
          <Icon name="sparkle" size={18} color="var(--iris)" />
        </span>
        <textarea
          ref={ref} rows={1} value={value} placeholder={placeholder} disabled={disabled}
          onChange={onChange}
          onFocus={() => setFocus(true)} onBlur={() => setFocus(false)}
          onKeyDown={(e) => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); if (canSend && onSubmit) onSubmit(); } }}
          style={{
            flex: '1 1 auto', resize: 'none', border: 'none', outline: 'none', background: 'transparent',
            fontFamily: 'var(--font-ui)', fontSize: 'var(--fs-body)', lineHeight: 1.5,
            color: 'var(--text-primary)', padding: '6px 0', maxHeight: 140, minHeight: 24,
          }}
        />
        <button type="button" aria-label="Send" disabled={!canSend}
          onClick={() => { if (canSend && onSubmit) onSubmit(); }}
          style={{
            width: 40, height: 40, borderRadius: 13, flex: '0 0 auto', border: 'none',
            display: 'grid', placeItems: 'center', cursor: canSend ? 'pointer' : 'not-allowed',
            background: canSend ? 'linear-gradient(150deg, var(--iris), var(--iris-deep))' : 'var(--bg-sunken)',
            boxShadow: canSend ? 'var(--shadow-brand), inset 0 1px 0 rgba(255,255,255,.22)' : 'none',
            transition: 'all var(--dur-fast) var(--spring)',
          }}>
          <Icon name="send" size={18} color={canSend ? '#fff' : 'var(--text-muted)'} />
        </button>
      </div>
      <div style={{
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        marginTop: 9, padding: '0 4px', fontSize: 'var(--fs-micro)', color: 'var(--text-faint)',
      }}>
        <span style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <kbd style={kbd}>↵</kbd> to send <span style={{ opacity: .5 }}>·</span> <kbd style={kbd}>⇧↵</kbd> new line
        </span>
        <span style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <span style={{ width: 5, height: 5, borderRadius: '50%', background: 'var(--brand-grad)' }} />
          DUX can make mistakes — double-check important results.
        </span>
      </div>
    </div>
  );
}

const kbd = {
  fontFamily: 'var(--font-mono)', fontSize: 10, background: 'var(--surface-2)',
  border: '1px solid var(--border-strong)', borderRadius: 5, padding: '1px 5px',
  color: 'var(--text-secondary)',
};
