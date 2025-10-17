describe('GOVUK.Modules.ImageCropper', () => {
  let form, component, module

  const width = 960
  const height = 640

  beforeEach((done) => {
    const canvas = document.createElement('canvas')
    canvas.setAttribute('width', 960)
    canvas.setAttribute('height', 660)
    const src = canvas.toDataURL('image/png')

    component = document.createElement('div')
    component.setAttribute('data-filename', 'icon.png')
    component.setAttribute('data-type', 'image/png')
    component.setAttribute('data-width', width)
    component.setAttribute('data-height', height)
    component.setAttribute('data-x', 0)
    component.setAttribute('data-y', 0)
    component.setAttribute('class', 'app-c-image-cropper')
    component.innerHTML = `
      <input class="js-cropped-image-input" name="image" hidden>
      <div style="position: relative; width: 1920px; height: 1280px;">
        <img class="app-c-image-cropper__image" src="${src}"/>
      </div>
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
      expect(input.value).toBe(JSON.stringify({ x: 0, y: 0, width, height }))
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
