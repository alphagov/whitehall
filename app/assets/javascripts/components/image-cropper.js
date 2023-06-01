//= require cropperjs/dist/cropper.js
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function ImageCropper ($imageCropper) {
    this.$imageCropper = $imageCropper
    this.$image = this.$imageCropper.querySelector('.app-c-image-cropper__image')
    this.$targetWidth = 960
    this.$targetHeight = 640
  }

  ImageCropper.prototype.init = function () {
    // This only runs if the image isn't cached
    this.$image.addEventListener('load', function () {
      this.initCropper()
    }.bind(this))

    // This should only run if the image is cached
    if (this.$image.complete) {
      this.initCropper()
    }

    this.$image.addEventListener('ready', function () {
      this.initKeyboardControls()
      this.updateAriaLabel()
    }.bind(this))

    this.$image.addEventListener('crop', function () {
      this.updateAriaLabel()
    }.bind(this))

    this.$imageCropper.addEventListener('click', function () {
      this.$imageCropper.focus()
    }.bind(this))
  }

  ImageCropper.prototype.initCropper = function () {
    if (!this.$image.complete) {
      return
    }

    var width = this.$image.clientWidth
    var naturalWidth = this.$image.naturalWidth
    var scaledRatio = width / naturalWidth

    // Adjust the crop box limits to the scaled image
    var minCropBoxWidth = Math.ceil(this.$targetWidth * scaledRatio)
    var minCropBoxHeight = Math.ceil(this.$targetHeight * scaledRatio)

    if (this.$image) {
      this.cropper = new window.Cropper(this.$image, { // eslint-disable-line
        viewMode: 2,
        aspectRatio: 3 / 2,
        autoCrop: true,
        autoCropArea: 1,
        guides: false,
        zoomable: false,
        highlight: false,
        minCropBoxWidth: minCropBoxWidth,
        minCropBoxHeight: minCropBoxHeight,
        rotatable: false,
        scalable: false
      })
      this.setupFormListener()
    }
  }

  ImageCropper.prototype.initKeyboardControls = function () {
    this.$imageCropper.addEventListener('keydown', function (e) {
      var cropBoxData = this.cropper.getCropBoxData()

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
    }.bind(this))
  }

  ImageCropper.prototype.updateAriaLabel = function () {
    var cropBoxData = this.cropper.getCropBoxData()
    var imageData = this.cropper.getImageData()
    var portionSelected = (cropBoxData.height * cropBoxData.width) /
            (imageData.height * imageData.width)
    var percentage = Math.round(portionSelected * 10) * 10
    if (percentage === 100) {
      this.$imageCropper.ariaLabel = 'Image to be cropped. All of the image is selected.'
      return
    }

    var horizontalPosition = cropBoxData.left / (imageData.width - cropBoxData.width)
    var verticalPosition = cropBoxData.top / (imageData.height - cropBoxData.height)

    var positionText = ''
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
    this.$imageCropper.ariaLabel = 'Image to be cropped. ' +
        percentage + '% of the image, centered on the ' +
        positionText + 'is selected.'
  }

  ImageCropper.prototype.setupFormListener = function () {
    var input = this.$imageCropper.querySelector('.js-cropped-image-input')
    input.form.addEventListener('submit', function (event) {
      event.preventDefault()
      this.cropper.getCroppedCanvas({
        width: this.$targetWidth,
        height: this.$targetHeight
      }).toBlob(function (blob) {
        var file = new File(
          [blob],
          this.$imageCropper.dataset.filename,
          {
            type: this.$imageCropper.dataset.type,
            lastModified: new Date().getTime()
          })
        var container = new DataTransfer()
        container.items.add(file)
        input.files = container.files
        input.form.submit()
      }.bind(this), this.$imageCropper.dataset.type)
    }.bind(this))
  }

  Modules.ImageCropper = ImageCropper
})(window.GOVUK.Modules)
