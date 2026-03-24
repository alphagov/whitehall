//= require cropperjs/dist/cropper.js
'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  function Cropbox(version, colour, style, outlineWidth, scaledRatio) {
    this.version = version
    this.colour = colour
    this.style = style
    this.outlineWidth = outlineWidth
    this.scaledRatio = scaledRatio
    this.dragging = false

    this.el = document.createElement('DIV')
    this.el.id = `cropbox-${version.name}`
    this.el.classList.add('cropper-crop-box')
    this.el.style.outline = `${this.outlineWidth}px ${this.style} ${this.colour}`
    this.el.style.pointerEvents = 'none'
    this.el.style.zIndex = 99
  }

  Cropbox.prototype.updatePosition = function (newHeight, newWidth, newScale) {
    const { height, width } = this.version

    const scaledWidth = Math.min(width * newScale * this.scaledRatio, newWidth)
    const scaledHeight = Math.min(
      height * newScale * this.scaledRatio,
      newHeight
    )

    const translateY = (newHeight - scaledHeight) / 2 + this.outlineWidth
    const translateX = (newWidth - scaledWidth) / 2 + this.outlineWidth

    this.el.style.width =
      Math.min(scaledWidth - this.outlineWidth * 2, newWidth) + 'px'
    this.el.style.height =
      Math.min(scaledHeight - this.outlineWidth * 2, newHeight) + 'px'
    this.el.style.transform = `translateX(${translateX}px) translateY(${translateY}px)`
  }

  Cropbox.prototype.toggleVisibility = function (visibility) {
    if (!visibility) {
      this.el.setAttribute('hidden', true)
    } else {
      this.el.removeAttribute('hidden')
    }
  }

  class CropInformation {
    constructor($root, colours, styles) {
      this.$root = $root
      this.colours = colours
      this.styles = styles
      this.cropKeys = []
      this.init()
    }

    init() {
      this.$root.removeAttribute('hidden')
      this.showAll = this.renderItem('Show all', 'show-all', (e) =>
        this.toggleAll(e)
      )
      this.$root.querySelector('ul').appendChild(this.showAll)
    }

    toggleAll(visibility) {
      this.cropKeys.forEach((cropKey) => {
        const input = cropKey.querySelector('input')
        if (input) {
          cropKey.querySelector('input').checked = visibility
          cropKey.dispatchEvent(new Event('click'))
        }
      })
    }

    renderItem(legendKey, versionName, onClick, style, colour) {
      const item = document.createElement('LI')
      item.classList.add('app-c-image-cropper__crop-key')
      item.dataset.cropBox = versionName
      item.innerHTML = `
        <div class="govuk-checkboxes__item">
          <input class="govuk-checkboxes__input" id="${versionName}" name="${versionName}" type="checkbox" checked="true" value="show">
          <label class="govuk-label govuk-checkboxes__label" for="${versionName}">
            ${
              style && colour
                ? `<span style="border: 5px ${style} ${colour}" class="app-c-image-cropper__crop-key-colour"></span>`
                : ``
            }
            ${legendKey}
          </label>
        </div>
      `
      item.addEventListener('click', (e) => {
        const checkBox = item.querySelector('input')
        onClick(checkBox.checked)
        this.showAll.querySelector('input').checked =
          this.$root.querySelectorAll('input:checked:not([name=show-all])')
            .length === this.cropKeys.length
      })
      return item
    }

    addCropKey(legendKey, versionName, onClick) {
      const index = this.cropKeys.length
      this.cropKeys.push(
        this.renderItem(
          legendKey,
          versionName,
          onClick,
          this.styles[index],
          this.colours[index]
        )
      )
      this.$root
        .querySelector('ul')
        .appendChild(this.cropKeys[this.cropKeys.length - 1])
    }
  }

  class CropControls {
    constructor($root, controls, action) {
      this.$root = $root
      this.controls = controls
      this.action = action
      this.el = document.createElement('div')
      this.el.classList.add('app-c-image-cropper__crop-button-container')

      this.init()
    }

    init() {
      this.controls.forEach(({ direction, className, cropBox, title }) => {
        const button = document.createElement('button')
        button.title = title
        button.classList.add('govuk-button', 'app-c-image-cropper__crop-button')
        button.classList.add(`app-c-image-cropper__crop-button--${className}`)

        button.addEventListener('click', (e) => {
          e.preventDefault()
          this.action(cropBox)
        })

        this.el.appendChild(button)
      })

      this.$root.appendChild(this.el)
    }
  }

  function ImageCropper($imageCropper) {
    this.$imageCropper = $imageCropper
    this.$image = this.$imageCropper.querySelector(
      '.app-c-image-cropper__image'
    )
    this.imageInformationContainer = this.$imageCropper.querySelector(
      '.app-c-image-cropper__image-information'
    )
    this.controlsContainer = this.$imageCropper.querySelector(
      '.app-c-image-cropper__controls-container'
    )
    this.$targetWidth = parseInt(this.$imageCropper.dataset.targetWidth, 10)
    this.$targetHeight = parseInt(this.$imageCropper.dataset.targetHeight, 10)
    this.$croppingHeight = parseInt(this.$imageCropper.dataset.height, 10)
    this.$croppingWidth = parseInt(this.$imageCropper.dataset.width, 10)
    this.$croppingX = parseInt(this.$imageCropper.dataset.x, 10)
    this.$croppingY = parseInt(this.$imageCropper.dataset.y, 10)
    this.$versions = this.$imageCropper.dataset.versions
      ? JSON.parse(this.$imageCropper.dataset.versions)
      : []
    this.$uniqueVersions = this.$versions.filter(
      (version) => !version.from_version
    )
    this.$cropBoxes = []
  }

  ImageCropper.prototype.init = function () {
    // This only runs if the image isn't cached
    this.$image.addEventListener(
      'load',
      function () {
        this.initCropper()
      }.bind(this)
    )

    // This should only run if the image is cached
    if (this.$image.complete) {
      this.initCropper()
    }

    this.$image.addEventListener(
      'ready',
      function () {
        this.initKeyboardControls()
        this.initButtonControls()
        this.updateAriaLabel()

        this.cropper.setData({
          x: this.$croppingX,
          y: this.$croppingY,
          width: this.$croppingWidth || this.$targetWidth,
          height: this.$croppingHeight || this.$targetHeight
        })

        this.$cropBox = this.$imageCropper.querySelector('.cropper-crop-box')
        this.$cropperContainer =
          this.$imageCropper.querySelector('.cropper-container')

        this.cropBoxReady = this.$uniqueVersions.length > 1

        if (this.cropBoxReady) {
          this.$imageCropper.querySelector('.cropper-view-box').style.outline =
            `2px dashed #fd0`
        }

        this.initCropboxes()
      }.bind(this)
    )

    this.$image.addEventListener(
      'cropend',
      function (e) {
        this.updateAriaLabel()
      }.bind(this)
    )

    this.$image.addEventListener(
      'crop',
      function (e) {
        const data = this.cropper.getData(true)

        this.$cropBoxes.forEach((cropBox) =>
          cropBox.updatePosition(
            this.$cropBox.clientHeight,
            this.$cropBox.clientWidth,
            this.cropper.getData(true).width / this.$targetWidth
          )
        )

        Object.keys(data).forEach((attribute) => {
          const input = this.$imageCropper.querySelector(
            `.js-cropped-image-input[name$="${attribute}]"]`
          )

          if (input) {
            input.value = data[attribute]
          }
        })

        this.updateAriaLabel()
      }.bind(this)
    )

    this.$imageCropper.addEventListener(
      'cropmove',
      function (e) {
        this.dragging = true
      }.bind(this)
    )

    this.$imageCropper.addEventListener(
      'cropend',
      function (e) {
        if (!this.dragging) {
          const { clientX, clientY } = e.detail.originalEvent
          const container =
            this.$imageCropper.querySelector('.cropper-container')
          const { top, left } = container.getBoundingClientRect()
          const containerTop = window.scrollY + top
          const containerLeft = window.scrollX + left

          this.cropper.setCropBoxData({
            top: clientY - containerTop,
            left: clientX - containerLeft
          })
        }

        this.dragging = false
      }.bind(this)
    )

    this.$imageCropper.addEventListener(
      'click',
      function (e) {
        if (e.target.closest('.cropper-crop-box')) {
          this.$imageCropper.focus()
        }
      }.bind(this)
    )
  }

  ImageCropper.prototype.initCropboxes = function () {
    if (!this.cropBoxReady) {
      return
    }

    const cropBoxColours = ['#f47738', '#0f7a52', '#ca3535', '#0f7a52']
    const cropBoxStyles = ['dotted', 'dashed', 'solid']
    const cropBoxOutlineWidth = [8, 4, 4]

    this.$imageInformation = new CropInformation(
      this.$imageCropper.querySelector(
        '.app-c-image-cropper__image-information'
      ),
      cropBoxColours,
      cropBoxStyles
    )

    this.$uniqueVersions.forEach((version, index) => {
      const { name } = version
      const colour = cropBoxColours[index % cropBoxColours.length]
      const style = cropBoxStyles[index % cropBoxStyles.length]
      const cropBox = new Cropbox(
        version,
        colour,
        style,
        cropBoxOutlineWidth[index % cropBoxOutlineWidth.length],
        this.scaledRatio
      )

      const legendKey = this.$versions
        .reduce((names, version) => {
          const currentName = version.name
          const legendName = (
            (currentName.match(/.*(?=_\d+x)/) || [])[0] || currentName
          ).replace('_', ' ')

          if (
            (version.from_version === name || version.name === name) &&
            names.indexOf(legendName) < 0
          ) {
            names.push(legendName)
          }

          return names
        }, [])
        .join('/')

      cropBox.updatePosition(
        this.$cropBox.clientHeight,
        this.$cropBox.clientWidth,
        this.cropper.getData(true).width / this.$targetWidth
      )

      this.$cropBoxes.push(cropBox)
      this.$cropBox.prepend(cropBox.el)
      this.$imageInformation.addCropKey(legendKey, name, (checked) =>
        cropBox.toggleVisibility(checked)
      )
    })
  }

  ImageCropper.prototype.initCropper = function () {
    if (!this.$image || !this.$image.complete || this.cropper) {
      return
    }

    this.scaledRatio = this.$image.clientWidth / this.$image.naturalWidth
    this.cropper = new window.Cropper(this.$image, {
      // eslint-disable-line
      viewMode: 2,
      aspectRatio: this.$targetWidth / this.$targetHeight,
      minCropBoxWidth: this.$targetWidth * 0.25,
      minCropBoxHeight: this.$targetHeight * 0.25,
      autoCrop: true,
      autoCropArea: 1,
      dragMode: 'move',
      guides: false,
      zoomable: false,
      highlight: false,
      rotatable: false,
      scalable: false,
      checkOrientation: false,
      checkCrossOrigin: false,
      toggleDragModeOnDblclick: false
    })
  }

  ImageCropper.prototype.initButtonControls = function () {
    if (!this.controlsContainer) return

    this.controlsContainer.removeAttribute('hidden')

    const buttonsContainer = document.createElement('div')
    buttonsContainer.classList.add(
      'app-c-image-cropper__control-buttons-container'
    )
    this.controlsContainer.appendChild(buttonsContainer)

    const directions = [
      {
        label: 'Up',
        className: 'up',
        title: 'Move cropbox up',
        cropBox: {
          top: (value) => value - 10
        }
      },
      {
        label: 'Left',
        className: 'left',
        title: 'Move cropbox left',
        cropBox: {
          left: (value) => value - 10
        }
      },
      {
        label: 'Down',
        className: 'down',
        title: 'Move cropbox down',
        cropBox: {
          top: (value) => value + 10
        }
      },
      {
        label: 'Right',
        className: 'right',
        title: 'Move cropbox right',
        cropBox: {
          left: (value) => value + 10
        }
      }
    ]

    const scales = [
      {
        label: 'Increase',
        className: 'increase',
        title: 'Increase size of the cropbox',
        cropBox: {
          width: (value) => (value *= 1.05),
          height: (value) => (value *= 1.05)
        }
      },
      {
        label: 'Decrease',
        className: 'decrease',
        title: 'Decrease size of the cropbox',
        cropBox: {
          width: (value) => (value /= 1.05),
          height: (value) => (value /= 1.05)
        }
      }
    ]

    const changeCropBox = (change) => {
      const cropBoxData = this.cropper.getCropBoxData()
      Object.keys(change).forEach((key) => {
        cropBoxData[key] = change[key](cropBoxData[key])
      })
      this.cropper.setCropBoxData(cropBoxData)
    }

    /* eslint-disable no-new */
    new CropControls(buttonsContainer, directions, changeCropBox)
    new CropControls(buttonsContainer, scales, changeCropBox)
  }

  ImageCropper.prototype.initKeyboardControls = function () {
    this.$imageCropper.addEventListener(
      'keydown',
      function (e) {
        const cropBoxData = this.cropper.getCropBoxData()

        switch (e.keyCode) {
          case 37:
            e.preventDefault()
            cropBoxData.left -= 10
            break

          case 38:
            e.preventDefault()
            cropBoxData.top -= 10
            break

          case 39:
            e.preventDefault()
            cropBoxData.left += 10
            break

          case 40:
            e.preventDefault()
            cropBoxData.top += 10
            break

          case 187:
            e.preventDefault()
            cropBoxData.height *= 1.05
            cropBoxData.width *= 1.05
            break

          case 189:
            e.preventDefault()
            cropBoxData.height /= 1.05
            cropBoxData.width /= 1.05
            break
        }
        this.cropper.setCropBoxData(cropBoxData)
      }.bind(this)
    )
  }

  ImageCropper.prototype.updateAriaLabel = function () {
    const cropBoxData = this.cropper.getCropBoxData()
    const imageData = this.cropper.getImageData()
    const portionSelected =
      (cropBoxData.height * cropBoxData.width) /
      (imageData.height * imageData.width)
    const percentage = Math.round(portionSelected * 10) * 10
    if (percentage === 100) {
      this.$imageCropper.ariaLabel =
        'Image to be cropped. All of the image is selected.'
      return
    }

    const horizontalPosition =
      cropBoxData.left / (imageData.width - cropBoxData.width)
    const verticalPosition =
      cropBoxData.top / (imageData.height - cropBoxData.height)

    let positionText = ''
    if (verticalPosition < 0.33) {
      positionText += 'top '
    } else if (verticalPosition > 0.67) {
      positionText += 'bottom '
    }
    if (horizontalPosition < 0.33) {
      positionText += 'left '
    } else if (horizontalPosition > 0.67) {
      positionText += 'right '
    }

    if (positionText === '') positionText = 'middle '
    this.$imageCropper.ariaLabel =
      'Image to be cropped. ' +
      percentage +
      '% of the image, centered on the ' +
      positionText +
      'is selected.'
  }

  Modules.ImageCropper = ImageCropper
})(window.GOVUK.Modules)
