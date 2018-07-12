(function(Modules) {
  "use strict";

  Modules.TaxonomyTreeCheckboxes = function() {
    var ancestors = function($element) {
      var parentContentID = $element.data("parent-content-id");
      if (parentContentID) {
        var $parent = $("#" + parentContentID);
        return $parent.add(ancestors($parent));
      } else {
        return $();
      }
    };

    var descendants = function($element) {
      return $("#topic-tree-" + $element.attr("id")).find('input[type="checkbox"]');
    };

    /**
     Check all ancestor topics.
     */
    var checkAncestors = function($element) {
      ancestors($element).prop('checked', true);
    };

    /**
     Uncheck all ancestor topics.
     */
    var uncheckAncestors = function($element) {
      ancestors($element).prop('checked', false);
    };

    /**
     Uncheck all descendant topics.
     */
    var uncheckDescendants = function($element) {
      descendants($element).prop('checked', false);
    };

    /**
     Check if a sibling topic (or its children) are checked.
     If any of the siblings, children are checked we expect the sibling to be checked too.
     */
    var hasCheckedSiblings = function($element) {
      return $element.closest('.topics').find('input:checked').length > 0;
    };

    var checkboxTrackClick = function(action, options) {
      var root = window;
      root.ga('send', 'event', {
        eventCategory: options.eventCategory,
        eventAction: action,
        eventLabel: options.eventLabel,
        dimension1: options.dimension1,
        dimension2: options.dimension2,
        dimension4: options.dimension4
      });
    };

    var bindExpandAndCollapseAll = function() {
      $('#expand_all_id').click(function(event) {
        $('.topics').collapse('show');
        event.preventDefault();
      });
      $('#collapse_all_id').click(function(event) {
        $('.topics').collapse('hide');
        event.preventDefault();
      });
    };

    this.start = function(element) {
      var $element = $(element);
      var publicPath = $element.data("content-public-path");
      var contentFormat = $element.data("content-format");
      var contentId = $element.data("content-id");

      bindExpandAndCollapseAll();

      $element.on('click', 'input:checkbox', function() {
        var $checkbox = $(this);
        var checked = $checkbox.is(":checked");
        var taxonName = $checkbox.data("taxon-name");
        var options = {
          eventCategory: "pageElementInteraction",
          eventLabel: taxonName,
          dimension1: publicPath,
          dimension2: contentFormat,
          dimension4: contentId
        };
        /*
        Checking a checkbox also checks all of the ancestor taxons.
        Unchecking a checkbox also unchecks all of the ancestor taxons,
        as long as there are no other descendants of that taxon selected.
        This is because tagging to a topic implicitly affects parent topics,
        and the content could be shown to users seeking any of them.
        */
        if (checked) {
          checkboxTrackClick("checkboxClickedOn", options);
          checkAncestors($checkbox);

          $("#topic-tree-" + $checkbox.attr("id")).collapse('show');
        } else {
          checkboxTrackClick("checkboxClickedOff", options);
          uncheckDescendants($checkbox);

          if (!hasCheckedSiblings($checkbox)) {
            uncheckAncestors($checkbox);
          }
        }
      });
    };
  };

})(window.GOVUKAdmin.Modules);
