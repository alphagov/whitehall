//= require admin/stop-scripts-nomodule

//= require govuk_publishing_components/dependencies
//= require govuk_publishing_components/analytics-ga4
//= require govuk_publishing_components/back-link
//= require govuk_publishing_components/contents-list
//= require govuk_publishing_components/copy-to-clipboard
//= require govuk_publishing_components/date-input
//= require govuk_publishing_components/details
//= require govuk_publishing_components/error-alert
//= require govuk_publishing_components/error-message
//= require govuk_publishing_components/fieldset
//= require govuk_publishing_components/file-upload
//= require govuk_publishing_components/govspeak
//= require govuk_publishing_components/heading
//= require govuk_publishing_components/hint
//= require govuk_publishing_components/input
//= require govuk_publishing_components/inset-text
//= require govuk_publishing_components/label
//= require govuk_publishing_components/layout-footer
//= require govuk_publishing_components/layout-for-admin
//= require govuk_publishing_components/lead-paragraph
//= require govuk_publishing_components/list
//= require govuk_publishing_components/notice
//= require govuk_publishing_components/phase-banner
//= require govuk_publishing_components/reorderable-list
//= require govuk_publishing_components/search
//= require govuk_publishing_components/select
//= require govuk_publishing_components/summary-list
//= require govuk_publishing_components/table
//= require govuk_publishing_components/textarea
//= require govuk_publishing_components/title
//= require govuk_publishing_components/warning-text

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

'use strict'
window.GOVUK.approveAllCookieTypes()
window.GOVUK.cookie('cookies_preferences_set', 'true', { days: 365 })
