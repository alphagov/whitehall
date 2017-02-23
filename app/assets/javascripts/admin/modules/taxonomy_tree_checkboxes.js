(function(Modules) {
  "use strict";

  Modules.TaxonomyTreeCheckboxes = function() {

    var ancestors = function(element) {
      var $parents = $(element).parents('.topics,.topic-tree');
      return $parents.prev('p').find('input[type="checkbox"]');
    };

    var descendants = function(element) {
      return $(element).closest('p').next('.topics').find('input[type="checkbox"]');
    };

    /**
     Check all ancestor topics.
     */
    var checkAncestors = function(element) {
      ancestors(element).prop('checked', true);
    };

    /**
     Uncheck all ancestor topics.
     */
    var uncheckAncestors = function(element) {
      ancestors(element).prop('checked', false);
    };

    /**
     Uncheck all descendant topics.
     */
    var uncheckDescendants = function(element) {
      descendants(element).prop('checked', false);
    };

    /**
     Check if a sibling topic (or its children) are checked.
     If any of the siblings, children are checked we expect the sibling to be checked too.
     */
    var hasCheckedSiblings = function(element) {
      var $p = $(element).closest('.topics').children('p');
      var $checkedSiblings = $p.find('input:checked');
      return $checkedSiblings.length > 0;
    };

    var checkboxTrackClick = function(action, options) {
      var root = window;
      root.ga('send', 'event', {
        eventCategory: options.eventCategory,
        eventAction: action,
        eventLabel: options.eventLabel,
        eventValue: 1,
        cd1: options.cd1,
        cd2: options.cd2,
        cd4: options.cd4
      });
    };

    this.start = function(element) {
      var $element = $(element);
      var publicPath = $element.data("content-public-path");
      var contentFormat = $element.data("content-format");
      var contentId = $element.data("content-id");

      $element.on('click', 'input:checkbox', function() {
        var $checkbox = $(this);
        var checked = $checkbox.is(":checked");
        var taxonName = $checkbox.data("taxon-name");
        var options = {
          eventCategory: "pageElementInteraction",
          eventLabel: taxonName,
          cd1: publicPath,
          cd2: contentFormat,
          cd4: contentId
        }
        /*
        Checking a checkbox also checks all of the ancestor taxons.
        Unchecking a checkbox also unchecks all of the ancestor taxons,
        as long as there are no other descendants of that taxon selected.
        This is because tagging to a topic implicitly affects parent topics,
        and the content could be shown to users seeking any of them.
        */
        if (checked) {
          checkboxTrackClick("checkboxClickedOn", options);
          checkAncestors(this);
        } else {
          checkboxTrackClick("checkboxClickedOff", options);
          uncheckDescendants(this);

          if (!hasCheckedSiblings(this)) {
            uncheckAncestors(this);
          }
        }
      });
    };
  };

})(window.GOVUKAdmin.Modules);
