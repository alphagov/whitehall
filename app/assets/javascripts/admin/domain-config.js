'use strict'
window.GOVUK.vars.extraDomains = [
  {
    name: 'production',
    domains: ['whitehall-admin.publishing.service.gov.uk'],
    initialiseGA4: true,
    id: 'GTM-KHZP7S7Q',
    gaProperty: 'UA-26179049-6'
  },
  {
    name: 'staging',
    domains: ['whitehall-admin.staging.publishing.service.gov.uk'],
    initialiseGA4: false
  },
  {
    name: 'integration',
    domains: ['whitehall-admin.integration.publishing.service.gov.uk'],
    initialiseGA4: true,
    id: 'GTM-KHZP7S7Q',
    auth: '8jHx-VNEguw67iX9TBC6_g',
    preview: 'env-50'
  }
]
