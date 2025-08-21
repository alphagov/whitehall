# 3. Move out to new Application

Date: 2025-08-14

## Status

Draft

## Context

The Content Block Manager has until now lived within Whitehall as a Rails
"engine". See [ADR 4: Content Object Store added with a Rails Engine][].

This has proved to be a good approach for testing the concept of a service
allowing content owners to model reusable blocks of content such as a simple
["Pension rate"][] or a complex ["Contact"][].

### Benefits

The new service has benefited from much existing Whitehall code and ongoing
maintenance effort, including:

- using "Sign on" authentication and Whitehall role-based access control
  (`Admin::BaseController`)
- interfacing with the Publishing API
- access to the Govspeak preview mechanism (`GOVUK.Modules.GovspeakEditor`)
- validating schemas (`JSONSchemer`)
- queuing background jobs with Sidekiq
- managing dependency updates with dependabot

### Friction points

We've noted a few points of friction between Content Block Manager and Whitehall:

- on a regular basis Whitehall experimental feature branches which aren't up to
  date with `main` are deployed to the integration environment. This is an
  entirely valid and necessary practice for the Whitehall team, but this often
  causes breaking changes in Content Block Manager features.

- one of the flip-sides to being a small part of Whitehall is the long build
  time. And conversely, from the Whitehall perspective, Content Block Manager is
  adding to the size and complexity of its build.

### Upcoming developing

More importantly, there are now a number of areas of development where we
believe the costs of being a part of Whitehall will significantly outweigh the
benefits:

#### Access control

We need to start developing a more fine-grained access control system and we
don't want to add more complexity to Whitehall's already long list of roles.
We need to be able to define permissions such as:

- a particular user may perform fact-checking and review draft content on a
  particular type of content block as a 2nd pair of eyes but not have permission
  to do anything else

- another user may have permission to create and review multiple types of block

At present the authorisation in the new service is very rudimentary and
provisional, with all users with access to Content Block Manager granted admin
control over Whitehall.

#### Interactivity

We have some rich UI needs which we'd like to meet using approaches which would
be awkward to add to Whitehall. For example, our intention is to build UIs to
allow users to:

- drag and drop nested objects within a block to re-order, for example the elements:

  - address b
  - address a
  - telephone 2
  - telephone 1

- view a "hot-reloading" preview of a complex content block whilst editing a
nested object. For example, whilst editing a Govspeak-enabled textarea within
the "telephone 2" nested object, the user will be able to generate a preview of
the composite Contact content-block including the unsaved contents of that
Govspeak textarea.

To offer these features we plan to use Rails' "Hotwire" components, such as
[Turbo Frames][]. We believe that it would not be practical to introduce this
library to Whitehall.

## Decision

We will move Content Block Manager out of Whitehall into its own repository as
a [new Rails application][].

## Consequences

There are a number of aspects to this work, including:

### Understand the Content Block Manager's dependencies

We will do some analysis to understand upfront the dependencies which Content
Block manager has on Whitehall. We believe that [Packwerk][] from Shopify may be
helpful.

### Explore converting test suite to RSpec

We will investigate the feasibility of converting our test suite from
Minitest to RSpec to align with [current GDS testing conventions][]. To ensure
that behaviour is not inadvertently changed, this would be a secondary step,
after initially porting the Minitest test suite.

### Lift and shift code

We will "lift and shift" our source code, deferring any refactoring.

### Move from MySQL to PostgreSQL

We will use Postgres rather than MySQL in the new Content Block Manager service.

### Provide continuity for block(s) in production

At present we have only 1 content block in production (["Pension rate"][]). We
will put together a migration plan to document in detail how we'll switch from
the current service to the new one without interruption.

### Provision the new application

The [new Rails application][] will come with a number of necessary features,
including authentication, API adaptors and publishing components.

In addition we will need to:

- add other dependencies which are currently provided by Whitehall
- configure the deployment pipeline through Github Actions
- provision Kubernetes infrastructure and set up monitoring / logging
- obtain SSL certificates and configure DNS (see
  [Kubernetes: Create a new application][])
- setup application accounts on related / 3rd party services such as Sentry,
  Logit, Notify etc.
- configure Google Analytics to continue to record user behaviour as is
  currently done in Whitehall
- understand governance requirements, e.g. for IT healthchecks
- implement an on-call rota to support the application out of hours

For an overview of responsibilities, see [Application ownership: what ownership means][].

[ADR 4: Content Object Store added with a Rails Engine]:
https://github.com/alphagov/whitehall/blob/main/docs/adr/0004-content-object-store-added-with-a-rails-engine.md

["Pension rate"]:
https://github.com/alphagov/publishing-api/blob/main/content_schemas/formats/content_block_pension.jsonnet

["Contact"]:
https://github.com/alphagov/publishing-api/blob/main/content_schemas/formats/content_block_contact.jsonnet

[Turbo Frames]:
https://turbo.hotwired.dev/handbook/frames

[new Rails application]:
https://docs.publishing.service.gov.uk/manual/setting-up-new-rails-app.html

[Packwerk]:
https://github.com/Shopify/packwerk

[current GDS testing conventions]:
https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html#testing-utilities

[Kubernetes: Create a new application]:
https://docs.publishing.service.gov.uk/kubernetes/create-app/#content

[Application ownership: what ownership means]:
https://docs.publishing.service.gov.uk/manual/ownership-meaning.html
