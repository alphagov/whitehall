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
    this.$targetWidth = parseInt(this.$imageCropper.dataset.targetWidth, 10)
    this.$targetHeight = parseInt(this.$imageCropper.dataset.targetHeight, 10)
    this.$croppingHeight = parseInt(this.$imageCropper.dataset.height, 10)
    this.$croppingWidth = parseInt(this.$imageCropper.dataset.width, 10)
    this.$croppingX = parseInt(this.$imageCropper.dataset.x, 10)
    this.$croppingY = parseInt(this.$imageCropper.dataset.y, 10)
    this.$versions = this.$imageCropper.dataset.versions
      ? JSON.parse(this.$imageCropper.dataset.versions)
      : []
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
          width: this.$croppingWidth,
          height: this.$croppingHeight
        })

        this.$cropBox = this.$imageCropper.querySelector('.cropper-crop-box')
        this.$cropCanvas = this.$imageCropper.querySelector('.cropper-canvas')
        this.$cropContainer =
          this.$imageCropper.querySelector('.cropper-container')

        this.previewReady = true

        this.handlePreviews()
      }.bind(this)
    )

    this.$image.addEventListener(
      'crop',
      function () {
        this.updateAriaLabel()
        this.handlePreviews()

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

  ImageCropper.prototype.handlePreviews = function () {
    if (!this.previewReady) {
      return
    }

    const data = this.cropper.getData(true)

    const previewColours = ['#f47738', '#0f7a52', '#ca3535', '#0f7a52']
    const outlineWidth = 3

    this.$versions.forEach((version, index) => {
      const { height, width, name } = version

      if (
        (width === this.$image.naturalWidth &&
          height === this.$image.naturalHeight) ||
        version.from_version
      )
        return

      const scale = data.width / this.$targetWidth
      const newWidth = width * scale
      const newHeight = height * scale
      const newX = data.x + data.width / 2 - newWidth / 2
      const newY = data.y + data.height / 2 - newHeight / 2

      if (width !== this.$targetWidth || height !== this.$targetHeight) {
        const widthOffset =
          this.$cropContainer.clientWidth - this.$cropCanvas.clientWidth
        const heightOffset =
          this.$cropContainer.clientHeight - this.$cropCanvas.clientHeight

        const translateX = widthOffset / 2 + newX * this.scaledRatio
        const translateY = heightOffset / 2 + newY * this.scaledRatio

        let previewCropbox = this.$cropBox.parentNode.querySelector(
          `#preview-${width}x${height}`
        )

        if (!previewCropbox) {
          previewCropbox = this.$cropBox.cloneNode(false)
          const previewCropboxPoint = this.$cropBox
            .querySelector('.cropper-point.point-sw')
            .cloneNode(false)
          previewCropboxPoint.innerText = name
          previewCropboxPoint.classList.add('point-label')
          previewCropboxPoint.style.backgroundColor =
            previewColours[index % previewColours.length]
          previewCropbox.id = `preview-${width}x${height}`
          previewCropbox.style.outline = `${outlineWidth}px dashed ${previewColours[index % previewColours.length]}`
          previewCropbox.style.pointerEvents = 'none'
          previewCropbox.style.zIndex = 99 - index
          previewCropbox.appendChild(previewCropboxPoint)
          this.$cropBox.parentNode.appendChild(previewCropbox)
        }

        previewCropbox.style.width =
          newWidth * this.scaledRatio - outlineWidth * 2 + 'px'
        previewCropbox.style.height =
          newHeight * this.scaledRatio - outlineWidth * 2 + 'px'
        previewCropbox.style.transform = `translateX(${translateX + outlineWidth}px) translateY(${translateY + outlineWidth}px)`
      }
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
