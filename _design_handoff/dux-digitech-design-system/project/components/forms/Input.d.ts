import React from 'react';

export interface InputProps {
  /** Leading icon element (e.g. <Icon name="search" size={16} />) */
  icon?: React.ReactNode;
  value?: string;
  onChange?: (e: React.ChangeEvent<HTMLInputElement>) => void;
  placeholder?: string;
  type?: string;
  disabled?: boolean;
  style?: React.CSSProperties;
}

/** Single-line text field with iris focus ring. */
export function Input(props: InputProps): JSX.Element;
