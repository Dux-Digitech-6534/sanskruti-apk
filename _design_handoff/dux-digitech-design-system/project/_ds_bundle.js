/* @ds-bundle: {"format":3,"namespace":"DUXDigitechDesignSystem_a3a609","components":[{"name":"BrandAvatar","sourcePath":"components/brand/BrandAvatar.jsx"},{"name":"Icon","sourcePath":"components/brand/Icon.jsx"},{"name":"ICON_NAMES","sourcePath":"components/brand/Icon.jsx"},{"name":"Badge","sourcePath":"components/core/Badge.jsx"},{"name":"Button","sourcePath":"components/core/Button.jsx"},{"name":"Card","sourcePath":"components/core/Card.jsx"},{"name":"CardMeta","sourcePath":"components/core/Card.jsx"},{"name":"IconButton","sourcePath":"components/core/IconButton.jsx"},{"name":"FilterPill","sourcePath":"components/feedback/FilterPill.jsx"},{"name":"FilterBar","sourcePath":"components/feedback/FilterPill.jsx"},{"name":"StatusTag","sourcePath":"components/feedback/StatusTag.jsx"},{"name":"ThinkingIndicator","sourcePath":"components/feedback/ThinkingIndicator.jsx"},{"name":"ThinkingKeyframes","sourcePath":"components/feedback/ThinkingIndicator.jsx"},{"name":"Composer","sourcePath":"components/forms/Composer.jsx"},{"name":"Input","sourcePath":"components/forms/Input.jsx"}],"sourceHashes":{"components/brand/BrandAvatar.jsx":"f4761600702e","components/brand/Icon.jsx":"113651d45d16","components/core/Badge.jsx":"c852dab78726","components/core/Button.jsx":"cc1d1f5e58bc","components/core/Card.jsx":"2ef83aedf455","components/core/IconButton.jsx":"cef4d7f321a4","components/feedback/FilterPill.jsx":"5ebb9a90fafe","components/feedback/StatusTag.jsx":"90cd26877334","components/feedback/ThinkingIndicator.jsx":"0953f83adf47","components/forms/Composer.jsx":"3b16ceb7e9fb","components/forms/Input.jsx":"1561123977ca"},"inlinedExternals":[],"unexposedExports":[]} */

