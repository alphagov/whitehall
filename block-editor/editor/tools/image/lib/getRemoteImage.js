const getRemoteImage = async (url) => {
  const response = await fetch(url);
  const contentType = response.headers.get('Content-Type');

  if (!contentType.startsWith('image/')) {
    throw new Error(`Invalid content type: ${contentType}`);
  }

  return response.blob();
};

export default getRemoteImage;
