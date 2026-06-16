import React from 'react';

export interface BadgeProps {
  children?: React.ReactNode;
  /** Color tone */
  tone?: 'neutral' | 'iris' | 'cyan' | 'ok' | 'pending' | 'err';
  /** Use mono (tabular) font — good for counts */
  mono?: boolean;
  style?: React.CSSProperties;
}

/** Small count / label chip. */
export function Badge(props: BadgeProps): JSX.Element;
