//= require admin/stop-scripts-nomodule

//= require govuk_publishing_components/dependencies
//= require govuk_publishing_components/analytics-ga4
//= require govuk_publishing_components/components/accordion
//= require govuk_publishing_components/components/add-another
//= require govuk_publishing_components/components/copy-to-clipboard
//= require govuk_publishing_components/components/govspeak
//= require govuk_publishing_components/components/reorderable-list
//= require govuk_publishing_components/components/table
//= require govuk_publishing_components/lib/trigger-event
//= require govuk_publishing_components/lib/cookie-functions

//= require components/govspeak-editor
//= require components/image-cropper
//= require components/miller-columns
//= require components/select-with-search

//= require admin/analytics-modules/ga4-index-section-setup.js
//= require admin/analytics-modules/ga4-button-setup.js
//= require admin/analytics-modules/ga4-link-setup.js
//= require admin/analytics-modules/ga4-visual-editor-event-handlers.js
//= require admin/analytics-modules/ga4-page-view-tracking.js
//= require admin/analytics-modules/ga4-finder-tracker.js
//= require admin/analytics-modules/ga4-paste-tracker.js
//= require admin/analytics-modules/ga4-select-with-search-tracker.js

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

document.addEventListener("DOMContentLoaded", (event) => {
	const finder = document.querySelector('[data-ga4-finder-tracker]');

	if (finder) {
		Array.from(document.querySelectorAll('input:not([type="search"]), select')).forEach((el) => {
			el.setAttribute('data-ga4-filter-parent', 'true');
			el.setAttribute('data-ga4-change-category', `update-filter ${el.tagName === 'INPUT' ? el.type : 'select'}`)
			
			if (el.id.length) {
				el.setAttribute('data-ga4-section', document.querySelector(`label[for="${el.id}"]`).innerText)	
			} else {
				el.setAttribute('data-ga4-section', document.querySelector(`label[for="${el.name}"]`).innerText)	
			}
		})
	}

	window.GOVUK.analyticsGa4.Ga4FinderTracker.getSectionIndex = function(input) {
		const inputs = Array.from(input.form.querySelectorAll('input:not([type="search"]), select'));
		
		return {
			index_section: inputs.indexOf(input),
			index_section_count: inputs.length
		}
	}

	if (finder) {
		finder.addEventListener('change', (event) => {
		  var ga4ChangeCategory = event.target.closest('[data-ga4-change-category]')
		  ga4ChangeCategory = ga4ChangeCategory.getAttribute('data-ga4-change-category')
			window.GOVUK.analyticsGa4.Ga4FinderTracker.trackChangeEvent(event.target, ga4ChangeCategory)
		})
	}

});
