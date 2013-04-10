(function($) {
  $(function() {
    var toggleTopicsAndPolicies = function() {
      var elem = $(this);
      var target = elem.parent().data('itemType');
      elem.parents('.well').find('.featured-item-type-pane').hide();
      elem.parents('.well').find('.featured-item-type-pane[data-item-type='+target+']').show();
    };
    var waitForChosenToBeReadyThenToggleInitialTopcisAndPoliciesSelector = function(container) {
      // know how many lists to expect
      var counter = container.find('.featured-item-type-pane .chzn-select-no-deselect').length;
      container.find('.featured-item-type-pane .chzn-select-no-deselect').on('liszt:ready', function() {
        // count how many are ready
        counter--;
        if (counter < 1) {
          // once all lists are ready, toggle to hide the unchosen ones
          // this avoids hidden ones being tiny and wee
          container.find('.featured-item-type input[type=radio]:checked').each(toggleTopicsAndPolicies);
        }
      })
    };
    waitForChosenToBeReadyThenToggleInitialTopcisAndPoliciesSelector($('.featured-topics-and-policies-items'));
    // use a "live" selector so we pick up any and all new radio buttons
    $('.featured-topics-and-policies-items').on('change', ".featured-item-type input[type=radio]", toggleTopicsAndPolicies);
    // hide initial, cloned ones will remain hidden
    $(".featured-topics-and-policies-items label[for$=ordering]").hide();

    // the following is heavily copied from duplicate_fields.js - but we
    // have very slightly different needs: we want the clone to go onto
    // the same container (list) as the clonee, we need to trigger some
    // stuff so the chosen's get re-done correctly
    var duplicateFeaturedItems = function(e) {
      e.preventDefault();
      var $button = $(e.target),
          $set = $(".featured-topics-and-policies-items"),
          $fields = $set.find('.sort_item').last(),
          $newFields = $fields.clone();

      $newFields.find('input[type=text], textarea').val('');
      $newFields.find('label,input,textarea,select').each(function(i, el){
        var $el = $(el),
            currentName = $el.attr('name'),
            currentId = $el.attr('id'),
            currentFor = $el.attr('for'),
            index = false;

        if(currentName && currentName.match(/\[([0-9]+)\]/)){
          index = parseInt(currentName.match(/\[([0-9]+)\]/)[1], 10);
          $el.attr('name', currentName.replace('['+ index +']', '['+ (index+1) +']'));
        }
        if(currentId && currentId.match(/_([0-9]+)_/)){
          if(index === false){
            index = parseInt(currentId.match(/_([0-9]+)_/)[1], 10);
          }
          $el.attr('id', currentId.replace('_'+ index +'_', '_'+ (index+1) +'_'));
        }
        if(currentFor && currentFor.match(/_([0-9]+)_/)){
          if(index === false){
            index = parseInt(currentFor.match(/_([0-9]+)_/)[1], 10);
          }
          $el.attr('for', currentFor.replace('_'+ index +'_', '_'+ (index+1) +'_'));
        }
      });
      $fields.parent().append($newFields);

      $newFields.find('.featured-item-type-pane').show();
      // remove old chosen artifacts...
      $newFields.find('div.chzn-container').remove();
      // ...then re-chosen-ify them
      waitForChosenToBeReadyThenToggleInitialTopcisAndPoliciesSelector($newFields);
      $newFields.find('.chzn-done').removeClass('chzn-done').show().chosen();
    };
    $button = $('<a href="#">Add another</a>');
    $(".featured-topics-and-policies-items").append($button);
    $button.on('click', duplicateFeaturedItems);
  })
})(jQuery);