import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'io.ionic.starter',
  appName: 'example',
  webDir: 'www',
  // This is required for the @capacitor-community/video-recorder plugin to work on iOS
  backgroundColor: '#ff000000',
};

export default config;
