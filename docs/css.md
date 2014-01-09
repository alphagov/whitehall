# Whitehall CSS Styleguide

To be read in conjunction with the [GOV.UK CSS Styleguide](https://github.com/alphagov/styleguides/blob/master/css.md)

## File structure

The stylesheets are split between frontend and admin. The frontend ones are in a much better state and should be the way the admin ones move in the future.

They are structured to take advantage of the the [conditionals][1] from the frontend_toolkit. This means you should put your IE fixes inline not in a separate file.

Within the frontend folder the basic structure of the files looks like:

    ./base.scss
    ./base-ie6.scss
    ./base-ie7.scss
    ./base-ie8.scss
    ./helpers/
    ./views/
    ./resets/
    ./layouts/
    ./styleguide/


The `base.scss` is the file that will be compiled with Sass.
All other files should be referenced from it in the relevant sections.
The IE variants (`base-ie[6-8].scss` which you should never need to edit as they include `base.scss`) enable us to use mixins which only show css to certain IE versions.

Tech-debt creep in CSS is usually an symptom of a lack of confidence in changing or removing existing CSS. By structuring CSS in this way, we are clearly communicating the scope of that CSS.

### `./helpers`

Helpers are blocks of Sass which match a reusable markup pattern, the markup for which is often represented in a Rails partial.
They are used to style singular blocks which appear on multiple pages around the site.

The name of the file should match the single selector inside the file and everything else should be nested under that selector,
for example if you had a partial to display a document table you would have the following helper:

`_document_table.html.erb`:

    <div class="document-table">
      <h2>My document table</h2>
      ...
    </div>

`./helpers/_document-table.scss`:

    .document-table {
      h2 {
        ...
      }
    }

### `./views`

Views are where you style the layout of a page and any elements which will only appear in that controller.
There should be one file in this directory for each controller, and should be named after the controller.

The view for the controller should set the `page_class` in the form `{controller}-{action}`,
for example for the views from `people_controller.rb`

`people/index.html.erb`:

    <% content_for :page_class, 'people-index' %>
    ...

`./views/_people.scss`:

    .people-index {
      ...
    }
    .people-show {
      ...
    }

### `./resets`

This contains the base html resets which remove most of the default styling a browser adds to elements. It also houses a reset to change any of the styles which have been added by [static][2] which might be flowing into the app.

### `./layouts`

There should be files in here for the views in `app/views/layouts`. They contain global page styling for things which appear on every page of the site. This includes any global navigation or global footers.

### `./styleguide`

These are a collection of Sass mixins. They shouldn't output any CSS when included and should only produce CSS when called from another file. Things should be put here and used before being standardised and moved into the [frontend_toolkit][3].

## Layouts

The frontend is built using responsive design in a mobile up fashion. That means that we define the mobile styles by default and then using a Sass mixin add on tablet or desktop styles. The whole site is also fluid so has been built using percentage widths for layout.

The frontend follows a loose grid based on a 1020px wide base with columns taking either 25% or 33.33% widths or multiples of them. They columns all have a 30px gutter between them. To achieve this we are forced to use extra spacing divs as CSS doesn't allow you to say `width: 50% - 60px;` without using the `calc` function which isn't available in most browsers.

We structure most of our pages like such:

    <div class="block heading-block">
      <div class="inner-block">
        ... my heading ...
      </div>
    </div>
    <div class="block navigation-block">
      <div class="inner-block">
        ... my navigation ...
      </div>
    </div>
    <div class="block content-block">
      <div class="inner-block">
        ... my content ...
      </div>
    </div>

The `inner-block` div has been styled globally to apply the correct amount of padding on desktop and reduce that padding for mobile. Then all you will need to do in your view Sass file is to define with widths and floats of your `block` elements.

So to create a standard top heading with navigation taking 25% width and content floating next to it which is in a linear column on mobile you would use something like:

    .navigation-block {
      @include media(tablet){
        width: 25%;
        float: left;
      }
    }
    .content-block {
      @include media(tablet){
        width: 75%;
        float: left;
      ]
    }

## Fonts

The `ig-core-[0-9]{2}` font mixins are deprecated. All new Sass should use the `core-[0-9]{2}` equivalents.

Always use the helper mixins. We don't have any generic styling for content markup, as such each view should define the font for its headings and paragraphs. Govspeak (markdown) is the exception to this where it should automatically get standard styling.

## Sizings

We use a standard set of dimension variables which are defined in `frontend/styleguide/_dimensions.scss`. You should use them where ever possible. The idea of using standardised spacings is the whole site will look uniform and won't be pixels out here and there.

## Right to left

The right to left support has been built the same way as the IE support. So that you can add styles to pages which display right to left text using the `right-to-left` mixin:

    .my-element {
      float: left;
      @include right-to-left {
        float: right;
      }
    }
