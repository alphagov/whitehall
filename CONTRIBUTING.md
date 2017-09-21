# Whitehall contributing guide

This guide covers the basics of how to contribute to the Whitehall project.

Ruby code should follow the rules below and also follow the [testing guideline
s](https://github.com/alphagov/whitehall/tree/master/docs/testing.md).

Frontend code should follow the [css](https://github.com/alphagov/whitehall/tree/master/docs/css.md) and [javascript](https://github.com/alphagov/whitehall/tree/master/docs/javascript.md) guidelines.

## Git workflow

- Make a branch
- Work in any way you like
- Rebase your branch into logical commits before sending a pull request -
  follow our [Git styleguide](https://github.com/alphagov/styleguides/blob/master/git.md)
- If you're working off the Trello backlog,
  include a link to the card in the pull request details
- Pull requests are automatically integration tested using [Jenkins](https://ci.integration.publishing.service.gov.uk/job/whitehall/),
  which will report back on whether the tests still pass on your
  branch
- You *may* rebase your branch after feedback if it's to include include relevant updates to the master branch. We prefer a rebase here to a merge commit as we prefer a clean and straight history on master with discrete merge commits for features

### Before merging:

1. Someone must review your code and approve it
2. Someone else must product/design review your changes
3. Merge your PR and delete the branch

## Copy

- Titles and navigation links should only capitalise first letter, not every word.
- URLs should use hyphens, not underscores.
- Follow the [style guide](https://www.gov.uk/guidance/style-guide).

## Code

- Don't commit additional whitespace
- Use ruby 1.9.2 hash syntax wherever possible
- Models should have:
  - All associations at the top
  - Then any scopes
  - Then validations
  - Then code
- Follow the [GOV.UK Ruby styleguide](https://github.com/alphagov/styleguides/blob/master/ruby.md)
