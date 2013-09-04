(function () {
  "use strict";
  var root = this,
      $ = root.jQuery;

  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var documentSeriesDocFinder = {

    // This object is re-usable. All it relies upon to work is an input
    // with an id of 'title' (though you could easily configure that),
    // a button with an id of '#find-documents', and a hidden field to
    // store the selected document's id (with a name attribute of
    // 'document_id').

    init: function() {
      this.latest_results = null;
      this.search_term_content = '';
      this.$search_term = $('input#title');
      this.$search_term.autocomplete({
        disabled: true,
        minLength: 0,
        select: function(event, ui) {
          documentSeriesDocFinder.selectDocFromMenu(event, ui);
        }
      });
      this.$document_id_input = this.$search_term.parents('form').find('input[name="document_id"]');
      this.$loader_indicator = this.$search_term.siblings('img.js-loader');
      this.setupEventHandlers();
    },

    enterKeyPressed: function(event) {
      return event.which == 13;
    },

    setupEventHandlers: function() {
      var $find_button = $('#find-documents');
      $find_button.click(function(event) { documentSeriesDocFinder.searchForDocument() });
      this.$search_term.keypress(function(event) {
        if (documentSeriesDocFinder.enterKeyPressed(event)) {
          event.preventDefault();
          $find_button.click();
        }
      });
      this.$search_term.keydown(function(event) {
        documentSeriesDocFinder.search_term_content = $(this).val();
      });
      this.$search_term.keyup(function(event) {
        if (documentSeriesDocFinder.searchTermChanged()) {
          documentSeriesDocFinder.$search_term.autocomplete('disable');
          documentSeriesDocFinder.$document_id_input.val('');
        }
      });
    },

    searchTermChanged: function() {
      return this.$search_term.val() != documentSeriesDocFinder.search_term_content;
    },

    searchForDocument: function() {
      var url = '/government/admin/document_searches.json';
      this.$loader_indicator.show();
      $.ajax(url, {
        data: { title: this.$search_term.val() },
        success: function(data, textStatus, xhr) {
          documentSeriesDocFinder.showSearchResults(data['results']);
        },
        error: this.showErrorMessage,
        complete: function() {
          documentSeriesDocFinder.$loader_indicator.hide();
        }
      });
    },

    showSearchResults: function(results) {
      this.latest_results = results;

      var formatResults = function(data) {
        var results = [];
        $.each(data, function(i, result) { results.push(result.title) });
        return results;
      };

      this.$search_term.autocomplete('option', 'source', formatResults(results));
      this.$search_term.autocomplete('enable');
      this.$search_term.autocomplete('search', '');
    },

    selectDocFromMenu: function(event, ui) {
      $.each(this.latest_results, function(i, result) {
        if (result.title == ui.item.label) {
          documentSeriesDocFinder.$document_id_input.val(result.document_id);
        }
      });
    },

    showErrorMessage: function(jqXHR, textStatus, errorThrown) {
      alert("Sorry, we couldn't find any documents. " +
            'The server said: ' + errorThrown);
    }
  }
  root.GOVUK.documentSeriesDocFinder = documentSeriesDocFinder;

  var documentSeriesCheckboxSelector = {
    init: function() {
      $('section.group ul.controls input:checkbox').click(function() {
        var to_toggle = $(this)
          .parents('section.group')
          .find('ol.document-list input:checkbox');
        $(to_toggle).prop('checked', $(this).is(':checked'));
      });
    }
  };
  root.GOVUK.documentSeriesCheckboxSelector = documentSeriesCheckboxSelector;
}).call(this);
