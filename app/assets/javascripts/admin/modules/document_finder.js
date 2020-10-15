(function () {
  'use strict'
  var root = this
  var $ = root.jQuery

  if (typeof root.GOVUK === 'undefined') { root.GOVUK = {} }

  var documentFinder = {
    // This object is re-usable. All it relies upon to work is an input
    // with an id of 'title' (though you could easily configure that),
    // a button with an id of '#find-documents', and a hidden field to
    // store the selected document's id (with a name attribute of
    // 'document_id') or edition's id (with a name attribute of 'edition_id').

    init: function (params) {
      this.noResultsMessage = params.no_results_message || 'No results matching search criteria'
      delete params.no_results_message
      this.additionalFilterParams = params
      this.latestResults = null
      this.searchTermContent = ''
      this.$searchTerm = $('input#title')
      this.$searchTerm.autocomplete({
        disabled: true,
        minLength: 0,
        select: function (event, ui) {
          documentFinder.selectDocFromMenu(event, ui)
        }
      })
      this.$documentIdInput = this.$searchTerm.parents('form').find('input[name="document_id"]')
      this.$editionIdInput = this.$searchTerm.parents('form').find('input[name="edition_id"]')
      this.$loaderIndicator = this.$searchTerm.siblings('img.js-loader')
      this.setupEventHandlers()
    },

    enterKeyPressed: function (event) {
      return event.which === 13
    },

    setupEventHandlers: function () {
      var $findButton = $('#find-documents')
      $findButton.click(function (event) { documentFinder.searchForDocument() })
      this.$searchTerm.keypress(function (event) {
        if (documentFinder.enterKeyPressed(event)) {
          event.preventDefault()
          $findButton.click()
        }
      })
      this.$searchTerm.keydown(function (event) {
        documentFinder.searchTermContent = $(this).val()
      })
      this.$searchTerm.keyup(function (event) {
        if (documentFinder.searchTermChanged()) {
          documentFinder.$searchTerm.autocomplete('disable')
          documentFinder.$documentIdInput.val('')
          documentFinder.$editionIdInput.val('')
        }
      })
    },

    searchTermChanged: function () {
      return this.$searchTerm.val() !== documentFinder.searchTermContent
    },

    searchForDocument: function () {
      var url = '/government/admin/document_searches.json'
      this.$loaderIndicator.show()
      $.ajax(url, {
        data: $.extend({ title: this.$searchTerm.val() }, this.additionalFilterParams),
        success: function (data, textStatus, xhr) {
          documentFinder.showSearchResults(data.results)
        },
        error: this.showErrorMessage,
        complete: function () {
          documentFinder.$loaderIndicator.hide()
        }
      })
    },

    showSearchResults: function (results) {
      this.latestResults = results
      var noResultsMessage = this.noResultsMessage

      var formatResults = function (data) {
        var results = []
        $.each(data, function (i, result) { results.push(result.title) })
        if (results.length) { return results } else { return [noResultsMessage] }
      }

      this.$searchTerm.autocomplete('option', 'source', formatResults(results))
      this.$searchTerm.autocomplete('enable')
      this.$searchTerm.autocomplete('search', '')
    },

    selectDocFromMenu: function (event, ui) {
      $.each(this.latestResults, function (i, result) {
        if (result.title === ui.item.label) {
          documentFinder.$documentIdInput.val(result.document_id).trigger('change')
          documentFinder.$editionIdInput.val(result.id).trigger('change')
        }
      })
    },

    showErrorMessage: function (jqXHR, textStatus, errorThrown) {
      alert("Sorry, we couldn't find any documents. " +
            'The server said: ' + errorThrown)
    }
  }
  root.GOVUK.documentFinder = documentFinder
}).call(this)
