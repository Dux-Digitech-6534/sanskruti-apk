import React from 'react';
import { IconName } from '../brand/Icon';

export interface FilterPillProps {
  /** Icon-tile glyph */
  icon?: IconName;
  /** Field label (e.g. "Supplier") */
  label?: React.ReactNode;
  /** Value (e.g. "Bhandari" or "> ₹50,000") */
  value?: React.ReactNode;
  /** Icon-tile tint */
  tint?: 'iris' | 'cyan' | 'pending' | 'ok' | 'mut';
  /** Render the value in mono cyan (amounts / numbers) */
  num?: boolean;
  style?: React.CSSProperties;
}

export interface FilterBarProps {
  children?: React.ReactNode;
  style?: React.CSSProperties;
}

/** Transparency chip showing which filter produced a result. */
export function FilterPill(props: FilterPillProps): JSX.Element;
/** "Showing results for" labelled strip wrapping FilterPills. */
export function FilterBar(props: FilterBarProps): JSX.Element;
