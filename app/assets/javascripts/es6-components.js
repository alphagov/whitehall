// These modules from govuk_publishing_components
// depend on govuk-frontend modules. govuk-frontend
// now targets browsers that support `type="module"`.
//
// To gracefully prevent execution of these scripts
// on browsers that don't support ES6, this script
// should be included in a `type="module"` script tag
// which will ensure they are never loaded.

//= require govuk_publishing_components/components/button
//= require govuk_publishing_components/components/checkboxes
//= require govuk_publishing_components/components/character-count
//= require govuk_publishing_components/components/error-summary
//= require govuk_publishing_components/components/layout-header
//= require govuk_publishing_components/components/radio
//= require govuk_publishing_components/components/skip-link
//= require govuk_publishing_components/components/tabs
