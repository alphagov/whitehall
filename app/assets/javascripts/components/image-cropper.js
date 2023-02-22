//= require cropperjs/dist/cropper.js
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function ImageCropper ($imageCropper) {
    this.$imageCropper = $imageCropper
    this.$image = this.$imageCropper.querySelector('.app-c-image-cropper__image')
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
  }

  ImageCropper.prototype.initCropper = function () {
    if (!this.$image.complete) {
      return
    }

    var $inputX = this.$imageCropper.querySelector('.js-image-cropper-x')
    var $inputY = this.$imageCropper.querySelector('.js-image-cropper-y')
    var $inputWidth = this.$imageCropper.querySelector('.js-image-cropper-width')
    var $inputHeight = this.$imageCropper.querySelector('.js-image-cropper-height')

    var width = this.$image.clientWidth
    var height = this.$image.clientHeight
    var naturalWidth = this.$image.naturalWidth
    var naturalHeight = this.$image.naturalHeight
    var scaledRatio = 1
    var minCropWidth = 960
    var minCropHeight = 640

    // Set the crop box limits
    var minCropBoxWidth = minCropWidth
    var minCropBoxHeight = minCropHeight

    // Read existing crop box data
    var cropBoxX = $inputX.value
    var cropBoxY = $inputY.value
    var cropBoxWidth = $inputWidth.value
    var cropBoxHeight = $inputHeight.value

    if (width < naturalWidth || height < naturalHeight) {
      // Determine the scale ratio of the resized image
      scaledRatio = width / naturalWidth

      // Adjust the crop box limits to the scaled image
      minCropBoxWidth = Math.round(minCropBoxWidth * scaledRatio)
      minCropBoxHeight = Math.round(minCropBoxHeight * scaledRatio)

      // Adjust the crop box to the scaled image
      cropBoxX = cropBoxX * scaledRatio
      cropBoxY = cropBoxY * scaledRatio
      cropBoxWidth = cropBoxWidth * scaledRatio
      cropBoxHeight = cropBoxHeight * scaledRatio

      // Ensure the cropbox doesn't exceed the canvas
      if (cropBoxWidth + cropBoxX > width) cropBoxX = width - cropBoxWidth
      if (cropBoxHeight + cropBoxY > height) cropBoxY = height - cropBoxHeight
    }

    if (this.$image) {
      new window.Cropper(this.$image, { // eslint-disable-line
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
        scalable: false,
        ready: function () {
          // Get canvas data
          var canvasData = this.cropper.getCanvasData()

          // Set crop box data
          this.cropper.setCropBoxData({
            left: cropBoxX + canvasData.left,
            top: cropBoxY + canvasData.top,
            width: cropBoxWidth,
            height: cropBoxHeight
          })
        },
        crop: function () {
          // Get crop data
          var cropData = this.cropper.getData({ rounded: true })

          // Ensure the crop size is not smaller than the minimum values
          if (cropData.width < minCropWidth) {
            cropData.width = minCropWidth
            cropData.x -= minCropWidth - cropData.width
          }
          if (cropData.height < minCropHeight) {
            cropData.height = minCropHeight
            cropData.y -= minCropHeight - cropData.height
          }

          // Set crop data in inputs
          $inputX.value = cropData.x
          $inputY.value = cropData.y
          $inputWidth.value = cropData.width
          $inputHeight.value = cropData.height
        }
      })
    }
  }

  Modules.ImageCropper = ImageCropper
})(window.GOVUK.Modules)