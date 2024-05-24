import { Component, OnDestroy, OnInit } from '@angular/core';
import {
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonButton, IonFooter, IonLabel, IonIcon, IonList, IonItem } from '@ionic/angular/standalone';
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
  folderOpenOutline
} from 'ionicons/icons';
import { Filesystem } from '@capacitor/filesystem';
import { ScreenOrientation } from '@capacitor/screen-orientation';

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
  standalone: true,
  imports: [IonItem, IonList, IonIcon, IonLabel, IonFooter, CommonModule, IonButton, IonHeader, IonToolbar, IonTitle, IonContent],
})
export class HomePage implements OnInit, OnDestroy {
  videos: { url: string, metadata?: { size: string; duration: string } }[] = [];
  initialized = false;
  isRecording = false;
  showVideos = false;
  durationIntervalId!: any;
  duration = "00:00";
  constructor() {
    addIcons({
      videocam,
      stopCircleOutline,
      cameraReverseOutline,
      folderOutline,
      folderOpenOutline
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
      quality: VideoRecorderQuality.MAX_480P
    });
    this.initialized = true;
  }

  async startRecording() {
    await this.initialise();
    await VideoRecorder.startRecording();
    this.isRecording = true;
    this.showVideos = false;

    // lock screen orientation when recording
    const orientation = await ScreenOrientation.orientation()
    await ScreenOrientation.lock({ orientation: orientation.type });

    this.durationIntervalId = setInterval(() => {
      VideoRecorder.getDuration().then((res) => {
        this.duration = this.numberToTimeString(res.value);
      });
    }, 1000);
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

  async destroyCamera() {
    await VideoRecorder.destroy();
    this.initialized = false;
  }
}
