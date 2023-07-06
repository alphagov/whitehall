const imgPath = (filename) => (`cypress/fixtures/images/${filename}`);

describe('Image tool', () => {
  it('can be created', () => {
    cy.createEditor();
    cy.addBlock('Image');
    cy.contains('Select an Image').selectFile(imgPath('sydney.jpg'));
    cy.contains('Crop').click();
    cy.placeholder('Caption').type('Sydney Opera House');

    // Check resultant image dimensions
    const img = cy.get('img.preview');
    img.should('have.prop', 'naturalWidth', 960);
    img.should('have.prop', 'naturalHeight', 640);
  });
});
