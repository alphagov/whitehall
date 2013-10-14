(function ($) {
  window.GOVUK = window.GOVUK || {}
  window.GOVUK.Admin = window.GOVUK.Admin || {}

  window.GOVUK.Admin.DocumentGroupOrdering = {
    document_groups: [],
    SPINNER_TEMPLATE: '<div class="loading-spinner"></div>',

    init: function init() {
      var form = $('#save-group-membership-changes-form');
      self.post_url = form.attr('action')+".json";

      $('.document-list').each(function(i, doc_list) {
        self.document_groups.push(new self.DocumentGroup(doc_list));
      });
    },

    get_post_data: function get_post_data() {
      var post_data = { groups: [] };

      for(var i=0; i<self.document_groups.length; i++) {
        post_data.groups.push({
          id: self.document_groups[i].group_id(),
          document_ids: self.document_groups[i].document_ids()
        });
      }
      return post_data;
    },

    do_post: function do_post() {
      $.post(self.post_url, self.get_post_data(), on_post_complete, "json");

      function on_post_complete() {
        self.loading_spinner.remove();
      }
    },

    DocumentGroup: function DocumentGroup(document_list) {
      document_list = $(document_list);

      this.group_id = function group_id() {
        return document_list.data('group-id');
      }

      this.document_ids = function document_ids() {
        return document_list.find("input[name='documents[]']").map(function(i, input) {
          return input.value;
        }).toArray();
      }

      document_list.sortable({
        opacity: 0.5,
        distance: 5,
        axis: 'y',
        connectWith: '.document-list',
        stop: on_drop
      });

      function on_drop(e, ui) {
        self.loading_spinner = $(self.SPINNER_TEMPLATE);
        ui.item.append(self.loading_spinner);
        self.do_post();
      }
    }
  };

  var self = window.GOVUK.Admin.DocumentGroupOrdering;
})(jQuery);
