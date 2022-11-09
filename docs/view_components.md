# View Components

[View Components](https://viewcomponent.org/) are an extension of the presenter pattern and allows you to consolidate the logic needed for a partial/template into a single class. Unlike a presenter this class is directly coupled to a html.erb file. They allow you to encapsulate and test view logic easily and effectively.

## When we should be using them

View components are intended for controller specific view needs, particularly to provide an easier way to test views, for components used in multiple places we have govuk_publishing_components.

We consider view components to be a part of the view layer of the application so should only contain logic that relates to converting the input arguments into HTML, if more complex business logic is needed you can use Helper functions or add it to methods on the object passed to the component.

Tests for view components should be all based on HTML output, If you need to test something more that it's likely not something that belongs in a ViewComponent.

## How to generate them

You can use:

```
govuk-docker-run rails g component admin/ComponentName
```

or

```
govuk-docker-run rails g component admin/component_name
```

## File structure and namespacing


View Components are linked to specific views, and will follow use the same file structure, with the controller action appended as a directory. For example, if it a component that is used on the edit edition page to encapsulate fields for an image, the file structure would be the following:

```
components/admin/editions/edit/image_component.rb
components/admin/editions/edit/image_component.html.erb
test/components/admin/editions/edit/image_component_test.rb
```

Any components used in multiple controller actions will sit in the top level folder for that controller. For example, if the image_component is used in the new and edit views, the file structure would be:

```
components/admin/editions/image_component.rb
components/admin/editions/image_component.html.erb
test/components/admin/editions/image_component_test.rb
```

If there is CSS or JS specific to the component it should sit in the top level folder like a component shared by multiple views.

For example, for JS:

```
assets/javascript/admin/views/edition/image_component.scss
```

And CSS:

```
assets/stylesheets/admin/views/edition/image_component.scss
```

## Github Issue

A [Github Issue] (https://github.com/alphagov/whitehall/issues/6954) was opened to discuss using View Components.
