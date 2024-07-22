import type { PluginListenerHandle } from '@capacitor/core';

export interface VideoRecorderPlugin {
  initialize(options?: VideoRecorderOptions): Promise<void>;
  destroy(): Promise<void>;
  flipCamera(): Promise<void>;
  addPreviewFrameConfig(config: VideoRecorderPreviewFrame): Promise<void>;
  editPreviewFrameConfig(config: VideoRecorderPreviewFrame): Promise<void>;
  switchToPreviewFrame(options: { id: string }): Promise<void>;
  showPreviewFrame(config: { position: number; quality: number }): Promise<void>;
  hidePreviewFrame(): Promise<void>;
  startRecording(): Promise<void>;
  stopRecording(): Promise<{
    videoUrl: string;
  }>;
  getDuration(): Promise<{
    value: number;
  }>;
  addListener(
    eventName: 'onVolumeInput',
    listenerFunc: (event: { value: number }) => void,
  ): Promise<PluginListenerHandle>;
}
export interface VideoRecorderPreviewFrame {
  id: string;
  stackPosition?: 'front' | 'back';
  x?: number;
  y?: number;
  width?: number | 'fill';
  height?: number | 'fill';
  borderRadius?: number;
  dropShadow?: {
    opacity?: number;
    radius?: number;
    color?: string;
  };
}

export interface VideoRecorderErrors {
  CAMERA_RESTRICTED: string;
  CAMERA_DENIED: string;
  MICROPHONE_RESTRICTED: string;
  MICROPHONE_DENIED: string;
};
export interface VideoRecorderOptions {
  camera?: VideoRecorderCamera;
  quality?: VideoRecorderQuality;
  autoShow?: boolean;
  previewFrames?: VideoRecorderPreviewFrame[];
}

export enum VideoRecorderCamera {
  FRONT = 0,
  BACK = 1,
}

export enum VideoRecorderQuality {
  MAX_480P = 0,
  MAX_720P = 1,
  MAX_1080P = 2,
  MAX_2160P = 3,
  HIGHEST = 4,
  LOWEST = 5,
  QVGA = 6,
}
