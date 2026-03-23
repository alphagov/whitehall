describe('GOVUK.Modules.ImageCropper', () => {
  let form, component, module

  const width = 960
  const height = 640
  const imageWidth = width
  const imageHeight = 660
  const versions = [
    {
      name: 'desktop',
      width: 1024,
      height: 1024,
      from_version: null
    },
    {
      name: 'tablet',
      width: 1536,
      height: 864,
      from_version: null
    },
    {
      name: 'mobile',
      width: 640,
      height: 360,
      from_version: null
    }
  ]

  const initCropperHTML = () => {
    const canvas = document.createElement('canvas')
    canvas.setAttribute('width', imageWidth)
    canvas.setAttribute('height', imageHeight)
    const src = canvas.toDataURL('image/png')

    component = document.createElement('div')
    component.setAttribute('data-filename', 'icon.png')
    component.setAttribute('data-type', 'image/png')
    component.setAttribute('data-width', imageWidth)
    component.setAttribute('data-height', imageHeight)
    component.setAttribute('data-x', 0)
    component.setAttribute('data-y', 0)
    component.setAttribute('data-target-width', width)
    component.setAttribute('data-target-height', height)
    component.setAttribute('data-versions', '[]')
    component.setAttribute('class', 'app-c-image-cropper')
    component.innerHTML = `
      <input class="js-cropped-image-input" name="[x]" hidden>
      <input class="js-cropped-image-input" name="[y]" hidden>
      <input class="js-cropped-image-input" name="[height]" hidden>
      <input class="js-cropped-image-input" name="[width]" hidden>
      <div style="position: relative; width: 1920px; height: 1280px;">
        <img class="app-c-image-cropper__image" src="${src}"/>
      </div>
    `

    form = document.createElement('form')
    form.appendChild(component)
    document.body.append(form)
  }

  describe('without versions', () => {
    beforeEach((done) => {
      initCropperHTML()
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
        const inputX = document.querySelector(
          '.js-cropped-image-input[name="[x]"]'
        )
        const inputY = document.querySelector(
          '.js-cropped-image-input[name="[y]"]'
        )
        const inputWidth = document.querySelector(
          '.js-cropped-image-input[name="[width]"]'
        )
        const inputHeight = document.querySelector(
          '.js-cropped-image-input[name="[height]"]'
        )
        expect(inputX.value).toBe('0')
        expect(inputY.value).toBe(`${(imageHeight - height) / 2}`)
        expect(inputWidth.value).toBe(`${width}`)
        expect(inputHeight.value).toBe(`${height}`)
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

  describe('with versions', () => {
    beforeEach((done) => {
      initCropperHTML()
      component.innerHTML += `
        <div class="app-c-image-cropper__image-information" hidden>
          <h2 class="govuk-heading-m">Crop boxes</h2>
          <ul class="govuk-list"></ul>
        </div>
      `
      component.setAttribute('data-versions', JSON.stringify(versions))

      window.setTimeout(() => {
        module = new GOVUK.Modules.ImageCropper(component)
        module.init()

        const image = document.querySelector('.app-c-image-cropper__image')
        image.addEventListener('ready', () => done())
      }, 1)
    })

    afterEach(() => form.remove())

    it('should display multiple cropboxes', (done) => {
      expect(document.querySelectorAll('.cropper-crop-box').length).toBe(
        versions.length + 1
      )
      done()
    })

    it('should display legend for each cropbox', (done) => {
      const cropKeys = Array.from(
        document.querySelectorAll('.app-c-image-cropper__crop-key')
      )
      cropKeys.shift()
      expect(cropKeys.length).toBe(versions.length)
      cropKeys.forEach((cropKey, index) => {
        const keyColour = cropKey.querySelector(
          '.app-c-image-cropper__crop-key-colour'
        )
        const cropBox = document.querySelector(
          `#cropbox-${cropKey.dataset.cropBox}`
        )

        expect(cropKey.innerText.replaceAll(' ', '').toLowerCase()).toBe(
          versions[index].name.toLowerCase()
        )
        expect(cropBox.style.outlineColor).toBe(keyColour.style.borderColor)
        expect(cropBox.style.outlineStyle).toBe(keyColour.style.borderStyle)
      })

      done()
    })

    it('the visibility of each cropbox should be togglable', (done) => {
      const cropKeys = Array.from(
        document.querySelectorAll('.app-c-image-cropper__crop-key')
      )
      const showAll = cropKeys.shift()
      const showAllCheckbox = showAll.querySelector('input')

      showAllCheckbox.click()
      expect(
        document.querySelectorAll(
          '.app-c-image-cropper__crop-key input:checked'
        ).length
      ).toBe(0)
      showAllCheckbox.click()
      expect(
        document.querySelectorAll(
          '.app-c-image-cropper__crop-key input:checked'
        ).length
      ).toBe(cropKeys.length + 1)

      cropKeys.forEach((cropKey) => {
        const cropBox = document.querySelector(
          `#cropbox-${cropKey.dataset.cropBox}`
        )

        const keyCheckbox = cropKey.querySelector('input')

        keyCheckbox.click()

        expect(cropBox.hasAttribute('hidden')).toBeTrue()

        keyCheckbox.click()
        keyCheckbox.dispatchEvent(new Event('click'))

        expect(cropBox.hasAttribute('hidden')).not.toBeTrue()
      })

      done()
    })
  })
})
