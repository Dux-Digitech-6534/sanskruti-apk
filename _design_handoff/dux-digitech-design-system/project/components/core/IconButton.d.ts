import React from 'react';
import { IconName } from '../brand/Icon';

export interface IconButtonProps {
  /** Glyph name */
  icon?: IconName;
  /** Square size in px */
  size?: number;
  /** default (hairline) · ghost · send (iris gradient) */
  variant?: 'default' | 'ghost' | 'send';
  /** Tooltip / aria-label */
  title?: string;
  disabled?: boolean;
  onClick?: (e: React.MouseEvent) => void;
  style?: React.CSSProperties;
}

/** Square icon-only control. */
export function IconButton(props: IconButtonProps): JSX.Element;
