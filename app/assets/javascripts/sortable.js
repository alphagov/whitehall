(function ($) {
  var _enableSortable = function() {
    var fieldset = $(this);
    var list = $("<ul></ul>");
    fieldset.children("label").each(function(i, label) {
      var li = $('<li class="sort_item"></li>');
      li.append(label);
      list.append(li);
    })
    fieldset.children("input").hide();
    fieldset.after(list);
    list.sortable({
      delay: 250,
      update: function(event, ui) {
        list.children(".sort_item").each(function(index, li) {
          var input_id = $(li).find("label").attr("for");
          var input = $("#" + input_id)
          input.val(index);
        })
      }
    });
  }

  $.fn.extend({
    enableSortable: _enableSortable
  });
})(jQuery);

jQuery(function() {
  jQuery(".sortable").enableSortable();
})