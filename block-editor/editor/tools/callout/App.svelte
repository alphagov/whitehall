<script>
  export const getData = () => ({
    content,
    calloutType,
  });

  export const setData = (data) => {
    if (data.content) content = data.content;
    if (data.calloutType) calloutType = data.calloutType;
  };

  let content;

  let calloutType = 'information';

  $: calloutClass = {
    example: 'example',
    warning: 'help-notice',
    information: 'info-notice',
  }[calloutType];
</script>

<div class={calloutClass}>
  <p contenteditable="true" bind:innerHTML={content} />
</div>

<style>
  p {
    outline: none;
  }

  /* contenteditable adds 'b' tag instead of 'strong' */
  :global(.govspeak .example b) {
    display: block;
  }
</style>
