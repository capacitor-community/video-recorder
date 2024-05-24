# y

capacitor plugin to record video

## Install

```bash
npm install y
npx cap sync
```

## API

<docgen-index>

* [`initialize(...)`](#initialize)
* [`destroy()`](#destroy)
* [`flipCamera()`](#flipcamera)
* [`addPreviewFrameConfig(...)`](#addpreviewframeconfig)
* [`editPreviewFrameConfig(...)`](#editpreviewframeconfig)
* [`switchToPreviewFrame(...)`](#switchtopreviewframe)
* [`showPreviewFrame()`](#showpreviewframe)
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


### showPreviewFrame()

```typescript
showPreviewFrame() => Promise<void>
```

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
addListener(eventName: 'onVolumeInput', listenerFunc: (event: { value: number; }) => void) => PluginListenerHandle
```

| Param              | Type                                                |
| ------------------ | --------------------------------------------------- |
| **`eventName`**    | <code>'onVolumeInput'</code>                        |
| **`listenerFunc`** | <code>(event: { value: number; }) =&gt; void</code> |

**Returns:** <code><a href="#pluginlistenerhandle">PluginListenerHandle</a></code>

--------------------


### Interfaces


#### VideoRecorderOptions

| Prop                | Type                                                                  |
| ------------------- | --------------------------------------------------------------------- |
| **`camera`**        | <code><a href="#videorecordercamera">VideoRecorderCamera</a></code>   |
| **`quality`**       | <code><a href="#videorecorderquality">VideoRecorderQuality</a></code> |
| **`autoShow`**      | <code>boolean</code>                                                  |
| **`previewFrames`** | <code>VideoRecorderPreviewFrame[]</code>                              |


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