(() => {

const __ds_ns = (window.DUXDigitechDesignSystem_a3a609 = window.DUXDigitechDesignSystem_a3a609 || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// components/brand/BrandAvatar.jsx
try { (() => {
/**
 * BrandAvatar — the DUX assistant identity chip: the DX monogram inside a
 * rounded square with a faint brand-gradient ring. Theme-aware (the mark
 * inverts to white in dark theme via the `data-theme` attribute upstream).
 *
 * `markLight` / `markWhite` should point at the DX mark PNGs. Defaults assume
 * the design-system asset paths relative to a UI-kit page.
 */
function BrandAvatar({
  size = 34,
  markLight = '../../assets/dux-mark.png',
  markWhite = '../../assets/dux-mark-white.png',
  ring = true,
  style = {}
}) {
  const radius = Math.round(size * 0.29);
  return /*#__PURE__*/React.createElement("span", {
    style: {
      position: 'relative',
      display: 'grid',
      placeItems: 'center',
      width: size,
      height: size,
      borderRadius: radius,
      flex: '0 0 auto',
      background: 'var(--avatar-bg)',
      border: '1px solid var(--border-strong)',
      boxShadow: 'var(--inset-hi)',
      overflow: 'hidden',
      ...style
    }
  }, /*#__PURE__*/React.createElement("img", {
    src: markLight,
    alt: "DUX",
    "data-mark": "light",
    style: {
      width: '62%',
      height: 'auto',
      objectFit: 'contain',
      display: 'var(--mark-light-display, block)'
    }
  }), /*#__PURE__*/React.createElement("img", {
    src: markWhite,
    alt: "",
    "data-mark": "white",
    style: {
      width: '62%',
      height: 'auto',
      objectFit: 'contain',
      position: 'absolute',
      display: 'var(--mark-white-display, none)'
    }
  }), ring && /*#__PURE__*/React.createElement("span", {
    "aria-hidden": "true",
    style: {
      position: 'absolute',
      inset: 0,
      borderRadius: 'inherit',
      padding: 1,
      background: 'var(--brand-grad)',
      opacity: .45,
      pointerEvents: 'none',
      WebkitMask: 'linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0)',
      WebkitMaskComposite: 'xor',
      maskComposite: 'exclude'
    }
  }));
}
Object.assign(__ds_scope, { BrandAvatar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/brand/BrandAvatar.jsx", error: String((e && e.message) || e) }); }

// components/brand/Icon.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
// DUX thin-stroke icon set — see Icon.prompt.md
/**
 * DUX thin-stroke icon set — ported verbatim from the production chat surface
 * (icons.jsx). 24×24 viewBox, 1.7 stroke, round caps/joins, currentColor.
 * Size via the `size` prop (px) or font-size; color follows `color`.
 */
const PATHS = {
  filter: '<path d="M3 5h18l-7 8v6l-4-2v-4z"/>',
  clock: '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
  truck: '<path d="M3 7h11v8H3z"/><path d="M14 9h4l3 3v3h-7"/><circle cx="7" cy="17" r="1.6"/><circle cx="17" cy="17" r="1.6"/>',
  building: '<path d="M5 21V5a1 1 0 0 1 1-1h8a1 1 0 0 1 1 1v16"/><path d="M15 9h3a1 1 0 0 1 1 1v11"/><path d="M9 8h2M9 12h2M9 16h2"/><path d="M3 21h18"/>',
  rupee: '<path d="M7 5h10M7 9h10M16 5c0 4-3.5 5-6.5 5L16 19"/><path d="M7 9h3"/>',
  calendar: '<rect x="3.5" y="5" width="17" height="16" rx="2"/><path d="M3.5 10h17M8 3v4M16 3v4"/>',
  box: '<path d="M21 8 12 3 3 8v8l9 5 9-5z"/><path d="M3 8l9 5 9-5M12 13v8"/>',
  search: '<circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/>',
  sparkle: '<path d="M12 3l1.6 4.8L18 9.4l-4.4 1.6L12 16l-1.6-5L6 9.4l4.4-1.6z"/><path d="M19 14l.7 2.1L22 17l-2.3.9L19 20l-.7-2.1L16 17l2.3-.9z"/>',
  send: '<path d="M12 19V5"/><path d="m5 12 7-7 7 7"/>',
  plus: '<path d="M12 5v14"/><path d="M5 12h14"/>',
  moon: '<path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z"/>',
  sun: '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M2 12h2M20 12h2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M19.1 4.9l-1.4 1.4M6.3 17.7l-1.4 1.4"/>',
  chevron: '<path d="m15 18-6-6 6-6"/>',
  layers: '<path d="m12 3 9 5-9 5-9-5z"/><path d="m3 13 9 5 9-5"/>',
  refresh: '<path d="M3 12a9 9 0 0 1 15-6.7L21 8"/><path d="M21 4v4h-4"/><path d="M21 12a9 9 0 0 1-15 6.7L3 16"/><path d="M3 20v-4h4"/>',
  check: '<path d="M4 12.5 9 17.5 20 6.5"/>',
  close: '<path d="M6 6l12 12M18 6 6 18"/>',
  copy: '<rect x="9" y="9" width="11" height="11" rx="2"/><path d="M5 15V5a2 2 0 0 1 2-2h8"/>',
  download: '<path d="M12 4v11"/><path d="m7 11 5 5 5-5"/><path d="M5 20h14"/>',
  user: '<circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/>'
};
function Icon({
  name = 'sparkle',
  size = 18,
  color = 'currentColor',
  strokeWidth = 1.7,
  style = {},
  ...rest
}) {
  const d = PATHS[name] || PATHS.sparkle;
  return /*#__PURE__*/React.createElement("svg", _extends({
    viewBox: "0 0 24 24",
    width: size,
    height: size,
    fill: "none",
    stroke: color,
    strokeWidth: strokeWidth,
    strokeLinecap: "round",
    strokeLinejoin: "round",
    style: {
      display: 'block',
      flex: '0 0 auto',
      ...style
    },
    dangerouslySetInnerHTML: {
      __html: d
    }
  }, rest));
}
const ICON_NAMES = Object.keys(PATHS);
Object.assign(__ds_scope, { Icon, ICON_NAMES });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/brand/Icon.jsx", error: String((e && e.message) || e) }); }

// components/core/Badge.jsx
try { (() => {
/**
 * Badge — small count / label chip. Tones map to brand + status colors.
 * For document workflow states use <StatusTag>; for query filters use
 * <FilterPill>. This is the generic neutral/brand chip.
 */
function Badge({
  children,
  tone = 'neutral',
  mono = false,
  style = {}
}) {
  const tones = {
    neutral: {
      color: 'var(--text-secondary)',
      bg: 'var(--bg-sunken)'
    },
    iris: {
      color: 'var(--iris)',
      bg: 'var(--iris-tint)'
    },
    cyan: {
      color: 'var(--cyan)',
      bg: 'var(--cyan-tint)'
    },
    ok: {
      color: 'var(--ok)',
      bg: 'var(--ok-bg)'
    },
    pending: {
      color: 'var(--pending)',
      bg: 'var(--pending-bg)'
    },
    err: {
      color: 'var(--err)',
      bg: 'var(--err-bg)'
    }
  }[tone];
  return /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 5,
      fontSize: 'var(--fs-micro)',
      fontWeight: 'var(--fw-semibold)',
      lineHeight: 1,
      padding: '4px 9px',
      borderRadius: 'var(--r-pill)',
      color: tones.color,
      background: tones.bg,
      fontFamily: mono ? 'var(--font-mono)' : 'var(--font-ui)',
      fontVariantNumeric: mono ? 'tabular-nums' : 'normal',
      ...style
    }
  }, children);
}
Object.assign(__ds_scope, { Badge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Badge.jsx", error: String((e && e.message) || e) }); }

// components/core/Button.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * Button — DUX action control.
 * variants: primary (iris gradient), secondary (hairline pill), ghost (text),
 *           danger (error-tinted). Sizes sm | md | lg. Optional leading icon.
 * Pills by default (matches the "New search" control); set rounded="md" for a
 * squared corner.
 */
function Button({
  children,
  variant = 'secondary',
  size = 'md',
  icon,
  iconRight,
  rounded = 'pill',
  disabled = false,
  onClick,
  style = {},
  ...rest
}) {
  const sizes = {
    sm: {
      pad: '6px 12px',
      fs: 12,
      ic: 13,
      gap: 6,
      h: 30
    },
    md: {
      pad: '8px 16px',
      fs: 13,
      ic: 15,
      gap: 7,
      h: 38
    },
    lg: {
      pad: '11px 20px',
      fs: 14,
      ic: 17,
      gap: 8,
      h: 46
    }
  }[size];
  const radius = rounded === 'pill' ? 'var(--r-pill)' : `var(--r-${rounded})`;
  const base = {
    display: 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: sizes.gap,
    height: sizes.h,
    padding: sizes.pad,
    fontSize: sizes.fs,
    fontFamily: 'var(--font-ui)',
    fontWeight: 'var(--fw-medium)',
    lineHeight: 1,
    borderRadius: radius,
    cursor: disabled ? 'not-allowed' : 'pointer',
    transition: 'all var(--dur-base) var(--spring)',
    whiteSpace: 'nowrap',
    border: '1px solid transparent',
    opacity: disabled ? .45 : 1,
    ...style
  };
  const variants = {
    primary: {
      color: 'var(--text-on-brand)',
      background: 'linear-gradient(150deg, var(--iris), var(--iris-deep))',
      boxShadow: 'var(--shadow-brand), inset 0 1px 0 rgba(255,255,255,.22)'
    },
    secondary: {
      color: 'var(--text-primary)',
      background: 'var(--bg-surface)',
      borderColor: 'var(--border-strong)',
      boxShadow: 'var(--inset-hi)'
    },
    ghost: {
      color: 'var(--text-secondary)',
      background: 'transparent'
    },
    danger: {
      color: 'var(--err)',
      background: 'var(--err-bg)',
      borderColor: 'var(--err-bg)'
    }
  };
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    disabled: disabled,
    onClick: onClick,
    style: {
      ...base,
      ...variants[variant]
    },
    onMouseEnter: e => {
      if (disabled) return;
      e.currentTarget.style.transform = 'translateY(-1px)';
      if (variant === 'secondary') {
        e.currentTarget.style.borderColor = 'var(--iris)';
        e.currentTarget.style.color = 'var(--iris)';
      }
      if (variant === 'ghost') e.currentTarget.style.color = 'var(--iris)';
    },
    onMouseLeave: e => {
      e.currentTarget.style.transform = 'none';
      if (variant === 'secondary') {
        e.currentTarget.style.borderColor = 'var(--border-strong)';
        e.currentTarget.style.color = 'var(--text-primary)';
      }
      if (variant === 'ghost') e.currentTarget.style.color = 'var(--text-secondary)';
    }
  }, rest), icon && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: sizes.ic
  }), children, iconRight && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: iconRight,
    size: sizes.ic
  }));
}
Object.assign(__ds_scope, { Button });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Button.jsx", error: String((e && e.message) || e) }); }

// components/core/Card.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * Card — the DUX result-card chrome: hairline border, soft ambient shadow,
 * inset highlight, generous radius. Optional brand-gradient top accent line
 * (the "filter bar" treatment). Compose meta rows / tables inside.
 */
function Card({
  children,
  accent = false,
  padding = 0,
  style = {},
  ...rest
}) {
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      position: 'relative',
      background: 'var(--bg-card)',
      border: '1px solid var(--border-subtle)',
      borderRadius: 'var(--r-lg)',
      boxShadow: 'var(--shadow-card), var(--inset-hi)',
      overflow: 'hidden',
      padding,
      ...style
    }
  }, rest), accent && /*#__PURE__*/React.createElement("span", {
    "aria-hidden": "true",
    style: {
      position: 'absolute',
      left: 0,
      right: 0,
      top: 0,
      height: 2,
      background: 'var(--brand-grad)',
      opacity: .6
    }
  }), children);
}

