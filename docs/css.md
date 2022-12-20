# Whitehall CSS Styleguide

To be read in conjunction with the following:

- [GDS Way CSS styleguide](https://gds-way.cloudapps.digital/manuals/programming-languages/css.html)
- [GOV.UK Component Conventions](https://github.com/alphagov/govuk_publishing_components/blob/main/docs/component_conventions.md)

## Namespacing

### Components

Components standards are defined by [GOVUK Publishing Components](https://github.com/alphagov/govuk_publishing_components).

All components must adhere to the following:

- [Component Conventions](https://github.com/alphagov/govuk_publishing_components/blob/main/docs/component_conventions.md)
- [Component Principles](https://github.com/alphagov/govuk_publishing_components/blob/main/docs/component_principles.md)
- [Component Branding](https://github.com/alphagov/govuk_publishing_components/blob/main/docs/component_branding.md)

All components must use a namespace with a `c` as part of the namespace -- the `c` is for component. For example `.app-c-banner`. Avoid using `.app-component-*` as it doesn't follow the standards set across the GOVUK applications.

Components from the [GOVUK Publishing Components](https://github.com/alphagov/govuk_publishing_components) will have a naming space of `gem-c-*`, for example `gem-c-banner`.

### Views

Views are where styling for individual layouts or partials live. In general, the css for a template should live in a scss file named after that template, but scss for partials used in multiple templates should be extracted to a separate file named after that partial. SCSS rules within these view files should never affect anything other than the coupled view file.

All view css must have a naming space with `view` as part of the namespace. For example `.app-view-dashboard`.

### View Components

View components that are created within this application will use the same conventions as `views` and use the same namespace. For example `.app-view-sidebar`.

We should avoid using the word `component` within the class names when referring to view components to reduce the risk of being confused with the GOV.UK Publishing components above.

[More information about view components](https://viewcomponent.org/)

## File structure and scope

The stylesheets file structure is as follows:

```
- app
  - assets
    - stylesheets
      - admin
        - views
      - components
      application.scss
```

### `/app/assets/stylesheets/admin/views`

In the `views` folder, all of the view css will be stored. This is currently stored in `/admin/views` to differentiate between legacy and new view CSS. Once the legacy CSS has been removed, this will be brought up to the same level as the `components` folder.

This folder will also store any `view_component` css.

### `/app/assets/stylesheets/components`

In this folder, all of the CSS for internal application components will be stored. The files should follow the same standards as the GOVUK Publishing Components and should be created in a way that can be ported over to the shared library.

### Legacy CSS

Legacy files will remain in the following folders structures:

```
- app
  - assets
    - stylesheets
      - admin_legacy
        - ...
      - frontend
        - ...
      - vendor
      admin_legacy.scss
```

More details about legacy css standards can be found [here](/docs/legacy_css.md).

## Styles

With the exception of namespaces, follow the [GOV.UK Frontend CSS conventions](https://github.com/alphagov/govuk-frontend/blob/main/docs/contributing/coding-standards/css.md), which describes in more detail our approach to namespaces, linting and BEM (block, element, modifier) CSS naming methodology.

Components can rely on classes from GOV.UK Frontend to allow for modification that build on top of the styles from the Design System. This follows the [recommendations for extending](https://design-system.service.gov.uk/get-started/extending-and-modifying-components/#small-modifications-to-components) from the Design System guide.

For example, a button component could be done like so:

```html
<button class="govuk-button app-c-button--inverse">Inverse button</button>
```

This makes it clear what the base component is, what the modifier is, and where the modifications are coming from.

### BEM

`.block {}`

`.block__element {}`

`.block--modifier {}`

`.block__element--modifier {}`

All CSS selectors should follow the BEM naming convention shown above, explained in [more detail here](https://github.com/alphagov/govuk-frontend/blob/main/docs/contributing/coding-standards/css.md#block-element-modifier-bem).

Note: to avoid long and complicated class names, we follow the [BEM guidance](http://getbem.com/faq/#css-nested-elements) that classes do not have to reflect the nested nature of the DOM. We also try to avoid nesting classes too deeply so that styles can be overridden if needed.

```scss
  // Avoid this:
  .block__elem1__elem2__elem3

  // Instead use:
  .block__elem1
  .block__elem2
  .block__elem3
```

Using BEM means we have confidence in our styles only being applied within the component context, and never interfering with other global styles. It also makes it clearer how HTML elements relate to each other.

Visit the links below for more information:

- [Official BEM Documentation](https://en.bem.info/methodology/naming-convention/#css-selector-naming-convention)
- [Guide on BEM naming conventions](https://webdesign.tutsplus.com/articles/an-introduction-to-the-bem-methodology--cms-19403)

### Print styles

Print styles should be included in the main stylesheet for a component, using the print media query as shown below.

```Sass
.app-c-example {
  background: red;

  @include govuk-media-query($media-type: print) {
    background: none;
  }
}
```

### Linting

All stylesheets must be linted according to [the style rules](https://github.com/alphagov/stylelint-config-gds/blob/main/scss-rules.js) in [stylelint-config-gds](https://github.com/alphagov/stylelint-config-gds).

```sh
govuk-docker-run yarn lint:scss
```
