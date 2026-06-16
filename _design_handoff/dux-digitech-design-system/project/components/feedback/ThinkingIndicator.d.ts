import React from 'react';

export interface ThinkingIndicatorProps {
  /** Shimmering headline */
  head?: string;
  /** Muted sub-line */
  sub?: string;
  /** DX mark paths (forwarded to BrandAvatar) */
  markLight?: string;
  markWhite?: string;
  style?: React.CSSProperties;
}

/** Working / loading state card with sweeping brand bar and pulsing mark. */
export function ThinkingIndicator(props: ThinkingIndicatorProps): JSX.Element;
/** Injects the @keyframes used by ThinkingIndicator (rendered automatically). */
export function ThinkingKeyframes(): JSX.Element;
