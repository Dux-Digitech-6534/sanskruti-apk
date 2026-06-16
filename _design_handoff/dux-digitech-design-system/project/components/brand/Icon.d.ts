import React from 'react';

export type IconName =
  | 'filter' | 'clock' | 'truck' | 'building' | 'rupee' | 'calendar' | 'box'
  | 'search' | 'sparkle' | 'send' | 'plus' | 'moon' | 'sun' | 'chevron'
  | 'layers' | 'refresh' | 'check' | 'close' | 'copy' | 'download' | 'user';

export interface IconProps {
  /** Icon glyph name */
  name?: IconName;
  /** Pixel size (width & height) */
  size?: number;
  /** Stroke color — defaults to currentColor */
  color?: string;
  /** SVG stroke width */
  strokeWidth?: number;
  style?: React.CSSProperties;
}

/** DUX thin-stroke line icon (24×24, 1.7 stroke). */
export function Icon(props: IconProps): JSX.Element;

export const ICON_NAMES: IconName[];
