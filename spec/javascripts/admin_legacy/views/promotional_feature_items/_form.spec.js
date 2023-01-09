describe('GOVUK.Modules.adminPromotionalFeaturesForm', function () {
  var form

  beforeEach(function () {
    form = document.createElement('form')
    form.classList.add('promotional_feature_item')
    document.body.append(form)
  })

  afterEach(function () {
    form.remove()
  })

  it('hides the image and youtube fields on init when no radios are checked', function () {
    form.innerHTML = uncheckedRadioFields()
    GOVUK.adminPromotionalFeatureItemsForm.init({
      selector: '.promotional_feature_item'
    })

    var imageFields = form.querySelector('.image-fields')
    var youtubeFields = form.querySelector('.youtube-video-url-fields')

    expect(imageFields.hidden).toBe(true)
    expect(youtubeFields.hidden).toBe(true)
  })

  it('hides the youtube fields on init when the image radio is checked', function () {
    form.innerHTML = checkedImageRadioFields()
    GOVUK.adminPromotionalFeatureItemsForm.init({
      selector: '.promotional_feature_item'
    })

    var imageFields = form.querySelector('.image-fields')
    var youtubeFields = form.querySelector('.youtube-video-url-fields')

    expect(imageFields.hidden).toBe(false)
    expect(youtubeFields.hidden).toBe(true)
  })

  it('hides the image fields on init when the youtube_video_url radio is checked', function () {
    form.innerHTML = checkedYoutubeVideoUrlRadioFields()
    GOVUK.adminPromotionalFeatureItemsForm.init({
      selector: '.promotional_feature_item'
    })

    var imageFields = form.querySelector('.image-fields')
    var youtubeFields = form.querySelector('.youtube-video-url-fields')

    expect(imageFields.hidden).toBe(true)
    expect(youtubeFields.hidden).toBe(false)
  })

  it('hides the youtube fields when the image radio is checked', function () {
    form.innerHTML = uncheckedRadioFields()
    GOVUK.adminPromotionalFeatureItemsForm.init({
      selector: '.promotional_feature_item'
    })

    var imageRadio = form.querySelector('#promotional_feature_promotional_feature_items_attributes_0_image_or_youtube_video_url_image')
    imageRadio.dispatchEvent(new Event('change'))

    var imageFields = form.querySelector('.image-fields')
    var youtubeFields = form.querySelector('.youtube-video-url-fields')

    expect(imageFields.hidden).toBe(false)
    expect(youtubeFields.hidden).toBe(true)
  })

  it('hides the image fields when the youtube_video_url radio is checked', function () {
    form.innerHTML = uncheckedRadioFields()
    GOVUK.adminPromotionalFeatureItemsForm.init({
      selector: '.promotional_feature_item'
    })

    var youtubeRadio = form.querySelector('#promotional_feature_promotional_feature_items_attributes_0_image_or_youtube_video_url_youtube_video_url')
    youtubeRadio.dispatchEvent(new Event('change'))

    var imageFields = form.querySelector('.image-fields')
    var youtubeFields = form.querySelector('.youtube-video-url-fields')

    expect(imageFields.hidden).toBe(true)
    expect(youtubeFields.hidden).toBe(false)
  })

  function uncheckedRadioFields () {
    return (
      '<fieldset class="image-and-youtube-radios">' +
        '<input type="radio" value="image" name="promotional_feature[promotional_feature_items_attributes][0][image_or_youtube_video_url]" id="promotional_feature_promotional_feature_items_attributes_0_image_or_youtube_video_url_image">' +
        '<div class="image-fields">' +
        '</div>' +
        '<input type="radio" value="youtube_video_url" name="promotional_feature[promotional_feature_items_attributes][0][image_or_youtube_video_url]" id="promotional_feature_promotional_feature_items_attributes_0_image_or_youtube_video_url_youtube_video_url">' +
        '<div class="youtube-video-url-fields">' +
        '</div>' +
      '</fieldset>'
    )
  }

  function checkedImageRadioFields () {
    return (
      '<fieldset class="image-and-youtube-radios">' +
        '<input type="radio" value="image" checked="checked" name="promotional_feature[promotional_feature_items_attributes][0][image_or_youtube_video_url]" id="promotional_feature_promotional_feature_items_attributes_0_image_or_youtube_video_url_image">' +
        '<div class="image-fields">' +
        '</div>' +
        '<input type="radio" value="youtube_video_url" name="promotional_feature[promotional_feature_items_attributes][0][image_or_youtube_video_url]" id="promotional_feature_promotional_feature_items_attributes_0_image_or_youtube_video_url_youtube_video_url">' +
        '<div class="youtube-video-url-fields">' +
        '</div>' +
      '</fieldset class="image-and-youtube-radios">'
    )
  }

  function checkedYoutubeVideoUrlRadioFields () {
    return (
      '<fieldset class="image-and-youtube-radios">' +
        '<input type="radio" value="image" name="promotional_feature[promotional_feature_items_attributes][0][image_or_youtube_video_url]" id="promotional_feature_promotional_feature_items_attributes_0_image_or_youtube_video_url_image">' +
        '<div class="image-fields">' +
        '</div>' +
        '<input type="radio" value="youtube_video_url" checked="checked" name="promotional_feature[promotional_feature_items_attributes][0][image_or_youtube_video_url]" id="promotional_feature_promotional_feature_items_attributes_0_image_or_youtube_video_url_youtube_video_url">' +
        '<div class="youtube-video-url-fields">' +
        '</div>' +
      '</fieldset>'
    )
  }
})
