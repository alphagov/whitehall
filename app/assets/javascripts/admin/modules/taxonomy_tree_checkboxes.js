(function(Modules) {
  "use strict";

  Modules.TaxonomyTreeCheckboxes = function() {
    var taxonomyTreeHelper = window.GOVUK.taxonomyTreeHelper;

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
            $('.level-one-taxon').collapse('show');
            event.preventDefault()
        });
        $('#collapse_all_id').click(function(event) {
            $('.level-one-taxon').collapse('hide');
            event.preventDefault()
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
          taxonomyTreeHelper.checkAncestors(this);
        } else {
          checkboxTrackClick("checkboxClickedOff", options);
          taxonomyTreeHelper.uncheckDescendants(this);

          if (!taxonomyTreeHelper.hasCheckedSiblings(this)) {
            taxonomyTreeHelper.uncheckAncestors(this);
          }
        }
      });
    };
  };

})(window.GOVUKAdmin.Modules);
