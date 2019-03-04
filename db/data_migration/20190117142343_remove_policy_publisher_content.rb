puts 'Unpublishing /government/policies/school-and-college-funding-and-accountability/email-signup and redirecting to /email-signup/?topic=/education/school-and-academy-funding'
Services.publishing_api.unpublish(
  '377e1772-a6d5-454c-836f-f9c282457b0e',
  type: 'redirect',
  alternative_path: '/email-signup/?topic=/education/school-and-academy-funding',
  discard_drafts: true
)

puts 'Unpublishing /government/policies/all and redirecting to /'
Services.publishing_api.unpublish(
  'ccb6c301-2c64-4a59-88c9-0528d0ffd088',
  type: 'redirect',
  alternative_path: '/'
)
