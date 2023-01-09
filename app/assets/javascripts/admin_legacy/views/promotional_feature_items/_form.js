(function () {
  'use strict'
  window.GOVUK = window.GOVUK || {}

  var promotionalFeatureItemsForm = {
    init: function init (options) {
      this.form = document.querySelector(options.selector)

      var youtubeAndImageRadioFieldset = this.form.querySelector('.image-and-youtube-radios')
      if (!youtubeAndImageRadioFieldset) { return }

      this.toggleImageAndYoutubeFieldsVisibility()
      this.addRadioButtonEventListeners()
    },

    toggleImageAndYoutubeFieldsVisibility: function toggleImageAndYoutubeFieldsVisibility () {
      var form = this.form
      var checked = form.querySelector('.image-and-youtube-radios input[type=radio]:checked')
      var imageFields = form.querySelector('.image-fields')
      var youtubeFields = form.querySelector('.youtube-video-url-fields')

      if (!checked) {
        imageFields.hidden = true
        youtubeFields.hidden = true
      } else if (checked.value === 'image') {
        youtubeFields.hidden = true
      } else {
        imageFields.hidden = true
      }
    },

    addRadioButtonEventListeners: function addRadioButtonEventListeners () {
      var form = this.form
      var radioElements = form.querySelectorAll('.image-and-youtube-radios input[type=radio]')
      var imageFields = form.querySelector('.image-fields')
      var youtubeFields = form.querySelector('.youtube-video-url-fields')

      for (var i = 0; i < radioElements.length; i++) {
        radioElements[i].addEventListener('change', function (event) {
          if (event.currentTarget.value === 'youtube_video_url') {
            imageFields.hidden = true
            youtubeFields.hidden = false
          } else {
            imageFields.hidden = false
            youtubeFields.hidden = true
          }
        })
      }
    }
  }

  window.GOVUK.adminPromotionalFeatureItemsForm = promotionalFeatureItemsForm
}())
