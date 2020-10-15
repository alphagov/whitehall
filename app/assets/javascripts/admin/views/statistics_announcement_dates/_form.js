(function () {
  'use strict'
  window.GOVUK = window.GOVUK || {}

  var StatisticsAnnouncementDateForm = {
    init: function (modelName) {
      this.modelName = modelName
      this.$precisionInputs = $('input[name="' + modelName + '[precision]"]')
      this.$confirmedCheckbox = $('input[name="' + modelName + '[confirmed]"]')

      // Note that the missing ] here is intentional
      // Release date fields look like [release_date2i], [release_date3i], etc.
      this.$releaseDateInputs = $('select[name*="' + modelName + '[release_date"]')

      // Date examples
      this.$exactExample = $('.js-example-exact')
      this.$oneMonthExample = $('.js-example-one-month')
      this.$twoMonthExample = $('.js-example-two-month')
      this.$provisionalLabels = $('.js-label-one-month, .js-label-two-month')
      this.$confirmedLabel = $('.js-label-exact')
      this.$releaseDateInputs.on('change', this.generateExampleDates)

      this.$confirmedCheckbox.on('click', this.togglePrecision)
      this.togglePrecision.apply(this.$confirmedCheckbox)
    },

    togglePrecision: function () {
      var that = StatisticsAnnouncementDateForm

      if ($(this).is(':checked')) {
        that.fixToExactPrecision()
        that.hidePrecisionChoice()
      } else {
        that.showPrecisionChoice()
      }

      that.generateExampleDates()
    },

    generateExampleDates: function () {
      var that = StatisticsAnnouncementDateForm
      var date = that.getDateFromRecentDateFields()
      var dateStatus = that.$confirmedCheckbox.is(':checked') ? ' (confirmed)' : ' (provisional)'

      that.updateExampleDates(date, dateStatus)
    },

    getDateFromRecentDateFields: function () {
      var year,
        month,
        day,
        hours,
        minutes

      StatisticsAnnouncementDateForm.$releaseDateInputs.each(function (i) {
        var value = parseInt($(this).val(), 10)

        switch (i) {
          case 0:
            year = value
            break
          case 1:
            month = value - 1
            break
          case 2:
            day = value
            break
          case 3:
            hours = value
            break
          case 4:
            minutes = value
            break
        }
      })

      return new Date(year, month, day, hours, minutes)
    },

    updateExampleDates: function (date, status) {
      var that = StatisticsAnnouncementDateForm
      var monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December']
      var time = getTime(date)
      var dateNextMonth

      // 5 September 2014 4:03pm
      that.$exactExample.text(
        date.getDate() + ' ' +
          monthNames[date.getMonth()] + ' ' +
          date.getFullYear() + ' ' +
          time +
          status)

      // September 2014
      that.$oneMonthExample.text(
        monthNames[date.getMonth()] + ' ' +
          date.getFullYear() +
          status)

      dateNextMonth = new Date(date.getTime())
      dateNextMonth.setMonth(date.getMonth() + 1)

      // September to October 2014
      // December to January 2015
      that.$twoMonthExample.text(
        monthNames[date.getMonth()] + ' to ' +
        monthNames[dateNextMonth.getMonth()] + ' ' +
        dateNextMonth.getFullYear() +
        status)

      // via http://stackoverflow.com/questions/8888491
      function getTime (date) {
        var hours = date.getHours()
        var minutes = date.getMinutes()
        var ampm = (hours >= 12) ? 'pm' : 'am'

        hours = hours % 12
        if (hours === 0) {
          hours = 12
        }

        if (minutes < 10) {
          minutes = '0' + minutes
        }

        return hours + ':' + minutes + ampm
      }
    },

    fixToExactPrecision: function () {
      var that = StatisticsAnnouncementDateForm
      $('input[name="' + that.modelName + '[precision]"][value="0"]').prop('checked', true)
    },

    hidePrecisionChoice: function () {
      var that = StatisticsAnnouncementDateForm
      that.$provisionalLabels.hide()
      that.$confirmedLabel.addClass('block-label-read-only')
    },

    showPrecisionChoice: function () {
      var that = StatisticsAnnouncementDateForm
      that.$provisionalLabels.show()
      that.$confirmedLabel.removeClass('block-label-read-only')
    }
  }

  GOVUK.StatisticsAnnouncementDateForm = StatisticsAnnouncementDateForm
}())
