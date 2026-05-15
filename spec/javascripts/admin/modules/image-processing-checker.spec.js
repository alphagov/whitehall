describe('GOVUK.Modules.ImageProcessingChecker', function () {
  let imagePreview

  const imageProcessingTimeout = 1
  const responseJSON = {
    image_data: {
      assets: [
        {
          variant: 'original',
          url: 'http://assets.gov.uk/media/960x640.png'
        },
        {
          variant: 's960',
          url: 'http://assets.gov.uk/media/s960_960x640.png'
        }
      ],
      all_assets_uploaded: true
    }
  }
  const notReadyJSON = JSON.parse(JSON.stringify(responseJSON))
  notReadyJSON.image_data.all_assets_uploaded = false

  const okResponse = new Response(JSON.stringify(responseJSON), {
    status: 200,
    statusText: 'OK'
  })
  const okNotReadyResponse = new Response(JSON.stringify(notReadyJSON), {
    status: 200,
    statusText: 'OK'
  })

  beforeEach(() => {
    imagePreview = document.createElement('div')
    imagePreview.dataset.module = 'image-processing-checker'
    imagePreview.dataset.imageLink = 'https://placeholder.com/image/1'
    imagePreview.dataset.timeoutDuration = imageProcessingTimeout

    imagePreview.innerHTML = `
      <template class="js-image-preview">
        <img src="" />
      </template>
      <div class="js-image-processing-status">
        <span class="js-image-processing-preview-tag">
          PROCESSING
        </span>
      </div>
      <template class="js-image-preview-failure">
        <span class="js-image-processing-failure-tag">
          FAILED
        </span>
      </template>
    `
    document.body.appendChild(imagePreview)
  })

  afterEach(() => imagePreview.remove())

  it('should replace the processing status with the original image', (done) => {
    spyOn(window, 'fetch').and.resolveTo(okResponse)
    // eslint-disable-next-line no-new
    new GOVUK.Modules.ImageProcessingChecker(imagePreview)

    expect(imagePreview.querySelector('img')).toBe(null)

    window.setTimeout(() => {
      expect(imagePreview.querySelector('img'))
      expect(imagePreview.querySelector('img').src).toBe(
        'http://assets.gov.uk/media/960x640.png'
      )
      done()
    }, imageProcessingTimeout * 2)
  })

  it('should replace the processing status with a specific image if `variant` specified', (done) => {
    imagePreview.dataset.variant = 's960'

    spyOn(window, 'fetch').and.resolveTo(okResponse)
    // eslint-disable-next-line no-new
    new GOVUK.Modules.ImageProcessingChecker(imagePreview)

    expect(imagePreview.querySelector('img')).toBe(null)

    window.setTimeout(() => {
      expect(imagePreview.querySelector('img'))
      expect(imagePreview.querySelector('img').src).toBe(
        'http://assets.gov.uk/media/s960_960x640.png'
      )
      done()
    }, imageProcessingTimeout * 2)
  })

  it('should replace the processing status with the image preview after multiple attempts', (done) => {
    let calls = 4

    const responder = () => {
      if (calls > 0) {
        calls -= 1
        return new Promise((resolve) => {
          resolve(okNotReadyResponse)
        })
      } else {
        return new Promise((resolve) => {
          resolve(okResponse)
        })
      }
    }

    spyOn(window, 'fetch').and.callFake(responder)

    // eslint-disable-next-line no-new
    new GOVUK.Modules.ImageProcessingChecker(imagePreview)

    expect(imagePreview.querySelector('img')).toBe(null)

    window.setTimeout(() => {
      expect(imagePreview.querySelector('img')).toBeTruthy()
      done()
    }, 100)
  })

  it('should render error if URL does not return 200', (done) => {
    const errorResponse = new Response(JSON.stringify(responseJSON), {
      status: 404,
      statusText: 'OK'
    })

    spyOn(window, 'fetch').and.resolveTo(errorResponse)
    // eslint-disable-next-line no-new
    new GOVUK.Modules.ImageProcessingChecker(imagePreview)

    expect(imagePreview.querySelector('img')).toBe(null)

    window.setTimeout(() => {
      expect(
        imagePreview.querySelector('.js-image-processing-failure-tag')
      ).toBeTruthy()
      done()
    }, 100)
  })

  it('should render error if image is not ready in time', (done) => {
    spyOn(window, 'fetch').and.resolveTo(okNotReadyResponse)
    // eslint-disable-next-line no-new
    new GOVUK.Modules.ImageProcessingChecker(imagePreview)

    expect(imagePreview.querySelector('img')).toBe(null)

    window.setTimeout(() => {
      expect(
        imagePreview.querySelector('.js-image-processing-failure-tag')
      ).toBeTruthy()
      done()
    }, 100)
  })
})