/** Meta strip — count / summary row that sits below a card's header. */
function CardMeta({
  left,
  right,
  style = {}
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '11px 16px',
      borderBottom: '1px solid var(--border-subtle)',
      background: 'var(--meta-bg)',
      fontSize: 'var(--fs-meta)',
      ...style
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--text-secondary)'
    }
  }, left), /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--text-muted)'
    }
  }, right));
}
Object.assign(__ds_scope, { Card, CardMeta });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Card.jsx", error: String((e && e.message) || e) }); }

// components/core/IconButton.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * IconButton — square icon-only control (header actions, toolbars).
 * Matches the chat surface's 34px hairline icon button; hovers to iris.
 * Use `variant="send"` for the gradient primary action (composer send).
 */
function IconButton({
  icon = 'plus',
  size = 34,
  variant = 'default',
  title,
  disabled = false,
  onClick,
  style = {},
  ...rest
}) {
  const radius = Math.round(size * 0.3);
  const glyph = Math.round(size * 0.47);
  const base = {
    display: 'grid',
    placeItems: 'center',
    width: size,
    height: size,
    borderRadius: radius,
    flex: '0 0 auto',
    cursor: disabled ? 'not-allowed' : 'pointer',
    border: '1px solid transparent',
    transition: 'all var(--dur-base) var(--spring)',
    opacity: disabled ? .4 : 1,
    ...style
  };
  const variants = {
    default: {
      background: 'var(--bg-surface)',
      borderColor: 'var(--border-strong)',
      color: 'var(--text-secondary)'
    },
    ghost: {
      background: 'transparent',
      color: 'var(--text-secondary)'
    },
    send: {
      background: 'linear-gradient(150deg, var(--iris), var(--iris-deep))',
      color: 'var(--text-on-brand)',
      boxShadow: 'var(--shadow-brand), inset 0 1px 0 rgba(255,255,255,.22)'
    }
  };
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    title: title,
    "aria-label": title || icon,
    disabled: disabled,
    onClick: onClick,
    style: {
      ...base,
      ...variants[variant]
    },
    onMouseEnter: e => {
      if (disabled) return;
      e.currentTarget.style.transform = 'translateY(-1px)';
      if (variant === 'default' || variant === 'ghost') {
        e.currentTarget.style.color = 'var(--iris)';
        e.currentTarget.style.borderColor = 'var(--iris)';
      }
    },
    onMouseLeave: e => {
      e.currentTarget.style.transform = 'none';
      if (variant === 'default') {
        e.currentTarget.style.color = 'var(--text-secondary)';
        e.currentTarget.style.borderColor = 'var(--border-strong)';
      }
      if (variant === 'ghost') {
        e.currentTarget.style.color = 'var(--text-secondary)';
      }
    }
  }, rest), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: glyph
  }));
}
Object.assign(__ds_scope, { IconButton });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/IconButton.jsx", error: String((e && e.message) || e) }); }

