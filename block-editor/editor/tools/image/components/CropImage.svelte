<script>
  import 'cropperjs/dist/cropper.css';
  import Cropper from 'cropperjs';
  import { onDestroy } from 'svelte';

  export let file, width, height;

  let cropper, img, src;

  $: src = URL.createObjectURL(file);

  const initCropper = () => {
    cropper = new Cropper(img, {
      aspectRatio: width / height,
      viewMode: 1,
      highlight: false,
      autoCropArea: 1,
      zoomable: false,
      movable: false,
      scalable: false,
      rotatable: false,
      dragMode: 'none',
    });
  };

  const crop = () => {
    const cropped = cropper.getCroppedCanvas({
      width,
      height,
      imageSmoothingEnabled: true,
      imageSmoothingQuality: 'high',
    });

    const options = [file.type];
    if (file.type == 'image/jpeg') {
      options.push(0.95); // JPEG compression level
    }

    cropped.toBlob((blob) => {
      file = blob;
    }, ...options);
  };

  onDestroy(() => {
    if (src) URL.revokeObjectURL(src);
    if (cropper) cropper.destroy();
  });
</script>

<div class="cropper">
  <img {src} bind:this={img} on:load={initCropper} alt={file.name} />
</div>

{#if cropper}
  <button class="cdx-button" on:click={crop}>Crop</button>
{/if}

<style>
  img {
    display: block;
    max-width: 100%;
    height: auto;
  }

  .cropper {
    margin-bottom: 10px;
  }
</style>
