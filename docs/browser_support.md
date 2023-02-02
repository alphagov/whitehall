# Whitehall browser support

Whitehall browser support follows the guidance provided in the [GOV.UK Service Manual](https://www.gov.uk/service-manual/technology/designing-for-different-browsers-and-devices#browsers-to-test-in-from-june-2022).
## Internet Explorer 11 support

Whitehall's support of Internet Explorer 11 does not go beyond the functionality that is offered through progressive enhancement. JavaScript is not required to be compatible with the browser but should not cause the page to break or become non-functional.

If a module uses features such as `fetch`, the presence of these features should be checked in the initialisation method before any changes are made to the DOM.

## Usage of ES6 (2015) syntax

To enable the use of ES6 syntax such as arrow functions Whitehall's build process is in the process of being updated. Upon completion of this work, JavaScript will be entirely disabled in Internet Explorer 11 through the use of modules. Only following this can variable declarations such as `let` and `const` be used.

## Background for the level of Internet Explorer 11 support provided

In January 2023 Whitehall's support for IE 11 was investigated. Usage was found to be significantly below the 2% cut off defined in the GOV.UK Service Manual. The subject was discussed with the broader frontend community and a decision was made to drop support for Internet Explorer 11. Beginning from the next major version, v5, GOV.UK Frontend will drop IE11 support in their JavaScript, leaving IE11 users with the JavaScript free versions of the pages only.
