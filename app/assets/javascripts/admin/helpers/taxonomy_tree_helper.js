(function () {
    "use strict";
    window.GOVUK = window.GOVUK || {};

    window.GOVUK.taxonomyTreeHelper = {
        ancestors: function ancestors(element) {
            var $parents = $(element).parents('.topics,.topic-tree');
            return $parents.prev('p').find('input[type="checkbox"]');
        },

        descendants: function descendants(element) {
            return $(element).closest('p').next('.topics').find('input[type="checkbox"]');
        },

        /**
         Check all ancestor topics.
         */
        checkAncestors: function checkAncestors(element) {
            this.ancestors(element).prop('checked', true);
        },

        /**
         Uncheck all ancestor topics.
         */
        uncheckAncestors: function uncheckAncestors(element) {
            this.ancestors(element).prop('checked', false);
        },

        /**
         Uncheck all descendant topics.
         */
        uncheckDescendants: function uncheckDescendants(element) {
            this.descendants(element).prop('checked', false);
        },

        /**
         Check if a sibling topic (or its children) are checked.
         If any of the siblings, children are checked we expect the sibling to be checked too.
         */
        hasCheckedSiblings: function hasCheckedSiblings(element) {
            var $p = $(element).closest('.topics').children('p');
            var $checkedSiblings = $p.find('input:checked');
            return $checkedSiblings.length > 0;
        }
    };
}());
