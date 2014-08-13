(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  var StatisticsAnnouncementDateForm = {
    init: function(model_name) {
      this.model_name = model_name;
      this.$precisionInputs = $('input[name="' + model_name +'[precision]"]');
      this.$confirmedCheckbox = $('input[name="' + model_name +'[confirmed]"]');

      // Note that the missing ] here is intentional
      // Release date fields look like [release_date2i], [release_date3i], etc.
      this.$releaseDateInputs = $('select[name*="' + model_name +'[release_date"]');

      // Date examples
      this.$exactExample = $('.js-example-exact');
      this.$oneMonthExample = $('.js-example-one-month');
      this.$twoMonthExample = $('.js-example-two-month');
      this.$provisionalLabels = $('.js-label-one-month, .js-label-two-month');
      this.$releaseDateInputs.on('change', this.generateExampleDates);

      this.$confirmedCheckbox.on('click', this.togglePrecision);
      this.togglePrecision.apply(this.$confirmedCheckbox);
    },

    togglePrecision: function() {
      var that = StatisticsAnnouncementDateForm;

      if ($(this).is(':checked')) {
        that.fixToExactPrecision();
        that.disablePrecisionChoice();
      } else {
        that.enablePrecisionChoice();
      }

      that.generateExampleDates();
    },

    generateExampleDates: function() {
      var that = StatisticsAnnouncementDateForm,
          date = that.getDateFromRecentDateFields(),
          dateStatus = that.$confirmedCheckbox.is(':checked') ? ' (confirmed)' : ' (provisional)';

      that.updateExampleDates(date, dateStatus);
    },

    getDateFromRecentDateFields: function() {
      var date = new Date();

      StatisticsAnnouncementDateForm.$releaseDateInputs.each(function(i) {
        var value = parseInt($(this).val(), 10);

        switch(i) {
          case 0:
            date.setFullYear(value);
            break;
          case 1:
            date.setMonth(value - 1);
            break;
          case 2:
            date.setDate(value);
            break;
          case 3:
            date.setHours(value);
            break;
          case 4:
            date.setMinutes(value);
            break;
        }
      });

      return date;
    },

    updateExampleDates: function(date, status) {
      var that = StatisticsAnnouncementDateForm,
          monthNames = ["January", "February", "March", "April", "May", "June",
                        "July", "August", "September", "October", "November", "December" ],
          time = getTime(date),
          dateNextMonth;

      // 5 September 2014 4:03pm
      that.$exactExample.text(
            date.getDate() + ' '
          + monthNames[date.getMonth()] + ' '
          + date.getFullYear() + ' '
          + time
          + status);

      // September 2014
      that.$oneMonthExample.text(
            monthNames[date.getMonth()] + ' '
          + date.getFullYear()
          + status);

      dateNextMonth = new Date(date.getTime());
      dateNextMonth.setMonth(date.getMonth() + 1);

      // September to October 2014
      // December to January 2015
      that.$twoMonthExample.text(
          monthNames[date.getMonth()] + ' to '
        + monthNames[dateNextMonth.getMonth()] + ' '
        + dateNextMonth.getFullYear()
        + status);

      // via http://stackoverflow.com/questions/8888491
      function getTime(date) {
        var hours = date.getHours(),
            minutes = date.getMinutes(),
            ampm = (hours >= 12) ? 'pm' : 'am';

        hours = hours % 12;
        if (hours == 0) {
          hours = 12;
        }

        if (minutes < 10) {
          minutes = '0' + minutes;
        }

        return hours + ':' + minutes + ampm;
      }
    },

    fixToExactPrecision: function() {
      var that = StatisticsAnnouncementDateForm;
      $('input[name="' + that.model_name +'[precision]"][value="0"]').prop('checked', true);
    },

    disablePrecisionChoice: function() {
      var that = StatisticsAnnouncementDateForm;
      $('input[name="' + that.model_name +'[precision]"]').prop('disabled', true);
      that.$provisionalLabels.hide();
    },

    enablePrecisionChoice: function() {
      var that = StatisticsAnnouncementDateForm;
      $('input[name="' + that.model_name +'[precision]"]').prop('disabled', false);
      that.$provisionalLabels.show();
    }
  };

  GOVUK.StatisticsAnnouncementDateForm = StatisticsAnnouncementDateForm;
}());
