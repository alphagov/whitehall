describe('GOVUK.Modules.ImageCropper', () => {
  let form, component, module

  beforeEach((done) => {
    const canvas = document.createElement('canvas')
    canvas.setAttribute('width', 1920)
    canvas.setAttribute('height', 1280)
    const src = canvas.toDataURL('image/png')

    component = document.createElement('div')
    component.setAttribute('data-filename', 'icon.png')
    component.setAttribute('data-type', 'image/png')
    component.setAttribute('data-width', '960')
    component.setAttribute('data-height', '640')
    component.setAttribute('data-x', 0)
    component.setAttribute('data-y', 0)
    component.setAttribute('class', 'app-c-image-cropper')
    component.innerHTML = `
      <input class="js-cropped-image-input" name="image" hidden>
      <div style="position: relative; width: 1920px; height: 1280px;">
        <img class="app-c-image-cropper__image" src="${src}"/>
      </div>
      <input type="file" class="js-cropped-image-input-file">
    `

    form = document.createElement('form')
    form.appendChild(component)
    document.body.append(form)

    // Initializing the module immediately after appending the form results in
    // the cropper not properly reading the DOM, the following timeout prevents
    // that from occuring.
    window.setTimeout(() => {
      module = new GOVUK.Modules.ImageCropper(component)
      module.init()

      const image = document.querySelector('.app-c-image-cropper__image')
      image.addEventListener('ready', () => done())
    }, 1)
  })

  afterEach(() => form.remove())

  it('should add cropping data to input when crop takes place', (done) => {
    const image = document.querySelector('.app-c-image-cropper__image')
    image.addEventListener('crop', () => {
      const input = document.querySelector('.js-cropped-image-input')
      expect(input.value).toBe(
        // the cropper supports width and height that are bigger
        // that the height and width specified if the aspect ratio
        // of the cropped width and height is the same (since we
        // use "fit to size" image processing on our images)
        JSON.stringify({ x: 0, y: 0, width: 1920, height: 1280 })
      )
      done()
    })
    image.dispatchEvent(new CustomEvent('crop'))
  })

  it('should update the aria label as the selection is controlled using the keyboard', (done) => {
    expect(document.querySelector('.app-c-image-cropper').ariaLabel).toBe(
      'Image to be cropped. All of the image is selected.'
    )
    const image = document.querySelector('.app-c-image-cropper__image')
    image.addEventListener('crop', () => {
      expect(document.querySelector('.app-c-image-cropper').ariaLabel).toBe(
        'Image to be cropped. 90% of the image, centered on the top left is selected.'
      )
      done()
    })
    component.dispatchEvent(new KeyboardEvent('keydown', { keyCode: 189 }))
  })
})
