(function () {
  'use strict'
  var root = this
  var $ = root.jQuery

  if (typeof root.GOVUK === 'undefined') { root.GOVUK = {} }

  var documentCollectionCheckboxSelector = {
    init: function () {
      $('section.group ul.controls input:checkbox').click(function () {
        var toToggle = $(this)
          .parents('section.group')
          .find('ol.document-list input:checkbox')
        $(toToggle).prop('checked', $(this).is(':checked'))
      })
    }
  }
  root.GOVUK.documentCollectionCheckboxSelector = documentCollectionCheckboxSelector
}).call(this)
