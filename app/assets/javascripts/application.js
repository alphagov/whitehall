//= require admin/stop-scripts-nomodule

//= require govuk_publishing_components/dependencies
//= require govuk_publishing_components/analytics-ga4
//= require govuk_publishing_components/components/accordion
//= require govuk_publishing_components/components/copy-to-clipboard
//= require govuk_publishing_components/components/govspeak
//= require govuk_publishing_components/components/reorderable-list
//= require govuk_publishing_components/components/table
//= require govuk_publishing_components/lib/trigger-event
//= require govuk_publishing_components/lib/cookie-functions

//= require components/autocomplete
//= require components/govspeak-editor
//= require components/image-cropper
//= require components/miller-columns
//= require components/select-with-search

//= require admin/analytics-modules/ga4-button-setup.js
//= require admin/analytics-modules/ga4-link-setup.js
//= require admin/analytics-modules/ga4-form-setup.js
//= require admin/analytics-modules/ga4-visual-editor-event-handlers.js
//= require admin/analytics-modules/ga4-page-view-tracking.js
//= require admin/analytics-modules/ga4-paste-tracker.js

//= require admin/modules/add-another
//= require admin/modules/document-history-paginator
//= require admin/modules/locale-switcher
//= require admin/modules/navbar-toggle
//= require admin/modules/paste-html-to-govspeak
//= require admin/modules/prevent-multiple-form-submissions

//= require admin/views/broken-links-report
//= require admin/views/edition-form
//= require admin/views/organisation-form
//= require admin/views/unpublish-display-conditions

//= require content_block_manager/application

'use strict'
window.GOVUK.approveAllCookieTypes()
window.GOVUK.cookie('cookies_preferences_set', 'true', { days: 365 })
