# View Components

[View Components](https://viewcomponent.org/) are an extension of the [presenter pattern](https://www.rubyguides.com/2019/09/rails-patterns-presenter-service/). They allow you to consolidate the logic needed for a partial/template into a single class. Unlike a presenter, this class is directly coupled to a `.html.erb` file. They allow you to encapsulate and test view logic easily and effectively.

## When we should be using them

1. View Components are intended for controller specific view needs, particularly to provide an easier way to test views. For components used in multiple places we have [govuk_publishing_components](https://docs.publishing.service.gov.uk/repos/govuk_publishing_components.html).

2. We consider View Components to be a part of the View layer of the application, so should only contain logic that relates to converting the input arguments into HTML. If more complex business logic is needed you can use Helper functions or add it to methods on the object passed into the component.

3. Tests for View Components should be all based on HTML output. If you need to test something more than that, it's likely not something that belongs in a View Component.

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


View Components are linked to specific views, and should follow the same file structure as the `app/views` directory. For example, a component that is used on the edit edition page to encapsulate fields for an image could exist as:

```
components/admin/editions/edit/image_component.rb
components/admin/editions/edit/image_component.html.erb
test/components/admin/editions/edit/image_component_test.rb
```

Any components used in multiple controller actions should sit in the top level folder for that controller. For example, if the image component is used in the new and edit views, the file structure would be:

```
components/admin/editions/image_component.rb
components/admin/editions/image_component.html.erb
test/components/admin/editions/image_component_test.rb
```

If the component needs specific CSS or JavaScript, that should sit in the equivalent path under `assets/(javascripts|stylesheets)/admin/views`. For example, given an image component shared by multiple views of the editions controller:

```
assets/javascript/admin/views/edition/image_component.js
assets/stylesheets/admin/views/edition/image_component.scss
```

## GitHub Issue

The GitHub Issue [#6954](https://github.com/alphagov/whitehall/issues/6954) was opened to discuss using View Components.
