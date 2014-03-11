(function () {
  "use strict";
  var root = this,
      $ = root.jQuery;

  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var documentFinder = {
    // This object is re-usable. All it relies upon to work is an input
    // with an id of 'title' (though you could easily configure that),
    // a button with an id of '#find-documents', and a hidden field to
    // store the selected document's id (with a name attribute of
    // 'document_id') or edition's id (with a name attribute of 'edition_id').

    init: function() {
      this.latest_results = null;
      this.search_term_content = '';
      this.$search_term = $('input#title');
      this.$search_term.autocomplete({
        disabled: true,
        minLength: 0,
        select: function(event, ui) {
          documentFinder.selectDocFromMenu(event, ui);
        }
      });
      this.$document_id_input = this.$search_term.parents('form').find('input[name="document_id"]');
      this.$edition_id_input = this.$search_term.parents('form').find('input[name="edition_id"]');
      this.$loader_indicator = this.$search_term.siblings('img.js-loader');
      this.setupEventHandlers();
    },

    enterKeyPressed: function(event) {
      return event.which == 13;
    },

    setupEventHandlers: function() {
      var $find_button = $('#find-documents');
      $find_button.click(function(event) { documentFinder.searchForDocument() });
      this.$search_term.keypress(function(event) {
        if (documentFinder.enterKeyPressed(event)) {
          event.preventDefault();
          $find_button.click();
        }
      });
      this.$search_term.keydown(function(event) {
        documentFinder.search_term_content = $(this).val();
      });
      this.$search_term.keyup(function(event) {
        if (documentFinder.searchTermChanged()) {
          documentFinder.$search_term.autocomplete('disable');
          documentFinder.$document_id_input.val('');
          documentFinder.$edition_id_input.val('');
        }
      });
    },

    searchTermChanged: function() {
      return this.$search_term.val() != documentFinder.search_term_content;
    },

    searchForDocument: function() {
      var url = '/government/admin/document_searches.json';
      this.$loader_indicator.show();
      $.ajax(url, {
        data: { title: this.$search_term.val() },
        success: function(data, textStatus, xhr) {
          documentFinder.showSearchResults(data['results']);
        },
        error: this.showErrorMessage,
        complete: function() {
          documentFinder.$loader_indicator.hide();
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
          documentFinder.$document_id_input.val(result.document_id);
          documentFinder.$edition_id_input.val(result.id);
        }
      });
    },

    showErrorMessage: function(jqXHR, textStatus, errorThrown) {
      alert("Sorry, we couldn't find any documents. " +
            'The server said: ' + errorThrown);
    }
  }
  root.GOVUK.documentFinder = documentFinder;

}).call(this);
