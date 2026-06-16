import React from 'react';

// DUX thin-stroke icon set — see Icon.prompt.md
/**
 * DUX thin-stroke icon set — ported verbatim from the production chat surface
 * (icons.jsx). 24×24 viewBox, 1.7 stroke, round caps/joins, currentColor.
 * Size via the `size` prop (px) or font-size; color follows `color`.
 */
const PATHS = {
  filter:   '<path d="M3 5h18l-7 8v6l-4-2v-4z"/>',
  clock:    '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
  truck:    '<path d="M3 7h11v8H3z"/><path d="M14 9h4l3 3v3h-7"/><circle cx="7" cy="17" r="1.6"/><circle cx="17" cy="17" r="1.6"/>',
  building: '<path d="M5 21V5a1 1 0 0 1 1-1h8a1 1 0 0 1 1 1v16"/><path d="M15 9h3a1 1 0 0 1 1 1v11"/><path d="M9 8h2M9 12h2M9 16h2"/><path d="M3 21h18"/>',
  rupee:    '<path d="M7 5h10M7 9h10M16 5c0 4-3.5 5-6.5 5L16 19"/><path d="M7 9h3"/>',
  calendar: '<rect x="3.5" y="5" width="17" height="16" rx="2"/><path d="M3.5 10h17M8 3v4M16 3v4"/>',
  box:      '<path d="M21 8 12 3 3 8v8l9 5 9-5z"/><path d="M3 8l9 5 9-5M12 13v8"/>',
  search:   '<circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/>',
  sparkle:  '<path d="M12 3l1.6 4.8L18 9.4l-4.4 1.6L12 16l-1.6-5L6 9.4l4.4-1.6z"/><path d="M19 14l.7 2.1L22 17l-2.3.9L19 20l-.7-2.1L16 17l2.3-.9z"/>',
  send:     '<path d="M12 19V5"/><path d="m5 12 7-7 7 7"/>',
  plus:     '<path d="M12 5v14"/><path d="M5 12h14"/>',
  moon:     '<path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z"/>',
  sun:      '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M2 12h2M20 12h2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M19.1 4.9l-1.4 1.4M6.3 17.7l-1.4 1.4"/>',
  chevron:  '<path d="m15 18-6-6 6-6"/>',
  layers:   '<path d="m12 3 9 5-9 5-9-5z"/><path d="m3 13 9 5 9-5"/>',
  refresh:  '<path d="M3 12a9 9 0 0 1 15-6.7L21 8"/><path d="M21 4v4h-4"/><path d="M21 12a9 9 0 0 1-15 6.7L3 16"/><path d="M3 20v-4h4"/>',
  check:    '<path d="M4 12.5 9 17.5 20 6.5"/>',
  close:    '<path d="M6 6l12 12M18 6 6 18"/>',
  copy:     '<rect x="9" y="9" width="11" height="11" rx="2"/><path d="M5 15V5a2 2 0 0 1 2-2h8"/>',
  download: '<path d="M12 4v11"/><path d="m7 11 5 5 5-5"/><path d="M5 20h14"/>',
  user:     '<circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/>',
};

export function Icon({ name = 'sparkle', size = 18, color = 'currentColor', strokeWidth = 1.7, style = {}, ...rest }) {
  const d = PATHS[name] || PATHS.sparkle;
  return (
    <svg
      viewBox="0 0 24 24" width={size} height={size} fill="none"
      stroke={color} strokeWidth={strokeWidth} strokeLinecap="round" strokeLinejoin="round"
      style={{ display: 'block', flex: '0 0 auto', ...style }}
      dangerouslySetInnerHTML={{ __html: d }} {...rest}
    />
  );
}

export const ICON_NAMES = Object.keys(PATHS);
