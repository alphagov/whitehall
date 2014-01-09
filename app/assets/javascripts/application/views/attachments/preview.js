(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  function AttachmentsPreview(options) {
    this.$el = $(options.el);
    this.$el.find('.other-organisations').hideOtherLinks({
      showCount: 0,
      linkElement: 'span'
    });
  }
  window.GOVUK.AttachmentsPreview = AttachmentsPreview;
})();
