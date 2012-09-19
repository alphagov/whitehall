(function ($) {
  var _enableSortable = function() {
    $(this).each(function() {
      var fieldset = $(this);
      var list = $("<ul></ul>");
      fieldset.find("input.ordering").hide();
      fieldset.children("div").each(function(i, item) {
        var li = $('<li class="sort_item"></li>');
        li.append(item);
        list.append(li);
      })
      fieldset.after(list);
      list.sortable({
        distance: 15,
        opacity: 0.5,
        update: function(event, ui) {
          list.children(".sort_item").each(function(index, li) {
            var input_id = $(li).find("label").attr("for");
            var input = $("#" + input_id)
            input.val(index);
          })
        },
        placeholder: "well sortable-drop-target",
        axis: "y"
      });
    })
  }

  $.fn.extend({
    enableSortable: _enableSortable
  });
})(jQuery);

jQuery(function($) {
  $(".sortable").enableSortable();
})
