(function(Modules) {
  "use strict";

  Modules.BreadcrumbPreview = function() {
    var that = this;

    that.fetchCheckedCheckboxes = function() {
      return $('.topic-tree :checked');
    };

    that.buildBreadcrumbsStructure = function(checkboxes) {
      var structure = $.map(checkboxes, function(checkbox) {
        var $checkbox = $(checkbox);
        var ancestors = $checkbox.data('ancestors').split('|');

        return [ancestors];
      });

      return structure;
    };

    that.filterBreadcrumbs = function(breadcrumbs) {
      var longestFirst = breadcrumbs.sort(function (a, b) {
        return b.length - a.length;
      });

      var breadcrumbsToDisplay = [];

      $.each(longestFirst, function(index, breadcrumb) {
        var visited = false;

        $.each(breadcrumbsToDisplay, function(index, visitedBreadcrumb) {
          var breadcrumbString = JSON.stringify(breadcrumb);
          var visitedBreadcrumbString = JSON.stringify(visitedBreadcrumb.slice(0, breadcrumb.length));

          if (breadcrumbString === visitedBreadcrumbString) {
            visited = true;
          }
        });

        if (!visited) {
          breadcrumbsToDisplay.push(breadcrumb);
        }
      });

      return breadcrumbsToDisplay;
    }

    that.start = function(element) {
      var $topicTree = $('.topic-tree');
      $(element).removeClass('hidden');

      $topicTree.on('change', function() {
        var checkboxes = that.fetchCheckedCheckboxes();
        var breadcrumbsArray = that.buildBreadcrumbsStructure(checkboxes);
        var breadcrumbsToDisplay = that.filterBreadcrumbs(breadcrumbsArray);

        $(element).mustache(
          'admin/edition_tags/_breadcrumb_list',
          { breadcrumbs: breadcrumbsToDisplay }
        );
      });

      $topicTree.trigger('change');
    }
  };
})(window.GOVUKAdmin.Modules);
