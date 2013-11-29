module("document-share-links", {
  setup: function() {
    window._gaq = [];

    this.$el = $('<div class="document-share-links"></div>');
    this.$el.append('<a href="https://www.facebook.com/sharer/sharer.php?u=https://www.gov.uk" target="_blank" class="facebook"><span class="connect">Share on</span> Facebook</span></a>');
    this.$el.append('<a href="https://twitter.com/share?url=https://www.gov.uk" target="_blank" class="twitter"><span class="connect">Share on</span> Twitter</span></a>');
    this.shareLinks = new window.GOVUK.DocumentShareLinks({el: this.$el});
  }
});

test("should send GA event when clicking facebook button", function() {
  equal(window._gaq.length, 0);
  this.$el.find('.facebook').click();
  equal(window._gaq[0][0], '_trackSocial');
  equal(window._gaq[0][1], 'facebook');
  equal(window._gaq[0][2], 'share');
});

test("should send GA event when clicking twitter button", function() {
  equal(window._gaq.length, 0);
  this.$el.find('.twitter').click();
  equal(window._gaq[0][0], '_trackSocial');
  equal(window._gaq[0][1], 'twitter');
  equal(window._gaq[0][2], 'share');
});