// components/feedback/FilterPill.jsx
try { (() => {
/**
 * FilterPill — the transparency chip that shows WHICH filter produced a result
 * ("Supplier: Bhandari", "Amount: > ₹50,000"). Icon tile + key + value. The
 * `tint` colors the icon tile; numeric values render in mono cyan.
 */
const TINTS = {
  iris: {
    color: 'var(--iris)',
    bg: 'var(--iris-tint)'
  },
  cyan: {
    color: 'var(--cyan)',
    bg: 'var(--cyan-tint)'
  },
  pending: {
    color: 'var(--pending)',
    bg: 'var(--pending-bg)'
  },
  ok: {
    color: 'var(--ok)',
    bg: 'var(--ok-bg)'
  },
  mut: {
    color: 'var(--text-secondary)',
    bg: 'var(--bg-sunken)'
  }
};
function FilterPill({
  icon = 'filter',
  label,
  value,
  tint = 'mut',
  num = false,
  style = {}
}) {
  const t = TINTS[tint] || TINTS.mut;
  return /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 7,
      padding: '6px 11px 6px 9px',
      borderRadius: 'var(--r-sm)',
      fontSize: 12.5,
      background: 'var(--pill-bg)',
      border: '1px solid var(--border-strong)',
      color: 'var(--text-primary)',
      ...style
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 22,
      height: 22,
      borderRadius: 6,
      display: 'grid',
      placeItems: 'center',
      flex: '0 0 auto',
      color: t.color,
      background: t.bg
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 13
  })), label && /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--text-muted)'
    }
  }, label, ":"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontWeight: 'var(--fw-medium)',
      fontFamily: num ? 'var(--font-mono)' : 'inherit',
      fontVariantNumeric: num ? 'tabular-nums' : 'normal',
      color: num ? 'var(--cyan)' : 'inherit'
    }
  }, value));
}

