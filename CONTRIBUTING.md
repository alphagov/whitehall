## Copy ##

- Titles and navigation links should only capitalise first letter, not every word.
- URLs should use hyphens, not underscores.
- Follow the [style guide](https://www.gov.uk/designprinciples/styleguide).

## Code ##

- Don't commit additional whitespace
- Use ruby 1.9.2 hash syntax wherever possible
- Models should have:
  - All associations at the top
  - Then any scopes
  - Then validations
  - Then code

## Testing ##

Write tests.

### Cucumber ###

- Only test the "happy path" behaviour, not exceptional behaviour.
- Only describe things that should *happen*, not things that shouldn't.
- Prefer large descriptive steps to small reusable ones.  DRY can be achieved at the Ruby level.
- Prefer steps written at a high level of abstraction.
- Write steps to be independent, not relying on the user being on a certain page.
- Avoid testing negatives; these are better tested in functional/unit tests.
- Avoid testing incidental behaviour (e.g. flash messages); these are better tested in functional/unit tests.
- Never call a cucumber step from within another one; extract the behaviour into a method which can be called from both.