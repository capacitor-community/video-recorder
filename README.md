<p align="center"><br><img src="https://user-images.githubusercontent.com/236501/85893648-1c92e880-b7a8-11ea-926d-95355b8175c7.png" width="128" height="128" /></p>
<h3 align="center">VIDEO RECORDER</h3>
<p align="center"><strong><code>@capacitor-community/video-recorder</code></strong></p>
<br>
<p align="center" style="font-size:50px;color:red"><strong>CAPACITOR 7</strong></p><br>
<br>

capacitor plugin to record video

## Install

Capacitor v7

```bash
npm install @capacitor-community/video-recorder
npx cap sync
```

Capacitor v6

```bash
npm install @capacitor-community/video-recorder@6
npx cap sync
```

Capacitor v5

```bash
npm install @capacitor-community/video-recorder@5
npx cap sync
```

To ensure the Android lib is downloadable when building the app, you can add the following to the repositories section of your project's build.gradle file:

```gradle
repositories {
  google()
  mavenCentral()
  maven {
    url "https://jitpack.io"
  }
}
```

#### Platform Support

- iOS
- Android

> On a web browser, we will fake the behavior to allow for easier development.

## Example Usage

### Initializing Camera

In order to initialize the camera feed (**note**: you are not recording at this point), you must first specify a config to the video recorder.

> Note: To overlay your web UI on-top of the camera output, you must use stackPosition: back and make all layers of your app transparent so that the camera can be seen under the webview.

There are 2 changes needed to make the webview transparent on Android and iOS:

```scss
// in the scss file of your page
ion-content {
  --background: transparent;
}
```

```ts
// in the capacitor.config.ts
{
  'backgroundColor: '#ff000000', // this is needed mainly on iOS
}
```

Next in your app:

```typescript
import { VideoRecorderCamera, VideoRecorderPreviewFrame } from '@capacitor-community/video-recorder';

const { VideoRecorder } = Plugins;

const config: VideoRecorderPreviewFrame = {
    id: 'video-record',
    stackPosition: 'back', // 'front' overlays your app', 'back' places behind your app.
    width: 'fill',
    height: 'fill',
    x: 0,
    y: 0,
    borderRadius: 0
};
await VideoRecorder.initialize({
    camera: VideoRecorderCamera.FRONT, // Can use BACK
    previewFrames: [config]
});
```

### Recording

Starts recording against the capture device.

```typescript
VideoRecorder.startRecording();
```

### Stop Recording / Getting Result

Stops the capture device and returns the path of the local video file.

``` typescript
const res = await VideoRecorder.stopRecording();
// The video url is the local file path location of the video output.
return res.videoUrl;
```

### Destroying Camera

Used to disconnect from the capture device and remove any native UI layers that exist.

```typescript
VideoRecorder.destroy();
```

### Demo App

The demo app can be found in the Example folder of this repo

## API

<docgen-index>

