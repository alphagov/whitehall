//= require cropperjs/dist/cropper.js
'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  function ImageCropper($imageCropper) {
    this.$imageCropper = $imageCropper
    this.$image = this.$imageCropper.querySelector(
      '.app-c-image-cropper__image'
    )
    this.$targetWidth = parseInt(this.$imageCropper.dataset.width, 10)
    this.$targetHeight = parseInt(this.$imageCropper.dataset.height, 10)
    this.$croppingX = parseInt(this.$imageCropper.dataset.x, 10)
    this.$croppingY = parseInt(this.$imageCropper.dataset.y, 10)
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

        const cropBoxData = this.cropper.getCropBoxData()

        cropBoxData.left = this.$croppingX
        cropBoxData.top = this.$croppingY

        this.cropper.setCropBoxData(cropBoxData)
      }.bind(this)
    )

    this.$image.addEventListener(
      'crop',
      function () {
        this.updateAriaLabel()

        const data = this.cropper.getData(true)

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

  ImageCropper.prototype.initCropper = function () {
    if (!this.$image || !this.$image.complete || this.cropper) {
      return
    }

    const width = this.$image.clientWidth
    const naturalWidth = this.$image.naturalWidth
    const scaledRatio = width / naturalWidth

    // Adjust the crop box limits to the scaled image
    const minCropBoxWidth = Math.ceil(this.$targetWidth * scaledRatio)
    const minCropBoxHeight = Math.ceil(this.$targetHeight * scaledRatio)

    this.cropper = new window.Cropper(this.$image, {
      // eslint-disable-line
      viewMode: 2,
      aspectRatio: this.$targetWidth / this.$targetHeight,
      autoCrop: true,
      autoCropArea: 1,
      guides: false,
      zoomable: false,
      highlight: false,
      minCropBoxWidth,
      minCropBoxHeight,
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
