(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  function MenuRenameTopicMultivariateTest(options) {
    GOVUK.MultivariateTest.call(this, options);
  }

  MenuRenameTopicMultivariateTest.prototype = Object.create(GOVUK.MultivariateTest.prototype);

  MenuRenameTopicMultivariateTest.prototype.name = 'topics_menu_text';
  MenuRenameTopicMultivariateTest.prototype.customVarIndex = 14;
  MenuRenameTopicMultivariateTest.prototype.cohorts = {
    // Nothing changes for topics cohort
    topics: {},
    policy_areas: {
      callback: "policyAreasCallback"
    }
  };

  MenuRenameTopicMultivariateTest.prototype.policyAreasCallback = function() {
    this.$el.find('.js-topics-link').text('Policy areas');
    this.$el.find('.js-policies-link').hide();
  }
  GOVUK.MenuRenameTopicMultivariateTest = MenuRenameTopicMultivariateTest;
})();

