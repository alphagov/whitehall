(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  function DocumentGroupOrdering(params) {
    this.postURL = params.post_url + '.json';
    this.selector = params.selector;
    this.groupButtons = $(params.group_buttons);
    this.groupContainer = $(params.group_container_selector);

    this.updateDocumentGroups();
    this.initializeGroupOrdering();
  }

  DocumentGroupOrdering.prototype.documentGroups = [];
  DocumentGroupOrdering.prototype.SPINNER_TEMPLATE = '<div class="loading-spinner"></div>';

  DocumentGroupOrdering.prototype.initializeGroupOrdering = function initializeGroupOrdering() {
    var reorderButton = this.groupButtons.find('.js-reorder'),
        finishReorderButton = this.groupButtons.find('.js-finish-reorder');
    reorderButton.click($.proxy(function(e) {
      e.preventDefault();
      $(e.target).hide();
      finishReorderButton.show();
      this.groupContainer.sortable({
        opacity: 0.5,
        distance: 5,
        axis: 'y',
        stop: $.proxy(this.onGroupDrop, this)
      });
    }, this)).show();
    finishReorderButton.hide().click($.proxy(function(e) {
      e.preventDefault();
      $(e.target).hide();
      reorderButton.show();
      this.groupContainer.sortable('destroy');
    }, this));
  };

  DocumentGroupOrdering.prototype.updateDocumentGroups = function updateDocumentGroups() {
    this.documentGroups = $(this.selector).map($.proxy(function(i, docList) {
      return new this.DocumentGroup(this, docList);
    }, this));
  };

  DocumentGroupOrdering.prototype.getPostData = function getPostData() {
    var postData = { groups: [] };

    for(var i=0; i<this.documentGroups.length; i++) {
      postData.groups.push({
        id: this.documentGroups[i].groupID(),
        document_ids: this.documentGroups[i].documentIDs(),
        order: i
      });
    }
    return postData;
  };

  DocumentGroupOrdering.prototype.doPost = function doPost() {
    $.post(this.postURL, this.getPostData(), $.proxy(onPostComplete, this), "json");

    function onPostComplete() {
      this.loadingSpinner.remove();
    }
  };

  DocumentGroupOrdering.prototype.onDrop = function onDrop(e, ui) {
    this.loadingSpinner = $(this.SPINNER_TEMPLATE);
    ui.item.append(this.loadingSpinner);
    this.doPost();
  };

  DocumentGroupOrdering.prototype.onGroupDrop = function onGroupDrop(e, ui) {
    this.loadingSpinner = $(this.SPINNER_TEMPLATE);
    ui.item.append(this.loadingSpinner);
    this.updateDocumentGroups();
    this.doPost();
  };

  DocumentGroupOrdering.prototype.DocumentGroup = function DocumentGroup(document_group_ordering, documentList) {
    documentList = $(documentList);

    this.groupID = function groupID() {
      return documentList.data('group-id');
    };

    this.documentIDs = function documentIDs() {
      return documentList.find("input[name='documents[]']").map(function(i, input) {
        return input.value;
      }).toArray();
    };

    documentList.sortable({
      opacity: 0.5,
      distance: 5,
      axis: 'y',
      connectWith: '.document-list',
      stop: $.proxy(document_group_ordering.onDrop, document_group_ordering)
    });
  };

  window.GOVUK.DocumentGroupOrdering = DocumentGroupOrdering;
}());
