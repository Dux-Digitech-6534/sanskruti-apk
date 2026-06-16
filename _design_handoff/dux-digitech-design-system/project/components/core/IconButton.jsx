import React from 'react';
import { Icon } from '../brand/Icon.jsx';

/**
 * IconButton — square icon-only control (header actions, toolbars).
 * Matches the chat surface's 34px hairline icon button; hovers to iris.
 * Use `variant="send"` for the gradient primary action (composer send).
 */
export function IconButton({
  icon = 'plus', size = 34, variant = 'default', title, disabled = false,
  onClick, style = {}, ...rest
}) {
  const radius = Math.round(size * 0.3);
  const glyph = Math.round(size * 0.47);
  const base = {
    display: 'grid', placeItems: 'center', width: size, height: size,
    borderRadius: radius, flex: '0 0 auto', cursor: disabled ? 'not-allowed' : 'pointer',
    border: '1px solid transparent', transition: 'all var(--dur-base) var(--spring)',
    opacity: disabled ? .4 : 1, ...style,
  };
  const variants = {
    default: { background: 'var(--bg-surface)', borderColor: 'var(--border-strong)', color: 'var(--text-secondary)' },
    ghost:   { background: 'transparent', color: 'var(--text-secondary)' },
    send:    {
      background: 'linear-gradient(150deg, var(--iris), var(--iris-deep))',
      color: 'var(--text-on-brand)',
      boxShadow: 'var(--shadow-brand), inset 0 1px 0 rgba(255,255,255,.22)',
    },
  };
  return (
    <button type="button" title={title} aria-label={title || icon} disabled={disabled} onClick={onClick}
      style={{ ...base, ...variants[variant] }}
      onMouseEnter={(e) => { if (disabled) return; e.currentTarget.style.transform = 'translateY(-1px)'; if (variant === 'default' || variant === 'ghost') { e.currentTarget.style.color = 'var(--iris)'; e.currentTarget.style.borderColor = 'var(--iris)'; } }}
      onMouseLeave={(e) => { e.currentTarget.style.transform = 'none'; if (variant === 'default') { e.currentTarget.style.color = 'var(--text-secondary)'; e.currentTarget.style.borderColor = 'var(--border-strong)'; } if (variant === 'ghost') { e.currentTarget.style.color = 'var(--text-secondary)'; } }}
      {...rest}
    >
      <Icon name={icon} size={glyph} />
    </button>
  );
}
