(function(Modules) {
  "use strict";

  Modules.BreadcrumbPreview = function() {
    var preview = this;

    preview.fetchCheckedCheckboxes = function() {
      return $('.topic-tree :checked');
    };

    preview.buildBreadcrumbsStructure = function(checkboxes) {
      var structure = $.map(checkboxes, function(checkbox) {
        var $checkbox = $(checkbox);
        var ancestors = $checkbox.data('ancestors').split('|');

        return {
          checkbox: checkbox,
          ancestors: ancestors
        };
      });

      return structure;
    };

    preview.renderUpdatedBreadcrumbs = function(element) {
      var checkboxes = preview.fetchCheckedCheckboxes();
      var breadcrumbsArray = preview.buildBreadcrumbsStructure(checkboxes);
      var breadcrumbsToDisplay = preview.filterBreadcrumbs(breadcrumbsArray);

      if (breadcrumbsToDisplay.length === 0) {
        $(element).removeClass("content").removeClass("content-bordered");
        $(element).addClass("no-content").addClass("no-content-bordered");
        $(element).text("No topics - please add a topic before publishing");
      } else {
        $(element).addClass("content").addClass("content-bordered");
        $(element).removeClass("no-content").removeClass("no-content-bordered");

        $(element).mustache(
          'admin/shared/tagging/_breadcrumb_list',
          { breadcrumbs: breadcrumbsToDisplay }
        );
        $('.deselect-taxon-button').each(function(idx, button){
          // Toggle the state of the relevant checkbox
          $(button).on("click", function() {
            $(breadcrumbsToDisplay[idx].checkbox).trigger("click");
          });
        });
      }
    };

    preview.filterBreadcrumbs = function(breadcrumbs) {
      var longestFirst = breadcrumbs.sort(function (a, b) {
        return b.ancestors.length - a.ancestors.length;
      });

      var breadcrumbsToDisplay = [];

      $.each(longestFirst, function(index, breadcrumb) {
        var visited = false;

        $.each(breadcrumbsToDisplay, function(index, visitedBreadcrumb) {
          var breadcrumbString = JSON.stringify(breadcrumb.ancestors);
          var visitedBreadcrumbString = JSON.stringify(
            visitedBreadcrumb.ancestors.slice(0, breadcrumb.ancestors.length)
          );

          if (breadcrumbString === visitedBreadcrumbString) {
            visited = true;
          }
        });

        if (!visited) {
          breadcrumbsToDisplay.push(breadcrumb);
        }
      });

      return breadcrumbsToDisplay;
    };

    preview.start = function(element) {
      $(element).removeClass('hidden');

      var $topicTree = $('.topic-tree');

      $topicTree.on('change', function() {
        preview.renderUpdatedBreadcrumbs(element);
      });

      $topicTree.trigger('change');
    };
  };
})(window.GOVUKAdmin.Modules);
