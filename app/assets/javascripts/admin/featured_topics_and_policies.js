(function($) {
  $(function() {
    var toggle_topics_and_policies = function() {
      var elem = $(this);
      var target = elem.parent().data('itemType');
      elem.parents('.well').find('.featured-item-type-pane').hide();
      elem.parents('.well').find('.featured-item-type-pane[data-item-type='+target+']').show();
    };
    // know how many lists to expect
    var counter = $('.featured-topics-and-policies-items .featured-item-type-pane .chzn-select-no-deselect').length;
    $('.featured-topics-and-policies-items .featured-item-type-pane .chzn-select-no-deselect').on('liszt:ready', function() {
      // count how many are ready
      counter--;
      if (counter < 1) {
        // once all lists are ready, toggle to hide the unchosen ones
        // this avoids hidden ones being tiny and wee
        $(this).parents('.featured-topics-and-policies-items').find('.featured-item-type input[type=radio][checked]').each(toggle_topics_and_policies);
      }
    })
    $(".featured-topics-and-policies-items .featured-item-type input[type=radio]").change(toggle_topics_and_policies);
    $(".featured-topics-and-policies-items label[for$=ordering]").hide();
  })
})(jQuery);