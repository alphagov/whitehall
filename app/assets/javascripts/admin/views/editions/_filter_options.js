(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  function FilterOptions(options) {
    GOVUK.Proxifier.proxifyAllMethods(this);

    var self = this;
    this.$filterForm = $(options.filter_form);
    this.$searchResults = $(options.search_results);

    this.getPath = this.$filterForm.attr('action');

    $('select', this.$filterForm).change(this.updateResultsWithNoRepeatProtection);
    this.$filterForm.submit(function(e) {
      e.preventDefault();
      self.updateResults();
    });

    var textFields = $('.btn-enter-wrapper').map(function() {
      return new self.TextFieldHandler({
        form: self.$filterForm,
        el: this,
        filterOptions: self
      });
    });
  }

  FilterOptions.prototype.updateResultsWithNoRepeatProtection = function updateResultsWithNoRepeatProtection() {
    if ( this.updateTimeout ) window.clearTimeout(this.updateTimeout);
    this.updateTimeout = window.setTimeout(this.updateResults, 10);
  };

  FilterOptions.prototype.updateResults = function updateResults(skipAntiRepeat) {
    // ### HACK ###
    // This section is a temporary solution to avoid querying for "All organisations" 
    // without a title or a slug. This query leads to a server timeout.
    // https://trello.com/c/NE2xfVo8/539-bad-gateway-error-for-featured-documents-in-whitehall-admin-1-day

    var formData = this.$filterForm.serializeArray();

    if(typeof(formData[2]) !== 'undefined'){
      var title = formData[0]['value'];
      var organisation = formData[2]['value'];

      var allOrganisationsSelected = !organisation
      var noTitleSpecified = !title
    }

    if (noTitleSpecified && allOrganisationsSelected) {
      $('#title_filter').append("<p class=\'warning\'>You need to specify a title or a slug when searching in All Organisations</p>");
    } else {
      $('#title_filter .warning').remove();
      // ### END HACK ###
      this.$searchResults.fadeTo(0.4, 0.6);
      if ( this.activeRequest ) this.activeRequest.abort();
      this.activeRequest = $.ajax({
        method: 'get',
        url: this.getPath,
        data: this.$filterForm.serialize(),
        success: this.renderResults
      });
    };

  };

  FilterOptions.prototype.renderResults = function renderResults(resultHtml) {
    this.$searchResults.fadeTo(0.1, 1.0);
    this.activeRequest = null;
    this.$searchResults.html(resultHtml);
  };

  FilterOptions.prototype.TextFieldHandler = function TextFieldHandler(args) {
    var filterOptions = args.filterOptions
    var $form = $(args.form);
    var $el = $(args.el);
    var $field = $('input[type=search], input[type=text]', $el);
    var $button = $('input[type=submit]', $el);

    $field.on('change paste keydown', showCommitButton);
    $button.on('click', commitField);
    $form.on('submit', hideCommitButton);

    function showCommitButton() {
      $button.show();
      $button.attr('disabled', null);
    }

    function hideCommitButton() {
      $button.hide();
    }

    function commitField() {
      hideCommitButton();
      filterOptions.updateResultsWithNoRepeatProtection();
    }
  };

  GOVUK.FilterOptions = FilterOptions;
}());
