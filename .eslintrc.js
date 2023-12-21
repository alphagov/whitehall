module.exports = {
  extends: ['standard', 'prettier'],
  ignorePatterns: [
    'app/assets/javascripts/vendor/',
    'app/assets/javascripts/admin_legacy/**/*',
    'spec/javascripts/admin_legacy/**/*'
  ],
  env: {
    browser: true,
    jquery: true,
    jasmine: true,
    es6: true
  },
  globals: {
    GOVUK: 'readonly'
  }
}
