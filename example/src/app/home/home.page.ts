import { Component, OnDestroy, OnInit, inject } from '@angular/core';
import {
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonButton, IonFooter, IonLabel, IonIcon, IonList, IonItem, IonPopover,
  Platform} from '@ionic/angular/standalone';
import {
  VideoRecorder,
  VideoRecorderCamera,
  VideoRecorderPreviewFrame,
  VideoRecorderQuality,
} from '@capacitor-community/video-recorder';
import { CommonModule } from '@angular/common';
import { addIcons } from 'ionicons';
import {
  videocam,
  stopCircleOutline,
  cameraReverseOutline,
  folderOutline,
  folderOpenOutline,
  settingsOutline
} from 'ionicons/icons';
import { Filesystem } from '@capacitor/filesystem';
import { ScreenOrientation } from '@capacitor/screen-orientation';

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
  standalone: true,
  imports: [IonPopover, IonItem, IonList, IonIcon, IonLabel, IonFooter, CommonModule, IonButton, IonHeader, IonToolbar, IonTitle, IonContent],
})
export class HomePage implements OnInit, OnDestroy {
  private platform = inject(Platform);
  videos: { url: string, metadata?: { size: string; duration: string } }[] = [];
  initialized = false;
  isRecording = false;
  showVideos = false;
  durationIntervalId!: any;
  duration = "00:00";
  quality = VideoRecorderQuality.MAX_720P;

  videoQualityMap = [
    { command: VideoRecorderQuality.HIGHEST, label: 'Highest' },
    { command: VideoRecorderQuality.MAX_2160P, label: '2160P' },
    { command: VideoRecorderQuality.MAX_1080P, label: '1080p' },
    { command: VideoRecorderQuality.MAX_720P, label: '720p' },
    { command: VideoRecorderQuality.MAX_480P, label: '480p' },
    { command: VideoRecorderQuality.QVGA, label: 'QVGA' },
    { command: VideoRecorderQuality.LOWEST, label: 'Lowest' },
  ]

  constructor() {
    addIcons({
      videocam,
      stopCircleOutline,
      cameraReverseOutline,
      folderOutline,
      folderOpenOutline,
      settingsOutline
    })
  }

  ngOnInit() {
    this.initialise();

    ScreenOrientation.removeAllListeners();
    ScreenOrientation.addListener('screenOrientationChange', async (res) => {
      if (this.initialized && !this.isRecording) {
        await this.destroyCamera();
        await this.initialise();
      }
    });
  }

  ngOnDestroy(): void {
    this.destroyCamera();

    ScreenOrientation.removeAllListeners();
  }

  private numberToTimeString(time: number) {
    const minutes = Math.floor(time / 60);
    const seconds = time % 60;
    return `${minutes < 10 ? '0' + minutes : minutes}:${seconds < 10 ? '0' + seconds : seconds}`;
  }

  private bytesToSize(bytes: number) {
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    if (bytes === 0) {
      return '0 Byte';
    }
    const i = Math.floor(Math.log(bytes) / Math.log(1024));
    return parseFloat((bytes / Math.pow(1024, i)).toFixed(2)) + ' ' + sizes[i];
  }

  async initialise() {
    const config: VideoRecorderPreviewFrame = {
      id: 'video-record',
      stackPosition: 'back',
      width: 'fill',
      height: 'fill',
      x: 0,
      y: 0,
      borderRadius: 0,
    };
    if (this.initialized) {
      return;
    }
    await VideoRecorder.initialize({
      camera: VideoRecorderCamera.BACK,
      previewFrames: [config],
      quality: this.quality,
      videoBitrate: 4500000,
    });

    if (this.platform.is('android')) {
      // Only used by Android
      await VideoRecorder.showPreviewFrame({
        position: 0, // 0:= - Back, 1:= - Front
        quality: this.quality
      });
    }

    this.initialized = true;
  }

  async startRecording() {
    try {
      await this.initialise();
      await VideoRecorder.startRecording();
      this.isRecording = true;
      this.showVideos = false;

      // lock screen orientation when recording
      const orientation = await ScreenOrientation.orientation();

      if (this.platform.is('ios')) {
        // On iOS the landscape-primary and landscape-secondary are flipped for some reason
        if (orientation.type === 'landscape-primary') {
          orientation.type = 'landscape-secondary'
        } else if (orientation.type === 'landscape-secondary') {
          orientation.type = 'landscape-primary'
        }
      }

      await ScreenOrientation.lock({ orientation: orientation.type });

      this.durationIntervalId = setInterval(() => {
        VideoRecorder.getDuration().then((res) => {
          this.duration = this.numberToTimeString(res.value);
        });
      }, 1000);
    } catch (error) {
      console.error(error);
    }
  }

  flipCamera() {
    VideoRecorder.flipCamera();
  }

  toggleVideos() {
    this.showVideos = !this.showVideos;
    if (this.showVideos) {
      this.destroyCamera();
    } else {
      this.initialise();
    }
  }

  async stopRecording() {
    const res = await VideoRecorder.stopRecording();
    clearInterval(this.durationIntervalId);
    this.duration = "00:00";
    this.isRecording = false;

    // unlock screen orientation after recording
    await ScreenOrientation.unlock();

    // The video url is the local file path location of the video output.
    // eg: http://192.168.1.252:8100/_capacitor_file_/storage/emulated/0/Android/data/io.ionic.starter/files/VID_20240524110208.mp4

    const filePath = 'file://' + res.videoUrl.split('_capacitor_file_')[1];
    const file = await Filesystem.stat({ path: filePath }).catch((err) => {
      console.error(err);
    });

    // file.ctime - file.mtime gives the duration in milliseconds
    // Convert it to human readable format
    let duration = '';
    if (file) {
      const durationInSeconds = Math.floor((file.mtime! / 1000) - (file.ctime! / 1000));
      duration = this.numberToTimeString(durationInSeconds);
    }

    this.videos.push({
      url: res.videoUrl,
      metadata: {
        size: file ? this.bytesToSize(file.size) : '',
        duration,
      }
    })
    this.toggleVideos();
  }

  async videoQualityChanged(quality: VideoRecorderQuality) {
    this.quality = quality;
    await this.destroyCamera();
    this.showVideos = false;
    await this.initialise();
  }

  async destroyCamera() {
    await VideoRecorder.destroy();
    this.initialized = false;
  }
}
