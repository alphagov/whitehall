## Code ##

- Don't commit additional whitespace
- Use double quotes, not single quotes
- Use ruby 1.9.2 hash syntax wherever possible

## Testing ##

### Cucumber ###

- Only use cucumber to describe things that should happen, not things that shouldn't
- Prefer large descriptive steps to small reusable ones.  DRY can be achieved at the ruby level.
- Write steps to be independent, not relying on the user being on a certain page.
