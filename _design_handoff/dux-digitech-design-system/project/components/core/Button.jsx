import React from 'react';
import { Icon } from '../brand/Icon.jsx';

/**
 * Button — DUX action control.
 * variants: primary (iris gradient), secondary (hairline pill), ghost (text),
 *           danger (error-tinted). Sizes sm | md | lg. Optional leading icon.
 * Pills by default (matches the "New search" control); set rounded="md" for a
 * squared corner.
 */
export function Button({
  children, variant = 'secondary', size = 'md', icon, iconRight,
  rounded = 'pill', disabled = false, onClick, style = {}, ...rest
}) {
  const sizes = {
    sm: { pad: '6px 12px', fs: 12, ic: 13, gap: 6, h: 30 },
    md: { pad: '8px 16px', fs: 13, ic: 15, gap: 7, h: 38 },
    lg: { pad: '11px 20px', fs: 14, ic: 17, gap: 8, h: 46 },
  }[size];
  const radius = rounded === 'pill' ? 'var(--r-pill)' : `var(--r-${rounded})`;

  const base = {
    display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
    gap: sizes.gap, height: sizes.h, padding: sizes.pad, fontSize: sizes.fs,
    fontFamily: 'var(--font-ui)', fontWeight: 'var(--fw-medium)', lineHeight: 1,
    borderRadius: radius, cursor: disabled ? 'not-allowed' : 'pointer',
    transition: 'all var(--dur-base) var(--spring)', whiteSpace: 'nowrap',
    border: '1px solid transparent', opacity: disabled ? .45 : 1, ...style,
  };
  const variants = {
    primary: {
      color: 'var(--text-on-brand)',
      background: 'linear-gradient(150deg, var(--iris), var(--iris-deep))',
      boxShadow: 'var(--shadow-brand), inset 0 1px 0 rgba(255,255,255,.22)',
    },
    secondary: {
      color: 'var(--text-primary)', background: 'var(--bg-surface)',
      borderColor: 'var(--border-strong)', boxShadow: 'var(--inset-hi)',
    },
    ghost: { color: 'var(--text-secondary)', background: 'transparent' },
    danger: { color: 'var(--err)', background: 'var(--err-bg)', borderColor: 'var(--err-bg)' },
  };

  return (
    <button type="button" disabled={disabled} onClick={onClick}
      style={{ ...base, ...variants[variant] }}
      onMouseEnter={(e) => { if (disabled) return; e.currentTarget.style.transform = 'translateY(-1px)'; if (variant === 'secondary') { e.currentTarget.style.borderColor = 'var(--iris)'; e.currentTarget.style.color = 'var(--iris)'; } if (variant === 'ghost') e.currentTarget.style.color = 'var(--iris)'; }}
      onMouseLeave={(e) => { e.currentTarget.style.transform = 'none'; if (variant === 'secondary') { e.currentTarget.style.borderColor = 'var(--border-strong)'; e.currentTarget.style.color = 'var(--text-primary)'; } if (variant === 'ghost') e.currentTarget.style.color = 'var(--text-secondary)'; }}
      {...rest}
    >
      {icon && <Icon name={icon} size={sizes.ic} />}
      {children}
      {iconRight && <Icon name={iconRight} size={sizes.ic} />}
    </button>
  );
}
