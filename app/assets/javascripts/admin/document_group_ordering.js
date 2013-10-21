(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {}

  function DocumentGroupOrdering(params) {
    this.postURL = params.post_url + '.json';

    $(params.selector).each($.proxy(function(i, docList) {
      this.documentGroups.push(new this.DocumentGroup(this, docList));
    }, this));
  }

  DocumentGroupOrdering.prototype.documentGroups = [];
  DocumentGroupOrdering.prototype.SPINNER_TEMPLATE = '<div class="loading-spinner"></div>';

  DocumentGroupOrdering.prototype.getPostData = function getPostData() {
    var postData = { groups: [] };

    for(var i=0; i<this.documentGroups.length; i++) {
      postData.groups.push({
        id: this.documentGroups[i].groupID(),
        document_ids: this.documentGroups[i].documentIDs()
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
  }

  window.GOVUK.DocumentGroupOrdering = DocumentGroupOrdering;
})();
