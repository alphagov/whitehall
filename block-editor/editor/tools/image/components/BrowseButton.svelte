<script>
  import ajax from '@codexteam/ajax';
  import { IconPicture } from '@codexteam/icons';
  import { ALLOWED_TYPES } from '../../image';

  const accept = ALLOWED_TYPES.join(', ');

  let files;
  export let file;
  $: if (files?.length > 0) file = files[0];
</script>

<label class="cdx-button">
  {@html IconPicture}
  Select an Image
  <input type="file" {accept} bind:files />
</label>

<style>
  input {
    display: none;
  }

  label {
    font-weight: normal;
  }

  .cdx-button {
    display: flex;
    align-items: center;
    justify-content: center;
  }
</style>
