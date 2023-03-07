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

    this.setupFormListener()
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
    }
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
