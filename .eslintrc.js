module.exports = {
  extends: ['standard', 'prettier'],
  ignorePatterns: ['app/assets/javascripts/vendor/'],
  env: {
    browser: true,
    jasmine: true,
    es6: true
  },
  globals: {
    GOVUK: 'readonly'
  }
}
