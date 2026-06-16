import React from 'react';

/**
 * BrandAvatar — the DUX assistant identity chip: the DX monogram inside a
 * rounded square with a faint brand-gradient ring. Theme-aware (the mark
 * inverts to white in dark theme via the `data-theme` attribute upstream).
 *
 * `markLight` / `markWhite` should point at the DX mark PNGs. Defaults assume
 * the design-system asset paths relative to a UI-kit page.
 */
export function BrandAvatar({
  size = 34,
  markLight = '../../assets/dux-mark.png',
  markWhite = '../../assets/dux-mark-white.png',
  ring = true,
  style = {},
}) {
  const radius = Math.round(size * 0.29);
  return (
    <span
      style={{
        position: 'relative', display: 'grid', placeItems: 'center',
        width: size, height: size, borderRadius: radius, flex: '0 0 auto',
        background: 'var(--avatar-bg)', border: '1px solid var(--border-strong)',
        boxShadow: 'var(--inset-hi)', overflow: 'hidden', ...style,
      }}
    >
      <img src={markLight} alt="DUX" data-mark="light"
        style={{ width: '62%', height: 'auto', objectFit: 'contain', display: 'var(--mark-light-display, block)' }} />
      <img src={markWhite} alt="" data-mark="white"
        style={{ width: '62%', height: 'auto', objectFit: 'contain', position: 'absolute', display: 'var(--mark-white-display, none)' }} />
      {ring && (
        <span aria-hidden="true" style={{
          position: 'absolute', inset: 0, borderRadius: 'inherit', padding: 1,
          background: 'var(--brand-grad)', opacity: .45, pointerEvents: 'none',
          WebkitMask: 'linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0)',
          WebkitMaskComposite: 'xor', maskComposite: 'exclude',
        }} />
      )}
    </span>
  );
}
