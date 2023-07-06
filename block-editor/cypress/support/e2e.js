// ***********************************************************
// This example support/e2e.js is processed and
// loaded automatically before your test files.
//
// This is a great place to put global configuration and
// behavior that modifies Cypress.
//
// You can change the location of this file or turn off
// automatically serving support files with the
// 'supportFile' configuration option.
//
// You can read more here:
// https://on.cypress.io/configuration
// ***********************************************************

// Add chai-subset assertions
import chaiSubset from 'chai-subset';
chai.use(chaiSubset);

// Import helpful commands
import './commands';

// Go to the test page before each test
beforeEach(() => {
  cy.visit('cypress/fixtures/test.html');
});
