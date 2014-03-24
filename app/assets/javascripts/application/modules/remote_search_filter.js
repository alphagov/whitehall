(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  function RemoteSearchFilter(params) {
    GOVUK.Proxifier.proxifyAllMethods(this);

    this.$form                  = $(params.form_element);
    this.$results               = $(params.results_element);
    this.searchUrl              = params.search_url;
    this.loadingMessageSelector = params.loading_message_holder;
    this.loadingMessageText     = params.loading_message_text;

    this.$form.find('input[type=submit]').hide();

    this.$form.find('select').on('change', this.updateResults);
    this.$form.find('input[type=text]').on('change keyup', this.updateResultsAfterDelay);
  };

  RemoteSearchFilter.prototype.UPDATE_DELAY = 300;

  RemoteSearchFilter.prototype.updateResultsAfterDelay = function updateResultsAfterDelay() {
    if (this.updateDelayTimeout) window.clearTimeout(this.updateDelayTimeout);
    this.updateDelayTimeout = window.setTimeout(this.updateResults, this.UPDATE_DELAY);
  };

  RemoteSearchFilter.prototype.updateResults = function updateResults() {
    this.renderLoadingMessage();
    $.get(this.searchUrl, this.getFilterAsQueryString(), this.handleResponse);
  };

  RemoteSearchFilter.prototype.getFilterAsQueryString = function getFilterAsQueryString() {
    return this.$form.serialize();
  };

  RemoteSearchFilter.prototype.renderLoadingMessage = function renderLoadingMessage() {
    var $message = $('<p></p>').html(this.loadingMessageText);
    $(this.loadingMessageSelector).empty().append($message);
  };

  RemoteSearchFilter.prototype.handleResponse = function handleResponse(responseHtml, textStatus, jqXHR) {
    this.$results.html(responseHtml);
  };

  GOVUK.RemoteSearchFilter = RemoteSearchFilter;
})();
