# Whitehall Testing Guidlines

All contributions to the Whitehall codebase should have appropriate tests. We
have a pragmatic approach to testing:- every test should pull its weight.

When writing a test follow [Kent Beck's
advice](http://stackoverflow.com/a/153565/800501) and ask yourself if the
errors that the test guards against are ones that your team are likely to
make. If not, maybe the test is not necessary.

As with production code, optimise your tests for readability. Think carefully
especially about the naming of tests. Always consider what layers of the
application are under test and ask yourself if you are testing at the
appropriate level.

## Test driven design

Rails can encourage some anti-patterns such as bloated model, bloated
controller. The whitehall codebase definitely suffers from bloated model
problems and we are working to [pull out functionality from the editions
model into service objects](https://github.com/alphagov/whitehall/pulls/1000).

If something is hard to test at a unit level, then ask yourself if you can
improve the software design by splitting the code into smaller cooperating
objects with specific responsibilities.

We generally organise these helper objects within the `lib` directory,
although some of them are now in `app/services`. Background workers are in
`app/workers`.

## Which kind of test should I write?

### Unit tests

Aim to have as much logic as possible in focused objects which can be unit
tested.

Use [constructor injection](http://martinfowler.com/articles/injection.html)
to pass dependencies to objects allowing stub or mocks to be passed in in unit
tests. You can always [set a default](http://objectsonrails.com/#ID-cb3b155f-33cb-44da-9ee8-32d3a50cb24a)

### Functional tests

Functional tests are a powerful way to test a combination of controller, model
and view logic.

It's also possible to use mocking/stubbing to isolate the test subject to just
the controller.

The [view rendering](https://github.com/alphag
ov/whitehall/blob/master/test/support/view_rendering.rb) helper allows you to
choose whether or not rails views are rendered in your functional test:

    view_test "Should display the organisation contact details" do
      @organisation = create(:organisation, :with_contact_details)
      get :show, id: @organisation
      assert_select ".organisation .contact-details", text: @organisation.contact_details
    end

    test "Should update the organisation contact details" do
      @organisation = create(:organisation, :with_contact_details)
      put :update, id: @organisation, contact_details: "New contact details"
      assert_equal "New contact details", @organisation.reload.contact_details
    end

### Cucumber

- Only test the "happy path" behaviour, not exceptional behaviour.
- Only describe things that should *happen*, not things that shouldn't.
- Prefer large descriptive steps to small reusable ones.  DRY can be achieved at the Ruby level in the step definitions.
- Prefer steps written at a high level of abstraction.
- Write steps to be independent, not relying on the user being on a certain page.
- Avoid testing negatives; these are better tested in functional/unit tests.
- Avoid testing incidental behaviour (e.g. flash messages); these are better tested in functional/unit tests.
- Never call a cucumber step from within another one; extract the behaviour into a method which can be called from both.