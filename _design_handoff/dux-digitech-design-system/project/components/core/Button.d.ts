import React from 'react';
import { IconName } from '../brand/Icon';

/**
 * Props for the DUX action button.
 * @startingPoint section="Core" subtitle="Primary / secondary / ghost buttons" viewport="700x180"
 */
export interface ButtonProps {
  children?: React.ReactNode;
  /** Visual style */
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger';
  /** Control size */
  size?: 'sm' | 'md' | 'lg';
  /** Leading icon name */
  icon?: IconName;
  /** Trailing icon name */
  iconRight?: IconName;
  /** Corner style — pill (default) or a radius token key */
  rounded?: 'pill' | 'sm' | 'md' | 'lg';
  disabled?: boolean;
  onClick?: (e: React.MouseEvent) => void;
  style?: React.CSSProperties;
}

/** DUX action button. Primary = iris gradient; secondary = hairline pill. */
export function Button(props: ButtonProps): JSX.Element;
