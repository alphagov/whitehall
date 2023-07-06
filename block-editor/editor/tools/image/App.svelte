<script>
  /*

  App states:

  1. Empty
    - show "browse" button

  2. Crop image (optional)
    - if image dimensions are wrong, load cropping tool
    - click 'crop' or 'cancel'

  3. Uploading image
    - show progress spinner
  
  4. Uploaded
    - show image from server
    - update data object with details from server

  */

  import BrowseButton from './components/BrowseButton.svelte';
  import CropImage from './components/CropImage.svelte';
  import getImageDimensions from './lib/getImageDimensions';

  const TARGET_WIDTH = 960;
  const TARGET_HEIGHT = 640;

  const isTargetSize = ({ width, height }) => {
    return width == TARGET_WIDTH && height == TARGET_HEIGHT;
  };

  export const getData = () => ({
    caption: caption ?? null,
    file: state == 'correct_size' ? file : null,
  });

  export const setData = (data) => {
    if (data.file) file = data.file;
    if (data.caption) caption = data.caption;
  };

  let caption, file, state, src, originalFile;

  const imageNeedsCropping = async (file) => {
    if (file.type == 'image/svg+xml') return false;
    const dimensions = await getImageDimensions(file);
    return !isTargetSize(dimensions);
  };

  $: {
    if (!file) {
      state = 'empty';
    } else if (file !== originalFile) {
      originalFile = file;
      state = 'checking_dimensions';
      imageNeedsCropping(file).then((crop) => {
        state = crop ? 'needs_cropping' : 'correct_size';
      });
    }
  }

  $: if (file) src = URL.createObjectURL(file);
</script>

<div>
  {#if state == 'empty'}
    <!-- 1. Select an image -->
    <BrowseButton bind:file />
  {:else if state == 'checking_dimensions'}
    <!-- 2. Check image dimensions -->
    <div class="cdx-loader" />
  {:else if state == 'needs_cropping'}
    <!-- 3. Image needs cropping/resizing -->
    <CropImage bind:file width={TARGET_WIDTH} height={TARGET_HEIGHT} />
  {:else if state == 'correct_size'}
    <!-- 4. Image is correct size -->
    <img {src} alt class="preview" />
    <input
      type="text"
      class="cdx-input"
      placeholder="Caption"
      bind:value={caption}
    />
  {/if}
</div>

<style>
  .preview {
    max-width: 100%;
    height: auto;
    display: block;
    border-radius: 3px;
    margin-bottom: 10px;
  }

  .cdx-loader {
    min-height: 200px;
  }

  .cdx-input {
    font-size: inherit;
    font-family: inherit;
  }
</style>