* [`initialize(...)`](#initialize)
* [`destroy()`](#destroy)
* [`flipCamera()`](#flipcamera)
* [`toggleFlash()`](#toggleflash)
* [`enableFlash()`](#enableflash)
* [`disableFlash()`](#disableflash)
* [`isFlashAvailable()`](#isflashavailable)
* [`isFlashEnabled()`](#isflashenabled)
* [`addPreviewFrameConfig(...)`](#addpreviewframeconfig)
* [`editPreviewFrameConfig(...)`](#editpreviewframeconfig)
* [`switchToPreviewFrame(...)`](#switchtopreviewframe)
* [`showPreviewFrame(...)`](#showpreviewframe)
* [`hidePreviewFrame()`](#hidepreviewframe)
* [`startRecording()`](#startrecording)
* [`stopRecording()`](#stoprecording)
* [`getDuration()`](#getduration)
* [`addListener('onVolumeInput', ...)`](#addlisteneronvolumeinput-)
* [Interfaces](#interfaces)
* [Enums](#enums)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### initialize(...)

```typescript
initialize(options?: VideoRecorderOptions | undefined) => Promise<void>
```

| Param         | Type                                                                  |
| ------------- | --------------------------------------------------------------------- |
| **`options`** | <code><a href="#videorecorderoptions">VideoRecorderOptions</a></code> |

--------------------


### destroy()

```typescript
destroy() => Promise<void>
```

--------------------


### flipCamera()

```typescript
flipCamera() => Promise<void>
```

--------------------


### toggleFlash()

```typescript
toggleFlash() => Promise<void>
```

--------------------


### enableFlash()

```typescript
enableFlash() => Promise<void>
```

--------------------


### disableFlash()

```typescript
disableFlash() => Promise<void>
```

--------------------


### isFlashAvailable()

```typescript
isFlashAvailable() => Promise<{ isAvailable: boolean; }>
```

**Returns:** <code>Promise&lt;{ isAvailable: boolean; }&gt;</code>

--------------------


### isFlashEnabled()

```typescript
isFlashEnabled() => Promise<{ isEnabled: boolean; }>
```

**Returns:** <code>Promise&lt;{ isEnabled: boolean; }&gt;</code>

--------------------


### addPreviewFrameConfig(...)

```typescript
addPreviewFrameConfig(config: VideoRecorderPreviewFrame) => Promise<void>
```

| Param        | Type                                                                            |
| ------------ | ------------------------------------------------------------------------------- |
| **`config`** | <code><a href="#videorecorderpreviewframe">VideoRecorderPreviewFrame</a></code> |

--------------------


### editPreviewFrameConfig(...)

```typescript
editPreviewFrameConfig(config: VideoRecorderPreviewFrame) => Promise<void>
```

| Param        | Type                                                                            |
| ------------ | ------------------------------------------------------------------------------- |
| **`config`** | <code><a href="#videorecorderpreviewframe">VideoRecorderPreviewFrame</a></code> |

--------------------


### switchToPreviewFrame(...)

```typescript
switchToPreviewFrame(options: { id: string; }) => Promise<void>
```

| Param         | Type                         |
| ------------- | ---------------------------- |
| **`options`** | <code>{ id: string; }</code> |

--------------------


### showPreviewFrame(...)

```typescript
showPreviewFrame(config: { position: number; quality: number; }) => Promise<void>
```

| Param        | Type                                                |
| ------------ | --------------------------------------------------- |
| **`config`** | <code>{ position: number; quality: number; }</code> |

--------------------


### hidePreviewFrame()

```typescript
hidePreviewFrame() => Promise<void>
```

--------------------


### startRecording()

```typescript
startRecording() => Promise<void>
```

--------------------


### stopRecording()

```typescript
stopRecording() => Promise<{ videoUrl: string; }>
```

**Returns:** <code>Promise&lt;{ videoUrl: string; }&gt;</code>

--------------------


### getDuration()

```typescript
getDuration() => Promise<{ value: number; }>
```

**Returns:** <code>Promise&lt;{ value: number; }&gt;</code>

--------------------


### addListener('onVolumeInput', ...)

```typescript
addListener(eventName: 'onVolumeInput', listenerFunc: (event: { value: number; }) => void) => Promise<PluginListenerHandle>
```

| Param              | Type                                                |
| ------------------ | --------------------------------------------------- |
| **`eventName`**    | <code>'onVolumeInput'</code>                        |
| **`listenerFunc`** | <code>(event: { value: number; }) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### Interfaces


#### VideoRecorderOptions

| Prop                | Type                                                                  | Description                    | Default              |
| ------------------- | --------------------------------------------------------------------- | ------------------------------ | -------------------- |
| **`camera`**        | <code><a href="#videorecordercamera">VideoRecorderCamera</a></code>   |                                |                      |
| **`quality`**       | <code><a href="#videorecorderquality">VideoRecorderQuality</a></code> |                                |                      |
| **`autoShow`**      | <code>boolean</code>                                                  |                                |                      |
| **`previewFrames`** | <code>VideoRecorderPreviewFrame[]</code>                              |                                |                      |
| **`videoBitrate`**  | <code>number</code>                                                   | The default bitrate is 4.5Mbps | <code>4500000</code> |


#### VideoRecorderPreviewFrame

| Prop                | Type                                                                |
| ------------------- | ------------------------------------------------------------------- |
| **`id`**            | <code>string</code>                                                 |
| **`stackPosition`** | <code>'front' \| 'back'</code>                                      |
| **`x`**             | <code>number</code>                                                 |
| **`y`**             | <code>number</code>                                                 |
| **`width`**         | <code>number \| 'fill'</code>                                       |
| **`height`**        | <code>number \| 'fill'</code>                                       |
| **`borderRadius`**  | <code>number</code>                                                 |
| **`dropShadow`**    | <code>{ opacity?: number; radius?: number; color?: string; }</code> |


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |


### Enums


#### VideoRecorderCamera

| Members     | Value          |
| ----------- | -------------- |
| **`FRONT`** | <code>0</code> |
| **`BACK`**  | <code>1</code> |


#### VideoRecorderQuality

| Members         | Value          |
| --------------- | -------------- |
| **`MAX_480P`**  | <code>0</code> |
| **`MAX_720P`**  | <code>1</code> |
| **`MAX_1080P`** | <code>2</code> |
| **`MAX_2160P`** | <code>3</code> |
| **`HIGHEST`**   | <code>4</code> |
| **`LOWEST`**    | <code>5</code> |
| **`QVGA`**      | <code>6</code> |

</docgen-api>

## Dependencies

The Android code is using `triniwiz/FancyCamera` v1.2.4 (<https://github.com/triniwiz/fancycamera>)

The iOS code is implemented using AVFoundation

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<p align="center">
  <a href="https://github.com/sbannigan" title="sbannigan"><img src="https://github.com/sbannigan.png?size=100" width="50" height="50" /></a>
  <a href="https://github.com/triniwiz" title="triniwiz"><img src="https://github.com/triniwiz.png?size=100" width="50" height="50" /></a>
  <a href="https://github.com/sean-perkins" title="sean-perkins"><img src="https://github.com/sean-perkins.png?size=100" width="50" height="50" /></a>
  <a href="https://github.com/shiv19" title="shiv19"><img src="https://github.com/shiv19.png?size=100" width="50" height="50" /></a>
</p>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
