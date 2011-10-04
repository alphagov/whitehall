## Code ##

- Don't commit additional whitespace
- Use double quotes, not single quotes
- Use ruby 1.9.2 hash syntax wherever possible

## Testing ##

### Cucumber ###

- Only test the "happy path" behaviour, not exceptional behaviour.
- Only describe things that should *happen*, not things that shouldn't.
- Prefer large descriptive steps to small reusable ones.  DRY can be achieved at the Ruby level.
- Prefer steps written at a high level of abstraction.
- Write steps to be independent, not relying on the user being on a certain page.
- Avoid testing negatives; these are better tested in functional/unit tests.
- Avoid testing incidental behaviour (e.g. flash messages); these are better tested in functional/unit tests.
