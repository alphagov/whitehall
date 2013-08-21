(function () {
  "use strict"
  var root = this,
      $ = root.jQuery;

  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var documentFinder = {

    init: function (selector) {
      documentFinder.$form = $(selector).find('form');
      documentFinder.$results = $(selector).find('.js-doc-finder-results');
      documentFinder.$resetLink = documentFinder.$form.find('.js-doc-finder-reset');

      documentFinder.$form
        .bind('ajax:beforeSend', documentFinder.requestSent)
        .bind('ajax:success', documentFinder.showResults)
        .bind('ajax:complete', documentFinder.reEnableForm)
        .bind('ajax:error', documentFinder.handleError);

      documentFinder.$form.find('input[type="search"]').focus();

      documentFinder.$resetLink.on('click', function() {
        documentFinder.$form.find('input[type="search"]').val('').focus();
        documentFinder.clearResults();
      });
    },

    requestSent: function() {
      documentFinder.clearResults();
      documentFinder.$form.find('.js-loading').show();
    },

    showResults: function(e, data, status, hxr) {
      documentFinder.$results.mustache('admin-document_series_memberships-_doc_finder_results', data);
      documentFinder.$resetLink.show();
    },

    reEnableForm: function() {
      documentFinder.$form.find('.js-loading').hide();
      documentFinder.$form.find('input[type="submit"]').attr('disabled', false);
    },

    handleError: function () {
      documentFinder.$results.html('<p class="error">There was an error. Please try again.</p>')
    },

    clearResults: function () {
      documentFinder.$results.html('');
      documentFinder.$resetLink.hide();
    }
  }

  root.GOVUK.documentFinder = documentFinder;
}).call(this);
