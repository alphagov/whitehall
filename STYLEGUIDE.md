# Whitehall style guide

Code written for Whitehall should follow these guidelines.

This is an extension of the [GDS style guide](https://github.com/alphagov/styleguides) with things that are specific to Whitehall.


## CSS

### File structure

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

Within ./views and ./layouts, files should be placed and named to directly reflect the template / partial they style.  For example, the styling for the partial `app/views/shared/_header.html.erb` should be `app/assets/stylesheets/frontend/helpers/shared/_header.scss`.

Why?: Tech-debt creep in CSS is usually an symptom of a lack of confidence in changing or removing existing CSS. By structuring CSS in this way, we are clearly communicating the scope of that CSS.


#### `./helpers`

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

#### `./views`

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

#### `./resets`

This contains the base html resets which remove most of the default styling a browser adds to elements. It also houses a reset to change any of the styles which have been added by [static][2] which might be flowing into the app.

#### `./layouts`

There should be files in here for the views in `app/views/layouts`. They contain global page styling for things which appear on every page of the site. This includes any global navigation or global footers.


#### `./styleguide`

These are a collection of Sass mixins. They shouldn't output any CSS when included and should only produce CSS when called from another file. Things should be put here and used before being standardised and moved into the [frontend_toolkit][3].

### Layouts

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

## JavaScript

## Code style

Javascript code should be written following this pattern:

    (function ($) {
      function TheThing(params) {
        //some initialisation code
      }

      TheThing.prototype.someFunction = function someFunction() {
        //do some stuff
      };

      Whitehall.Frontend.TheThing = TheThing;
    )}(jQuery);

Defining functions on the prototype as opposed to defining them privately in the constructor exposes them making the objects easier to test. Although in theory you should never test a private method, it's sometime helpful to do so in Javascript - particularly when testing objects which are very tightly coupled to the dom and often don't have any public API.

Objects in general should not be defined as singletons. Using singletons makes re-use difficult, prevents multiple instances and makes testing difficult.  In the rare case that a singleton is appropriate it should be defined as above, except an instance should be assigned to the namespace finally:

    (function ($) {
      function TheSingletonThing(params) {
      }

      Whitehall.TheSingletonThing = new TheSingletonThing();
    )}(jQuery);


In general, use of anonymous functions should be avoided. Code made up of anonymous functions is more difficult to profile
and debug.

bad:

    TheThing.prototype.someFunction = function() {
      //do some stuff
    };
    new TheThing().someFunction.name;  //  ==> ''

good:

    TheThing.prototype.someFunction = function someFunction() {
      //do some stuff
    };
    new TheThing().someFunction.name;  //  ==> 'someFunction'


Favour named arguments in a hash over sequential arguments. [Connascence of naming is a weaker form of connascence than connascence of position][5].

## File structure and namespacing

Each javascript object should be stored in it's own file with a filename reflecting the object name. In the spirit of keeping things similar to the css, they should be stored in:

    ./views/
    ./helpers/
    ./frontend/views/
    ./frontend/helpers/
    ./admin/views/
    ./admin/helpers/

Views are view-specific scripts and as with the css, it's file path & name should exactly mirror the view template or partial it applies to.

Helpers are scripts which cannot be associated with any particular view.  These may be scripts which are loaded everywhere (such as the script which prevents forms from being submited twice), or may be scripts which apply to multiple different not-necessarily-related views.

Namespaces should be kept simple. All constructors should be under 'Whitehall', 'Whitehall.Frontend' or 'Whitehall.Admin'. The javascript layer is thin for whitehall and so (at least at present) there's no need to use deeper namespaces. These 3 namespaces are defined in whitehall.js and so code like `window.Whitehall = window.Whitehall || {}` is unnecessary.

## Script initialisation

Scripts should be initialised with `Whitehall.init`:

    Whitehall.init(Whitehall.Frontend.SomeScript, {elem_selector: '.js-the-thing'});

Whitehall.init creates an instance of the passed in constructor, passing the second argument through as an argument. A reference to the new instance is stored in `Whitehall.instances`.

Scripts should only be initialised when needed and should make use of the rails helper `initialise_script`:

    #!erb
    <% initialise_script "Whitehall.Frontend.SomeView", selector: '.js-some-view' %>

This rails helper takes a ruby hash as a second argument, which is jsonified and passed down to the javascript constructor (in content\_for block :javascript_initialisers). This is not done in $.ready by default, so if the script needs to wait for $.ready, it should do so in it's constructor.

This initialise\_script line should be in the most appropriate template/partial for view scripts / view-specific helpers, and should be near the :javascript_initialisers yield in the applicable layout for site-wide helpers.

## CSS selectors

Scripts should only make use of css classes beginning with 'js-'. [This makes it completely transparent what the class is used for within the HTML][4].

### Styles

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
[5]: http://en.wikipedia.org/wiki/Connascence_%28computer_programming%29#Types_of_connascence