/** Labelled bar that wraps a row of FilterPills (the "Showing results for" strip). */
function FilterBar({
  children,
  style = {}
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '14px 16px 13px',
      position: 'relative',
      ...style
    }
  }, /*#__PURE__*/React.createElement("span", {
    "aria-hidden": "true",
    style: {
      position: 'absolute',
      left: 0,
      right: 0,
      top: 0,
      height: 2,
      background: 'var(--brand-grad)',
      opacity: .6
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 7,
      marginBottom: 11,
      fontSize: 'var(--fs-label)',
      letterSpacing: 'var(--ls-label)',
      textTransform: 'uppercase',
      color: 'var(--text-muted)',
      fontWeight: 'var(--fw-semibold)'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "filter",
    size: 13
  }), " Showing results for"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexWrap: 'wrap',
      gap: 8
    }
  }, children));
}
Object.assign(__ds_scope, { FilterPill, FilterBar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/FilterPill.jsx", error: String((e && e.message) || e) }); }

// components/feedback/StatusTag.jsx
try { (() => {
/**
 * StatusTag — document workflow state chip with a leading dot. Auto-maps common
 * ERPNext statuses to a tone, or pass `tone` explicitly. Mirrors the chat
 * surface's statusTagClass() logic.
 */
const TONES = {
  approved: {
    color: 'var(--ok)',
    bg: 'var(--ok-bg)'
  },
  pending: {
    color: 'var(--pending)',
    bg: 'var(--pending-bg)'
  },
  draft: {
    color: 'var(--text-secondary)',
    bg: 'var(--bg-sunken)'
  }
};
function autoTone(label) {
  const s = String(label || '').toLowerCase();
  if (/draft|cancel|return|hold|rejected/.test(s)) return 'draft';
  if (/paid|approved|completed|closed|fulfilled|delivered|received and billed|active/.test(s)) return 'approved';
  return 'pending';
}
function StatusTag({
  children,
  label,
  tone,
  style = {}
}) {
  const text = children ?? label;
  const t = TONES[tone || autoTone(text)];
  return /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 6,
      fontSize: 'var(--fs-micro)',
      fontWeight: 'var(--fw-medium)',
      lineHeight: 1,
      padding: '3px 9px',
      borderRadius: 'var(--r-pill)',
      whiteSpace: 'nowrap',
      color: t.color,
      background: t.bg,
      ...style
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 5,
      height: 5,
      borderRadius: '50%',
      background: 'currentColor'
    }
  }), text);
}
Object.assign(__ds_scope, { StatusTag });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/StatusTag.jsx", error: String((e && e.message) || e) }); }

// components/feedback/ThinkingIndicator.jsx
try { (() => {
/**
 * ThinkingIndicator — the working state shown while DUX queries records.
 * A card with a sweeping brand-gradient top bar, a pulsing brand mark, a
 * shimmering headline and a sub-line. Inject @keyframes once via <ThinkingKeyframes/>.
 */
function ThinkingIndicator({
  head = 'Reading your operations data…',
  sub = 'Parsing intent · matching filters · querying records',
  markLight,
  markWhite,
  style = {}
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 13,
      alignItems: 'flex-start',
      ...style
    }
  }, /*#__PURE__*/React.createElement(ThinkingKeyframes, null), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: '1 1 auto',
      position: 'relative',
      overflow: 'hidden',
      padding: '15px 17px',
      borderRadius: 'var(--r-md)',
      background: 'var(--surface-2)',
      border: '1px solid var(--border-subtle)',
      boxShadow: 'var(--shadow-card)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    "aria-hidden": "true",
    style: {
      position: 'absolute',
      top: 0,
      left: 0,
      right: 0,
      height: 2,
      background: 'var(--brand-grad)',
      opacity: .85
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 13
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      animation: 'duxBob 2.4s var(--ease) infinite',
      display: 'grid'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.BrandAvatar, {
    size: 40,
    markLight: markLight,
    markWhite: markWhite
  })), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 13.5,
      fontWeight: 'var(--fw-medium)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      background: 'linear-gradient(90deg, var(--fg-3) 30%, var(--fg-1) 50%, var(--fg-3) 70%)',
      backgroundSize: '200% 100%',
      WebkitBackgroundClip: 'text',
      backgroundClip: 'text',
      color: 'transparent',
      animation: 'duxShim 2.2s linear infinite'
    }
  }, head)), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--text-muted)',
      marginTop: 5
    }
  }, sub)))));
}
function ThinkingKeyframes() {
  return /*#__PURE__*/React.createElement("style", null, `
      @keyframes duxBob { 0%,100%{transform:translateY(0);} 50%{transform:translateY(-3px);} }
      @keyframes duxShim { to { background-position:-200% 0; } }
    `);
}
Object.assign(__ds_scope, { ThinkingIndicator, ThinkingKeyframes });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/ThinkingIndicator.jsx", error: String((e && e.message) || e) }); }

