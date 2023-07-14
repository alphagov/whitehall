# Gift Week Editor

A block-based editor created during the ‘GOV.UK Ideas and Future Thinking’ week in December 2022.

Powered by the excellent [Editor.js](https://editorjs.io/).

## Demo

Find a live demo of this editor at:

https://gift-week-editor.netlify.app

## Govspeak compatibility

| Feature | Status | Notes |
|---|---|---|
| Acronyms |  |  |
| Addresses |  |  |
| Bold text | ✅ Supported | Bold text is supported.<br>Need to remove styling for italic text, as per [Govspeak CSS rules]. |
| Bulleted lists | ⚠️ Partial support | Ordered and unordered lists are supported.<br>Need to add support for hyperlinks, bold text, and other inline elements within list items. |
| Buttons |  |  |
| Callouts |  |  |
| Contacts |  |  |
| Headings | ⚠️ Partial support | Supports H2–H6.<br>Styling needs to be updated to reflect GOV.UK Frontend styles. |
| Line breaks |  |  |
| Links |  |  |
| Tables | ⚠️ Partial support | Basic tables are supported. Text alignment and header cells are not supported. |

[Govspeak CSS rules]: https://github.com/alphagov/govuk_publishing_components/blob/1b3f4091ceaf6198c8eca7cf69f7aee95564fac7/app/assets/stylesheets/govuk_publishing_components/components/govspeak/_typography.scss#L96-L100
