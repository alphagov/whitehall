(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  function AdminSpeechesForm(options) {
    GOVUK.Proxifier.proxifyAllMethods(this);

    this.$el = $(options.el);
    this.speechTypeLabels = options.speech_type_label_data;
    this.$speechTypeSelect = $('select#edition_speech_type_id', this.$el);
    this.$creatorLabel = $('label[for=edition_role_appointment_id]', this.$el);
    this.$createdDateLabel = $('label[for=edition_delivered_on]', this.$el);
    this.$locationFieldEls = $('#edition_location, label[for=edition_location]', this.$el);

    this.$speechTypeSelect.change(this.updateSpeechHeaders);
    this.updateSpeechHeaders();
  }

  AdminSpeechesForm.prototype.updateSpeechHeaders = function updateSpeechHeaders() {
    var chosenType = this.$speechTypeSelect.val() || '';
    var labels = this.speechTypeLabels[chosenType];

    this.$creatorLabel.text(labels.ownerGroup.speaker);
    this.$createdDateLabel.text(labels.publishedExternallyLabel);

    if (labels.locationRelevant) {
      this.$locationFieldEls.show();
    } else {
      this.$locationFieldEls.hide();
    }
  };

  GOVUK.AdminSpeechesForm = AdminSpeechesForm;
}());
