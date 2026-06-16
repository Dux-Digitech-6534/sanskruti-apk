import React from 'react';

/**
 * Props for the signature DUX ask-bar composer.
 * @startingPoint section="Forms" subtitle="The DUX ask-bar composer" viewport="700x150"
 */
export interface ComposerProps {
  value?: string;
  onChange?: (e: React.ChangeEvent<HTMLTextAreaElement>) => void;
  /** Fired on ⏎ (not ⇧⏎) or send-button click when there is trimmed text */
  onSubmit?: () => void;
  placeholder?: string;
  disabled?: boolean;
  style?: React.CSSProperties;
}

/** The signature DUX "ask bar" — sparkle glyph, auto-grow textarea, iris send button. */
export function Composer(props: ComposerProps): JSX.Element;
