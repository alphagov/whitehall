//= require admin/stop-scripts-nomodule

//= require govuk_publishing_components/dependencies
//= require govuk_publishing_components/components/accordion
//= require govuk_publishing_components/components/add-another
//= require govuk_publishing_components/components/copy-to-clipboard
//= require govuk_publishing_components/components/file-upload
//= require govuk_publishing_components/components/govspeak
//= require govuk_publishing_components/components/reorderable-list
//= require govuk_publishing_components/components/table
//= require govuk_publishing_components/components/select-with-search
//= require govuk_publishing_components/components/service-navigation
//= require govuk_publishing_components/lib/trigger-event
//= require govuk_publishing_components/lib/cookie-functions
//= require govuk_publishing_components/analytics-ga4/ga4-form-change-tracker

//= require components/govspeak-editor
//= require components/image-cropper
//= require components/miller-columns

//= require admin/analytics-modules/ga4-index-section-setup.js
//= require admin/analytics-modules/ga4-button-setup.js
//= require admin/analytics-modules/ga4-search-results-setup.js
//= require admin/analytics-modules/ga4-paste-tracker.js
//= require admin/analytics-modules/ga4-search-setup.js
//= require admin/analytics-modules/ga4-finder-setup.js
//= require admin/analytics-modules/ga4-form-setup.js

//= require admin/modules/document-history-paginator
//= require admin/modules/locale-switcher
//= require admin/modules/navbar-toggle
//= require admin/modules/paste-html-to-govspeak
//= require admin/modules/prevent-multiple-form-submissions

//= require admin/views/broken-links-report
//= require admin/views/edition-form
//= require admin/views/organisation-form
//= require admin/views/unpublish-display-conditions

'use strict'
window.GOVUK.approveAllCookieTypes()
window.GOVUK.cookie('cookies_preferences_set', 'true', { days: 365 })
