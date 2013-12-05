(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  /*
   * Show a custom user satisfaction survey with a custom URL.
   *
   * This is a separate module because the survey is in static as a singleton,
   * so whitehall has no control over its initialisation.
   */
  function CustomUserSatisfactionSurvey(options) {
    // Loading GOVUK.userSatisfaction is deferred
    $(function() {
      if (!GOVUK.userSatisfaction) {
        return;
      }

      GOVUK.userSatisfaction.setSurveyUrl(options.surveyUrl);
      GOVUK.userSatisfaction.showSurveyBar();
    });
  }

  GOVUK.CustomUserSatisfactionSurvey = CustomUserSatisfactionSurvey;
})();
