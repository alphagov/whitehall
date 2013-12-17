(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  function AdminEditionsIndex(options) {
    var self = this;
    this.$filterForm = $(options.filter_form);
    this.$searchResults = $(options.search_results);

    this.getPath = this.$filterForm.attr('action');

    $('select', this.$filterForm).change($.proxy(this.updateResults, this));
    this.$filterForm.submit(function(e) {
      e.preventDefault();
      self.updateResults();
    });

    var textFields = $('.btn-enter-wrapper').map(function() {
      return new self.TextFieldHandler({
        form: self.$filterForm,
        el: this,
        adminEditionsIndex: self
      });
    });
  }

  AdminEditionsIndex.prototype.updateResults = function updateResults() {
    this.$searchResults.fadeTo(0.4, 0.6);

    if ( this.activeRequest ) this.activeRequest.abort();
    this.activeRequest = $.ajax({
      method: 'get',
      url: this.getPath,
      data: this.$filterForm.serialize(),
      success: $.proxy(renderResults, this)
    });

    function renderResults(responseHtml) {
      this.$searchResults.fadeTo(0.1, 1.0);
      this.activeRequest = null;
      this.$searchResults.html(responseHtml);
    }
  }

  AdminEditionsIndex.prototype.TextFieldHandler = function TextFieldHandler(args) {
    var $form = $(args.form);
    var $el = $(args.el);
    var $field = $('input[type=search], input[type=text]', $el);
    var $button = $('input[type=submit]', $el);

    $field.on('change paste keydown', showCommitButton);
    $button.on('click', commitField);
    $form.on('submit', function() {$button.hide();});

    function showCommitButton() {
      $button.show();
      $button.attr('disabled', null);
    }

    function hideCommitButton() {
      $button.hide();
    }

    function commitField() {
      hideCommitButton();
      args.adminEditionsIndex.updateResults();
    }
  }

  GOVUK.AdminEditionsIndex = AdminEditionsIndex;
}());
