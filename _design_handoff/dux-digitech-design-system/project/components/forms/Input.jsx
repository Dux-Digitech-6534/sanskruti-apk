import React from 'react';

/**
 * Input — single-line text field. Hairline border, focus lifts to an iris
 * ring. Optional leading icon.
 */
export function Input({ icon, value, onChange, placeholder, type = 'text', disabled = false, style = {}, ...rest }) {
  const [focus, setFocus] = React.useState(false);
  const Icon = icon;
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 9,
      padding: '0 13px', height: 42, borderRadius: 'var(--r-md)',
      background: 'var(--bg-surface)',
      border: `1px solid ${focus ? 'var(--iris)' : 'var(--border-strong)'}`,
      boxShadow: focus ? '0 0 0 3px var(--iris-tint)' : 'var(--inset-hi)',
      transition: 'border-color var(--dur-base) var(--ease), box-shadow var(--dur-base) var(--ease)',
      opacity: disabled ? .5 : 1, ...style,
    }}>
      {icon && <span style={{ color: focus ? 'var(--iris)' : 'var(--text-muted)', display: 'grid' }}>{icon}</span>}
      <input
        type={type} value={value} onChange={onChange} placeholder={placeholder} disabled={disabled}
        onFocus={() => setFocus(true)} onBlur={() => setFocus(false)}
        style={{
          flex: '1 1 auto', border: 'none', outline: 'none', background: 'transparent',
          fontFamily: 'var(--font-ui)', fontSize: 'var(--fs-body)', color: 'var(--text-primary)',
          minWidth: 0,
        }}
        {...rest}
      />
    </div>
  );
}
