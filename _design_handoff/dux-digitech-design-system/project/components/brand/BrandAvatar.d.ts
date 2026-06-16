import React from 'react';

export interface BrandAvatarProps {
  /** Square size in px */
  size?: number;
  /** Path to the dark DX mark (shown in light theme) */
  markLight?: string;
  /** Path to the white DX mark (shown in dark theme) */
  markWhite?: string;
  /** Show the brand-gradient ring */
  ring?: boolean;
  style?: React.CSSProperties;
}

/** DUX monogram identity chip with brand-gradient ring. */
export function BrandAvatar(props: BrandAvatarProps): JSX.Element;