// components/forms/Composer.jsx
try { (() => {
/**
 * Composer — the signature DUX "ask bar": a sparkle lead glyph, an auto-growing
 * textarea, and the iris-gradient send button. Focus reveals a brand-gradient
 * border halo. ⏎ submits, ⇧⏎ inserts a newline.
 */
function Composer({
  value,
  onChange,
  onSubmit,
  placeholder = 'Ask about purchase orders, suppliers, amounts…',
  disabled = false,
  style = {}
}) {
  const [focus, setFocus] = React.useState(false);
  const ref = React.useRef(null);
  const grow = () => {
    const el = ref.current;
    if (!el) return;
    el.style.height = 'auto';
    el.style.height = Math.min(el.scrollHeight, 140) + 'px';
  };
  React.useEffect(grow, [value]);
  const canSend = !!(value && value.trim()) && !disabled;
  return /*#__PURE__*/React.createElement("div", {
    style: style
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      display: 'flex',
      alignItems: 'flex-end',
      gap: 10,
      padding: '11px 11px 11px 16px',
      borderRadius: 'var(--r-xl)',
      background: 'var(--bg-surface)',
      border: `1px solid ${focus ? 'transparent' : 'var(--border-strong)'}`,
      boxShadow: 'var(--shadow-pop), var(--inset-hi)',
      transition: 'border-color var(--dur-slow) var(--ease)'
    }
  }, focus && /*#__PURE__*/React.createElement("span", {
    "aria-hidden": "true",
    style: {
      position: 'absolute',
      inset: -1,
      borderRadius: 'inherit',
      padding: 1,
      background: 'var(--brand-grad)',
      opacity: .9,
      pointerEvents: 'none',
      WebkitMask: 'linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0)',
      WebkitMaskComposite: 'xor',
      maskComposite: 'exclude'
    }
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: '0 0 auto',
      width: 22,
      height: 22,
      marginBottom: 6,
      display: 'grid',
      placeItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "sparkle",
    size: 18,
    color: "var(--iris)"
  })), /*#__PURE__*/React.createElement("textarea", {
    ref: ref,
    rows: 1,
    value: value,
    placeholder: placeholder,
    disabled: disabled,
    onChange: onChange,
    onFocus: () => setFocus(true),
    onBlur: () => setFocus(false),
    onKeyDown: e => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        if (canSend && onSubmit) onSubmit();
      }
    },
    style: {
      flex: '1 1 auto',
      resize: 'none',
      border: 'none',
      outline: 'none',
      background: 'transparent',
      fontFamily: 'var(--font-ui)',
      fontSize: 'var(--fs-body)',
      lineHeight: 1.5,
      color: 'var(--text-primary)',
      padding: '6px 0',
      maxHeight: 140,
      minHeight: 24
    }
  }), /*#__PURE__*/React.createElement("button", {
    type: "button",
    "aria-label": "Send",
    disabled: !canSend,
    onClick: () => {
      if (canSend && onSubmit) onSubmit();
    },
    style: {
      width: 40,
      height: 40,
      borderRadius: 13,
      flex: '0 0 auto',
      border: 'none',
      display: 'grid',
      placeItems: 'center',
      cursor: canSend ? 'pointer' : 'not-allowed',
      background: canSend ? 'linear-gradient(150deg, var(--iris), var(--iris-deep))' : 'var(--bg-sunken)',
      boxShadow: canSend ? 'var(--shadow-brand), inset 0 1px 0 rgba(255,255,255,.22)' : 'none',
      transition: 'all var(--dur-fast) var(--spring)'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "send",
    size: 18,
    color: canSend ? '#fff' : 'var(--text-muted)'
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      marginTop: 9,
      padding: '0 4px',
      fontSize: 'var(--fs-micro)',
      color: 'var(--text-faint)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 6
    }
  }, /*#__PURE__*/React.createElement("kbd", {
    style: kbd
  }, "\u21B5"), " to send ", /*#__PURE__*/React.createElement("span", {
    style: {
      opacity: .5
    }
  }, "\xB7"), " ", /*#__PURE__*/React.createElement("kbd", {
    style: kbd
  }, "\u21E7\u21B5"), " new line"), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 6
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 5,
      height: 5,
      borderRadius: '50%',
      background: 'var(--brand-grad)'
    }
  }), "DUX can make mistakes \u2014 double-check important results.")));
}
const kbd = {
  fontFamily: 'var(--font-mono)',
  fontSize: 10,
  background: 'var(--surface-2)',
  border: '1px solid var(--border-strong)',
  borderRadius: 5,
  padding: '1px 5px',
  color: 'var(--text-secondary)'
};
Object.assign(__ds_scope, { Composer });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Composer.jsx", error: String((e && e.message) || e) }); }

