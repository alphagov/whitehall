(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  var StatisticsAnnouncementDateForm = {
    init: function(el) {
      this.$form = $(el);
      this.$precisionInputs = this.$form.find('input[name="statistics_announcement_date_change[precision]"]');
      this.$confirmedCheckbox = this.$form.find('#statistics_announcement_date_change_confirmed');

      this.$confirmedCheckbox.on('click', this.togglePrecision);
    },

    togglePrecision: function() {
      if ($(this).is(':checked')) {
        StatisticsAnnouncementDateForm.fixToExactPrecision();
      } else {
        StatisticsAnnouncementDateForm.enablePrecision();
      };
    },

    fixToExactPrecision: function() {
      StatisticsAnnouncementDateForm.$precisionInputs.find('#statistics_announcement_date_change_precision_0').prop('checked', true);
      StatisticsAnnouncementDateForm.$precisionInputs.prop('disabled', true);
    },

    enablePrecision: function() {
      StatisticsAnnouncementDateForm.$precisionInputs.prop('disabled', false);
    }
  };

  GOVUK.StatisticsAnnouncementDateForm = StatisticsAnnouncementDateForm;
}());
