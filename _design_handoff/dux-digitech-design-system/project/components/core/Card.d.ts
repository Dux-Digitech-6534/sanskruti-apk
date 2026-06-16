import React from 'react';

export interface CardProps {
  children?: React.ReactNode;
  /** Show brand-gradient top accent line */
  accent?: boolean;
  /** Inner padding (number = px). Default 0 for table-style cards. */
  padding?: number | string;
  style?: React.CSSProperties;
}

export interface CardMetaProps {
  left?: React.ReactNode;
  right?: React.ReactNode;
  style?: React.CSSProperties;
}

/** Result-card chrome: hairline + ambient shadow + inset highlight. */
export function Card(props: CardProps): JSX.Element;
/** Count / summary strip for inside a Card. */
export function CardMeta(props: CardMetaProps): JSX.Element;