// components/forms/Input.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * Input — single-line text field. Hairline border, focus lifts to an iris
 * ring. Optional leading icon.
 */
function Input({
  icon,
  value,
  onChange,
  placeholder,
  type = 'text',
  disabled = false,
  style = {},
  ...rest
}) {
  const [focus, setFocus] = React.useState(false);
  const Icon = icon;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 9,
      padding: '0 13px',
      height: 42,
      borderRadius: 'var(--r-md)',
      background: 'var(--bg-surface)',
      border: `1px solid ${focus ? 'var(--iris)' : 'var(--border-strong)'}`,
      boxShadow: focus ? '0 0 0 3px var(--iris-tint)' : 'var(--inset-hi)',
      transition: 'border-color var(--dur-base) var(--ease), box-shadow var(--dur-base) var(--ease)',
      opacity: disabled ? .5 : 1,
      ...style
    }
  }, icon && /*#__PURE__*/React.createElement("span", {
    style: {
      color: focus ? 'var(--iris)' : 'var(--text-muted)',
      display: 'grid'
    }
  }, icon), /*#__PURE__*/React.createElement("input", _extends({
    type: type,
    value: value,
    onChange: onChange,
    placeholder: placeholder,
    disabled: disabled,
    onFocus: () => setFocus(true),
    onBlur: () => setFocus(false),
    style: {
      flex: '1 1 auto',
      border: 'none',
      outline: 'none',
      background: 'transparent',
      fontFamily: 'var(--font-ui)',
      fontSize: 'var(--fs-body)',
      color: 'var(--text-primary)',
      minWidth: 0
    }
  }, rest)));
}
Object.assign(__ds_scope, { Input });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Input.jsx", error: String((e && e.message) || e) }); }

__ds_ns.BrandAvatar = __ds_scope.BrandAvatar;

__ds_ns.Icon = __ds_scope.Icon;

__ds_ns.ICON_NAMES = __ds_scope.ICON_NAMES;

__ds_ns.Badge = __ds_scope.Badge;

__ds_ns.Button = __ds_scope.Button;

__ds_ns.Card = __ds_scope.Card;

__ds_ns.CardMeta = __ds_scope.CardMeta;

__ds_ns.IconButton = __ds_scope.IconButton;

__ds_ns.FilterPill = __ds_scope.FilterPill;

__ds_ns.FilterBar = __ds_scope.FilterBar;

__ds_ns.StatusTag = __ds_scope.StatusTag;

__ds_ns.ThinkingIndicator = __ds_scope.ThinkingIndicator;

__ds_ns.ThinkingKeyframes = __ds_scope.ThinkingKeyframes;

__ds_ns.Composer = __ds_scope.Composer;

__ds_ns.Input = __ds_scope.Input;

})();
