import React from 'react';

export interface StatusTagProps {
  /** Status label (also accepts `label`) */
  children?: React.ReactNode;
  label?: string;
  /** Force a tone; omit to auto-map from the label text */
  tone?: 'approved' | 'pending' | 'draft';
  style?: React.CSSProperties;
}

/** Document workflow-state chip with leading dot; auto-tones from the label. */
export function StatusTag(props: StatusTagProps): JSX.Element;
