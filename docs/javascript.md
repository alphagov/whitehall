# Whitehall JavaScript

Should be read in conjunction with the [GDS Way JS styleguide](https://gds-way.cloudapps.digital/manuals/programming-languages/js.html)

## File structure and namespacing

Each JavaScript object should be stored in its own file with a filename reflecting the object name. In the spirit of keeping things similar to the CSS, they should be stored in:

```
./admin/modules/
./admin/views/
```

## Modules

Modules are re-useable things. An example of a module would be the script for a tabbed content block. Modules should not be initialised globally, and should only be initialised when needed, by the layout / partial which needs it. They should be initalised using data attributes, for example:

```html
<div data-module="your-module-name"></div>
```

Modules should be written in the following format:

```js
window.GOVUK = window.GOVUK || {};
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function YourModuleName(module) {
    this.module = module;
  }

  YourModuleName.prototype.init = function () {
    // code here
  };

  Modules.YourModuleName = YourModuleName;
})(window.GOVUK.Modules);
```

Modules names are written with a [kebab case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) in the `data-module` attribute. However, they are [camel case](https://en.wikipedia.org/wiki/Camel_case) in the JavaScript files.

Modules are automatically initalised by the GOVUK Publishing component scripts on load.

## Views

Views are view-specific scripts and as with the css, their file path and name should exactly mirror the view template or partial it applies to.

They should initalise using the same way as modules. This will maintain consistency and not require a new method of initialising scripts.
