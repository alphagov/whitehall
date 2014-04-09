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

    $(window).on('popstate', this.onHistoryPopState);
  };

  RemoteSearchFilter.prototype.UPDATE_DELAY = 300;
  RemoteSearchFilter.prototype.HISTORY_REPLACE_NOT_PUSH_FOR = 2000;

  RemoteSearchFilter.prototype.updateResultsAfterDelay = function updateResultsAfterDelay() {
    if (this.updateDelayTimeout) { window.clearTimeout(this.updateDelayTimeout); }
    this.updateDelayTimeout = window.setTimeout(this.updateResults, this.UPDATE_DELAY);
  };

  RemoteSearchFilter.prototype.updateResults = function updateResults() {
    this.pushToHistory();
    this.getResultsFromRemote(this.getFilterParams());
  };

  RemoteSearchFilter.prototype.getResultsFromRemote = function getResultsFromRemote(params) {
    this.renderLoadingMessage();
    $.ajax({
      type: 'get',
      url: this.searchUrl,
      data: params,
      cache: false
    }).then(this.handleResponse);
  };

  RemoteSearchFilter.prototype.handleResponse = function handleResponse(responseHtml, textStatus, jqXHR) {
    this.$results.html(responseHtml);
  };

  RemoteSearchFilter.prototype.getFilterParams = function getFilterParams() {
    var paramsWithValues = [];
    $.each(this.$form.serializeArray(), function(_i, param) {
      if ( param.value !== '' ) { paramsWithValues.push(param); }
    });
    return paramsWithValues;
  };

  RemoteSearchFilter.prototype.urlForParams = function urlForParams(filterParams) {
    if ( filterParams.length == 0 ) {
      return this.searchUrl;
    }
    else {
      return this.searchUrl + '?' + $.param(filterParams);
    }
  };

  RemoteSearchFilter.prototype.renderLoadingMessage = function renderLoadingMessage() {
    var $message = $('<p></p>').html(this.loadingMessageText);
    $(this.loadingMessageSelector).empty().append($message);
  };

  RemoteSearchFilter.prototype.pushToHistory = function pushToHistory() {
    var filterParams = this.getFilterParams();

    if (this.historyReplaceDontPushTimeout) {
      history.replaceState(filterParams, null, this.urlForParams(filterParams));
    }
    else {
      history.pushState(filterParams, null, this.urlForParams(filterParams));
    }

    if (this.historyReplaceDontPushTimeout) { window.clearTimeout(this.historyReplaceDontPushTimeout); }
    this.historyReplaceDontPushTimeout = window.setTimeout($.proxy(function() {
      this.historyReplaceDontPushTimeout = null;
    }, this), this.HISTORY_REPLACE_NOT_PUSH_FOR);
  };

  RemoteSearchFilter.prototype.onHistoryPopState = function onHistoryPopState(event) {
    var filterParams = event.state || event.originalEvent.state;

    if ( filterParams != null ) {
      this.setFieldValues(filterParams);
      this.getResultsFromRemote(filterParams);
    }
  };

  RemoteSearchFilter.prototype.setFieldValues = function setFieldValues(filterParams) {
    filterParams = filterParams || [];
    var paramsAsHash = {}
    for (var i=0; i<filterParams.length; i++) {
      paramsAsHash[filterParams[i].name] = filterParams[i].value;
    }

    $('input:not([type=submit]), select', this.$form).each(function(_i, $field) {
      $field = $($field);
      if ( typeof paramsAsHash[$field.attr('name')] === 'undefined' ) {
        $field.val('');
      }
      else {
        $field.val(paramsAsHash[$field.attr('name')]);
      }
    });
  }

  GOVUK.RemoteSearchFilter = RemoteSearchFilter;
})();
