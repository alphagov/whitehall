'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  class ImageProcessingChecker {
    static TIMEOUT_DURATION = 1000
    static MAX_ATTEMPTS = 5

    constructor($root) {
      this.$root = $root
      this.imageLink = this.$root.dataset.imageLink

      this.timeoutDuration =
        parseInt(this.$root.dataset.timeoutDuration, 10) ||
        ImageProcessingChecker.TIMEOUT_DURATION
      this.maxAttempts =
        parseInt(this.$root.dataset.maxAttempts) ||
        ImageProcessingChecker.MAX_ATTEMPTS

      const imagePreview = this.$root.querySelector('.js-image-preview')
      const imagePreviewFailure = this.$root.querySelector(
        '.js-image-preview-failure'
      )

      if (imagePreview) {
        this.imagePreview = document.importNode(
          imagePreview.content,
          true
        ).firstElementChild
      }

      if (imagePreviewFailure) {
        this.imagePreviewFailure = document.importNode(
          imagePreviewFailure.content,
          true
        ).firstElementChild
      }

      this.imageStatus = this.$root.querySelector('.js-image-processing-status')

      // the image was not already loaded on page load
      if (this.imageStatus && !this.imageStatus.querySelector('img')) {
        this.checkImageStatus()
      }
    }

    checkImageStatus(attempts = 0) {
      if (attempts !== this.maxAttempts) {
        fetch(this.imageLink)
          .then((response) => {
            if (response.ok) {
              return response.clone().json()
            } else {
              throw new Error(
                `Supplied URL ${this.imageLink} returned ${response.status}`
              )
            }
          })
          // eslint-disable-next-line camelcase
          .then(({ image_data: { all_assets_uploaded, assets } }) =>
            // eslint-disable-next-line camelcase
            !all_assets_uploaded
              ? setTimeout(
                  () => this.checkImageStatus(attempts + 1),
                  this.timeoutDuration * Math.pow(2, attempts + 1)
                )
              : this.handleSuccess(assets)
          )
          .catch((error) => this.handleFailure(error.message))
      } else {
        this.handleFailure(`Image at ${this.imageLink} was not ready in time`)
      }
    }

    updateImageStatus(replacementEl) {
      if (replacementEl) {
        this.$root.replaceChild(replacementEl, this.imageStatus)
      } else {
        this.imageStatus.remove()
      }
    }

    handleFailure(error) {
      console.error(error)
      this.updateImageStatus(this.imagePreviewFailure)
    }

    handleSuccess(assets) {
      if (!this.imagePreview) {
        this.updateImageStatus()
      } else {
        const imgElement =
          this.imagePreview.querySelector('img') ||
          (this.imagePreview.tagName === 'IMG' && this.imagePreview)

        if (imgElement) {
          const previewAsset = assets.find(
            ({ variant }) => variant !== 'original'
          )

          // images with multiple assets can have
          // transformed variants so we should not use
          // the `original` asset if this is the case
          imgElement.src = previewAsset ? previewAsset.url : assets[0].url
        }

        this.updateImageStatus(this.imagePreview)
      }
    }
  }

  Modules.ImageProcessingChecker = ImageProcessingChecker
})(window.GOVUK.Modules)
