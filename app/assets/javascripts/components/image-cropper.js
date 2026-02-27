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

    this.el = document.createElement('DIV')
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

  function ImageCropper($imageCropper) {
    this.$imageCropper = $imageCropper
    this.$image = this.$imageCropper.querySelector(
      '.app-c-image-cropper__image'
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
        this.$imageInformation = this.$imageCropper.querySelector(
          '.app-c-image-cropper__image-information'
        )

        this.cropBoxReady = this.$uniqueVersions.length > 1

        if (this.cropBoxReady) {
          this.$imageCropper.querySelector('.cropper-view-box').style.outline =
            `2px dashed #fd0`
        }

        this.initCropboxes()
      }.bind(this)
    )

    this.$image.addEventListener(
      'crop',
      function () {
        this.updateAriaLabel()

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
      }.bind(this)
    )

    this.$imageCropper.addEventListener(
      'click',
      function () {
        this.$imageCropper.focus()
      }.bind(this)
    )
  }

  ImageCropper.prototype.initCropboxes = function () {
    if (!this.cropBoxReady) {
      return
    }

    const cropBoxColours = ['#f47738', '#0f7a52', '#ca3535', '#0f7a52']
    const cropBoxStyles = ['dotted', 'dashed', 'solid']
    const cropBoxOutlineWidth = 4

    this.$uniqueVersions.forEach((version, index) => {
      const { name } = version
      const colour = cropBoxColours[index % cropBoxColours.length]
      const style = cropBoxStyles[index % cropBoxColours.length]
      const cropBox = new Cropbox(
        version,
        colour,
        style,
        cropBoxOutlineWidth + index,
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
      this.$cropBox.appendChild(cropBox.el)

      this.$imageInformation.removeAttribute('hidden')
      const legend = document.createElement('LI')
      legend.classList.add('app-c-image-cropper__crop-key')
      legend.innerHTML = `
          <span style="border: 5px ${style} ${colour}" class="app-c-image-cropper__crop-key-colour"></span>
          ${legendKey}
        `
      this.$imageInformation.querySelector('ul').appendChild(legend)
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
      guides: false,
      zoomable: false,
      highlight: false,
      rotatable: false,
      scalable: false
    })
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
