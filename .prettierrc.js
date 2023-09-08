module.exports = {
  semi: false,
  singleQuote: true,
  trailingComma: 'none',
  overrides: [
    {
      files: '*.scss',
      options: {
        printWidth: 120,
        singleQuote: false
      }
    }
  ]
}
