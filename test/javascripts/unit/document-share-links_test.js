module('document-share-links', {
  setup: function () {
    GOVUK.analytics = { trackShare: function () {} }
    this.$el = $('<div></div>')
    this.$el.append('<a href="#" class="facebook">Facebook</a>')
    this.$el.append('<a href="#" class="twitter">Twitter</a>')
    this.shareLinks = new window.GOVUK.DocumentShareLinks({ el: this.$el })
  }
})

test('should send GA event when clicking facebook button', function () {
  var spy = this.spy(GOVUK.analytics, 'trackShare')
  this.$el.find('.facebook').click()
  sinon.assert.calledWith(spy, 'facebook')
})

test('should send GA event when clicking twitter button', function () {
  var spy = this.spy(GOVUK.analytics, 'trackShare')
  this.$el.find('.twitter').click()
  sinon.assert.calledWith(spy, 'twitter')
})
