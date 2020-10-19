(function ($) {
  var _enableSortable = function () {
    $(this).each(function () {
      var fieldset = $(this)
      var orderLabelFinder = fieldset.data('orderingLabelSelector') || 'label'
      var list = $('<ul class="list-unstyled"></ul>')
      fieldset.find('input.ordering').hide()
      fieldset.children('div').each(function (i, item) {
        var li = $('<li class="sort_item"></li>')
        li.append(item)
        list.append(li)
      })
      fieldset.after(list)
      list.sortable({
        distance: 15,
        opacity: 0.5,
        update: function (event, ui) {
          list.children('.sort_item').each(function (index, li) {
            var inputId = $(li).find(orderLabelFinder).attr('for')
            var input = $('#' + inputId)
            input.val(index)
          })
        },
        placeholder: 'well sortable-drop-target',
        axis: 'y'
      })
    })
  }

  var _enableConnectedSortable = function (extraUpdateFunction) {
    $(this).each(function () {
      var fieldset = $(this)
      var list = $('<ul class="connected-sortable"></ul>')
      fieldset.find('input.ordering').hide()
      fieldset.find('input.lead').each(function (i, item) {
        var $item = $(item)
        $item.hide()
        $item.siblings('[for=' + $item.attr('id') + ']').hide()
      })
      fieldset.children('div').each(function (i, item) {
        var li = $('<li class="sort_item"></li>')
        li.append(item)
        list.append(li)
      })
      fieldset.after(list)
      list.sortable({
        distance: 15,
        opacity: 0.5,
        update: extraUpdateFunction,
        placeholder: 'well sortable-drop-target',
        connectWith: '.connected-sortable',
        dropOnEmpty: true,
        forcePlaceholderSize: true
      }).disableSelection()
    })
  }

  $.fn.extend({
    enableConnectedSortable: _enableConnectedSortable,
    enableSortable: _enableSortable
  })
})(jQuery)

jQuery(function ($) {
  $('.sortable').enableSortable()
  $('#lead_organisation_sortable').enableConnectedSortable(function (event, ui) {
    $('#lead_organisation_sortable').siblings('.connected-sortable').children('.sort_item').each(function (index, li) {
      $(li).find('input.ordering').val(index)
    })
    ui.item.find('input.lead').val(1)
  })
  $('#organisation_sortable').enableConnectedSortable(function (event, ui) {
    $('#organisation_sortable').siblings('.connected-sortable').children('.sort_item').each(function (index, li) {
      $(li).find('input.ordering').val('')
    })
    $('#lead_organisation_sortable').siblings('.connected-sortable').children('.sort_item').each(function (index, li) {
      $(li).find('input.ordering').val(index)
    })
    ui.item.find('input.lead').val(0)
  })
})
