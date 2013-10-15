(function ($) {
  window.GOVUK = window.GOVUK || {}
  window.GOVUK.Admin = window.GOVUK.Admin || {}

  window.GOVUK.Admin.DocumentGroupOrdering = function DocumentGroupOrdering() {
    var self = this;
    var documentGroups = [],
        SPINNER_TEMPLATE = '<div class="loading-spinner"></div>',
        loading_spinner,
        postURL;

    init();

    function init() {
      var form = $('#save-group-membership-changes-form');
      postURL = form.attr('action')+".json";

      $('.document-list').each(function(i, docList) {
        documentGroups.push(new DocumentGroup(docList));
      });
    }

    function getPostData() {
      var postData = { groups: [] };

      for(var i=0; i<documentGroups.length; i++) {
        postData.groups.push({
          id: documentGroups[i].groupID(),
          document_ids: documentGroups[i].documentIDs()
        });
      }
      return postData;
    }

    function doPost() {
      $.post(postURL, getPostData(), onPostComplete, "json");

      function onPostComplete() {
        loadingSpinner.remove();
      }
    }

    function DocumentGroup(documentList) {
      documentList = $(documentList);

      this.groupID = function groupID() {
        return documentList.data('group-id');
      }

      this.documentIDs = function documentIDs() {
        return documentList.find("input[name='documents[]']").map(function(i, input) {
          return input.value;
        }).toArray();
      }

      documentList.sortable({
        opacity: 0.5,
        distance: 5,
        axis: 'y',
        connectWith: '.document-list',
        stop: onDrop
      });

      function onDrop(e, ui) {
        loadingSpinner = $(SPINNER_TEMPLATE);
        ui.item.append(loadingSpinner);
        doPost();
      }
      // Expose this for tests.
      self.__onDrop = onDrop;
    }
  };

  window.GOVUK.Admin.DocumentGroupOrdering.init = function init() {
    window.documentGroupOrdering = new window.GOVUK.Admin.DocumentGroupOrdering();
  }
})(jQuery);
