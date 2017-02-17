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

    this.start = function(element) {
      $(element).on('click', 'input:checkbox', function() {

        var checked = $(this).is(":checked");

        /*
        Checking a checkbox also checks all of the ancestor taxons.
        Unchecking a checkbox also unchecks all of the ancestor taxons,
        as long as there are no other descendants of that taxon selected.
        This is because tagging to a topic implicitly affects parent topics,
        and the content could be shown to users seeking any of them.
        */
        if (checked) {
          checkAncestors(this);
        } else {
          uncheckDescendants(this);

          if (!hasCheckedSiblings(this)) {
            uncheckAncestors(this);
          }
        }
      });
    };
  };

})(window.GOVUKAdmin.Modules);
