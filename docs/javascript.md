# Whitehall JavaScript Styleguide

Should be read in conjunction with the [GOV.UK JS styleguide](https://github.com/alphagov/styleguides/blob/master/js.md)

## Code style

All code should be wrapped in a closure and should declare `use strict`.  The GOVUK namespace should be setup in each file to promote portability.

    (function() {
      "use strict";
      window.GOVUK = window.GOVUK || {};

      // stuff
    }());


There are two patterns which can be employed in Whitehall, a singleton pattern and a constructor pattern and it's a case of choosing the right tool for the right job.

### Singleton pattern

Singletons should be defined as raw JavaScript hashes, and if required should do its initialisation in a function called init.

    (function() {
      "use strict";
      window.GOVUK = window.GOVUK || {};

      window.GOVUK.singletonThing = {
        init: function init() {

        },

        anotherFunction: function anotherFunction() {

        },

        // etc.
      };
    }());

### Constructor pattern

Constructors should follow the prototype pattern as follows:

    (function() {
      "use strict";
      window.GOVUK = window.GOVUK || {};

      function TheThing(options) {
        // some initialisation code
      }

      TheThing.prototype.someFunction = function someFunction() {
        // do some stuff
      };

      GOVUK.TheThing = TheThing;
    }());

Defining functions on the prototype as opposed to defining them privately in the constructor exposes them making the objects easier to test. Although in theory you should never test a private method, it's sometimes helpful to do so in JavaScript - particularly when testing objects which are very tightly coupled to the DOM and often don't have any public API.

Defining the constructor in the wrapper function's scope, then assigning it to the namespace improves readability by keeping names shorter.

This pattern works well for creating views (in the Backbone sense) to control a DOM element. You probably want to add this line to your constructor to initialise the view against a DOM element:

    this.$el = $(options.el);

The view can then be initialised with a selector for the DOM element is controlling:

    GOVUK.init(GOVUK.TheThing, {el: '.js-the-thing'});

See "Script initialisation" below for more details on `GOVUK.init`.

#### Proxying function when using the prototype / constructor pattern

One of the main problems with the prototype / constructor pattern is the need to proxy functions in order to avoid loss of context. Here's an example of the problem:

    function SillyRedButton(options) {
      $('#the_big_red_button').click(this.makeSillyNoise);
    };

    SillyRedButton.prototype.makeSillyNoise = function makeSillyNoise() {
      this.playSoundEffect("a_silly_noise");
    };

    SillyRedButton.prototype.playSoundEffect = function playSoundEffect(soundEffect) {
      SomeSoundLibrary.play(soundEffect);
    };

This script will break on the call `this.playSoundEffect()` because that function will be called in the context of the button clicked on, not the constructed object. GOVUK.Proxifier can make this problem go away with a single call in the constructor function and no further changes to the script:

    function SillyRedButton(options) {
      GOVUK.Proxifier.proxifyAllMethods(this);
      $('#the_big_red_button').click(this.makeSillyNoise);
    };

    SillyRedButton.prototype.makeSillyNoise = function makeSillyNoise() {
      this.playSoundEffect("a_silly_noise");
    };

    SillyRedButton.prototype.playSoundEffect = function playSoundEffect(soundEffect) {
      SomeSoundLibrary.play(soundEffect);
    };

To proxify only single methods, use `GOVUK.Proxifier.ProxifyMethods(object, [methodNames])` or `GOVUK.Proxifier.ProxifyMethod(object, methodName)`

### Other style points

Favour named arguments in a hash over sequential arguments. [Connascence of naming is a weaker form of connascence than connascence of position][5].

In general, use of anonymous functions should be avoided. Code made up of anonymous functions is more difficult to profile and debug.  Anonymous functions don't report a name to profilers, stack traces and when calling `arguments.callee.caller`, etc.

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

## File structure and namespacing

Each JavaScript object should be stored in its own file with a filename reflecting the object name. In the spirit of keeping things similar to the CSS, they should be stored in:

    ./helpers/
    ./frontend/views/
    ./frontend/modules/
    ./frontend/helpers/
    ./admin/views/
    ./admin/modules/
    ./admin/helpers/

__Views__ are view-specific scripts and as with the css, their file path and name should exactly mirror the view template or partial it applies to. The name of the script object should reflect the whole view path (the object in `/admin/editions/index.js` should be called `GOVUK.adminEditionsIndex`).

__Modules__ are re-useable things. An example of a module would be the script for a tabbed content block. Modules should not be initialised globaly, and should only be initialised when needed, by the layout / partial which needs it (see script initialisation). If a script is only ever going to be used in one place, don't make it a module.

__Helpers__ are scripts which are loaded everywhere (such as the script which prevents forms from being submited twice).

Namespaces should be kept simple and all constructors should be under `GOVUK`. The JavaScript layer is thin for whitehall and so (at least at present) there's no need to use deeper namespaces.

## Script initialisation

Scripts should be initialised with `GOVUK.init`:

    GOVUK.init(GOVUK.SomeScript, {el: '.js-the-thing'});

If the passed in object is a constructor, `GOVUK.init` creates an instance of the passed in constructor, passing the second argument through as an argument. A reference to the new instance is stored in `GOVUK.instances`.

Otherwise, `GOVUK.init` will call init on the passed in hash, treating it as a singleton.

Scripts should only be initialised when needed and should make use of the rails helper `initialise_script`:

    #!erb
    <% initialise_script "GOVUK.SomeView", el: '.js-some-view' %>

This rails helper takes a ruby hash as a second argument, which is jsonified and passed down to the javascript constructor (in content\_for block `:javascript_initialisers`). This is not done in `$.ready` by default, so if the script needs to wait for $.ready, it should do so itself.

This initialise\_script line should be in the most appropriate template/partial for view scripts / view-specific helpers, and should be near the `:javascript_initialisers` yield in the applicable layout for site-wide helpers.

## CSS selectors

Scripts should only make use of CSS classes beginning with `js-`. [This makes it completely transparent what the class is used for within the HTML][4].

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
