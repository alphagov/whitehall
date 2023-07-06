export default file => new Promise((resolve, reject) => {
  const img = document.createElement('img');
  img.src = URL.createObjectURL(file);
  img.onload = () => {
    URL.revokeObjectURL(img.src);
    resolve({
      width: img.naturalWidth,
      height: img.naturalHeight,
    });
  };
  img.onerror = reject;
});
