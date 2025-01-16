# Analytics

Events in Whitehall are tracked using Google Tag Manager by pushing directly to the data layer. Tracking can be verified by monitoring the `window.dataLayer` in the console.

The majority of tracking code is defined and documented in govuk_publishing_components. This allows it to be more easily shared across publishing applications and the frontend - reducing developer burden and ensuring schema consistency across applications.

Whilst we aim to share as much code between the frontend and publishing applications, there are some differences in approach due to the contrast in user numbers. Due to the large number of users on GOV.UK, frontend applications risk pushing too data if every event is written. Publishing applications see much lower user numbers and consequently a different approach is taken for some components, such as buttons.

Tracking is built on a component level, that is to say, rather than focusing on individual pages or individual forms we aim to add tracking to a component such as a link or a button and use the same code across all pages and applications.

Tracking in Whitehall and other applications is written in three ways:
- modules included in component markup
- modules that require setup
- modules that run on page load regardless of page content

## Modules included in component markup

Some components have tracking built in. When these components are used in a page they will include a module in the page markup and as long as the core tracking code is included in the application these components will automatically push to the data layer. If a change to the schema or tracking code is required, it must be checked with all teams that use publishing components and made in the shared repository.

Components that are automatically tracked include a `disable_ga4` parameter to disable tracking, examples of components with automatic tracking that are used in Whitehall include:
- Back links
- Details
- Phase banner
- Tabs

## Modules that require setup

Modules such as the event-data-tracker and link-tracker must be added to the page manually and rely on attributes for contribution. This allows them to be restricted to a limited number of buttons, links or pages in the frontend applications.

In Whitehall we would like track all buttons while at the same time sharing as much of the existing implementation with the frontend applications as possible. The approach we use is to initialise both the tracking module and a “setup” module at the same time at the top of the page. The purpose of the “setup” module is to automatically generate and add attributes to relevant elements of the page. The “setup” modules to not perform any tracking themselves but Without them, the tracking modules would not have all appropriate attributes to include in the events pushed to the data layer.

## Modules that run on page load regardless of page content

Some modules run on page load, regardless of the content of the page that is loaded. These modules are attached to the `window.GOVUK.analyticsGa4.analyticsModules` object and include an `init` function (which is run on page load). Examples of these modules are the page view tracker and the copy tracker.
