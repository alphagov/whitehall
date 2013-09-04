# CSS


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


The `base.scss` is the file that will be compiled with Sass. All other files should be referenced from it in the relevant sections. The IE variants (`base-ie[6-8].scss` which you should never need to edit as they include `base.scss`) enable us to use mixins which only show css to certain IE versions.

### `./helpers`

These are blocks of Sass which usually match a rails partial. They are used to style singular blocks which appear on multiple pages around the site. The name of the file should match the single selector inside the file and everything else should be nested under that selector. For example if you had a partial to display a document table you would have the following helper:

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

These are where you style the layout of a page and any elements which will only appear in that one view. There should be one file in this directory for each controller. They should be named after the controller. The view for the controller should set the `page_class` in the form `{controller}-{action}`. For example for the views from `people_controller.rb`

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

### Fonts

The `ig-core-[0-9]{2}` font mixins are deprecated. All new Sass should use the `core-[0-9]{2}` equivalents.

Always use the helper mixins. We don't have any generic styling for content markup, as such each view should define the font for its headings and paragraphs. Govspeak (markdown) is the exception to this where it should automatically get standard styling.

### Sizings

We use a standard set of dimension variables which are defined in `frontend/styleguide/_dimensions.scss`. You should use them where ever possible. The idea of using standardised spacings is the whole site will look uniform and won't be pixels out here and there.

### Right to left

The right to left support has been built the same way as the IE support. So that you can add styles to pages which display right to left text using the `right-to-left` mixin:

    .my-element {
      float: left;
      @include right-to-left {
        float: right;
      }
    }

# JavaScript

We write testable JavaScript. That means you can write unit tests for all the logic in the JavaScript and have a fairly high degree of confidence that the JavaScript will do exactly what you expect it to.

The standard wrapper for JavaScript files looks like:

    (function () {
      "use strict"
      var root = this,
          $ = root.jQuery;

      if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

      var myThing = {
        methodToDoSometing: function(){
          ...
        },
        init: function(){
          ...
        }
      }
      root.GOVUK.myThing = myThing;
    }).call(this);

Using this format means you can write a unit test for `methodToDoSomething` by itself and check that it does exactly what you want it to do. Writing the same thing as a jQuery extension or as a clousured function means you couldn't then unit test the individual components.

The init for your thing should then be called in `on_ready.js`. There are separate `on_ready.js` files for each of the admin and frontend.

You should prefix any classes you wish your JavaScript to find with a [`js-` prefix][4]. This lets us easily see when refactoring code that there is some JavaScript behaviour associated to the object.

## Styles

If you want to add styles to things with the knowledge that JavaScript is available on the page you can take advantage of the `js-enabled` class we add to the body element. So if you know an element need to be hidden when JavaScript is available you can use:

    .my-toggle-body {
      .js-enabled & {
        display: none;
      }
    }

[1]: https://github.com/alphagov/govuk_frontend_toolkit#conditionals
[2]: https://github.com/alphagov/static
[3]: https://github.com/alphagov/govuk_frontend_toolkit
[4]: https://github.com/alphagov/styleguides/blob/master/js.md#use-a-js--prefix-for-js-only-html-classes
