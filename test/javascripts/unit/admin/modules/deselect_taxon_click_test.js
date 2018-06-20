module("DeselectTaxonClick", {
    setup: function () {
        var form =
            '<form id="taxon-form" class="js-supports-non-english"></form>';

        var checkboxToDeselect =
            '<input type="checkbox" id="deselect-me" data-taxon-name="Child 1">';
        var siblingCheckbox =
            '<input type="checkbox" id="sibling" data-taxon-name="Sibling 1">';
        var parentCheckBox =
            '<input type="checkbox" id="parent" data-taxon-name="Parent 1">';

        var wrapCheckBox = function(contents){
            return '<p>' +
                '   <label>' +
                contents +
                '   </label>' +
                '</p>';
        };

        var taxonomyTree =
            '<div class="topics">' +
            wrapCheckBox(parentCheckBox) +
            '   <div class="topics">' +
            wrapCheckBox(checkboxToDeselect) +
            wrapCheckBox(siblingCheckbox) +
            '   </div>' +
            '</div>';

        var breadcrumbs =
            '<div class="content">' +
            '    <div class="taxon-breadcrumb">' +
            '       <button class="close deselect-taxon-button"  id="deselect-this-one">X</button>' +
            '       <ol>' +
            '           <li>Parent 1</li>' +
            '           <li>Child 1</li>' +
            '       </ol>' +
            '   </div>' +
            '    <div class="taxon-breadcrumb">' +
            '       <ol>' +
            '           <li>Parent 1</li>' +
            '           <li>Sibling 1</li>' +
            '       </ol>' +
            '   </div>' +
            '</div>';

        this.subject = new GOVUKAdmin.Modules.DeselectTaxonClick();

        $('#qunit-fixture').append(form);
        $('#qunit-fixture form').append(taxonomyTree);
        $('#qunit-fixture form').append(breadcrumbs);


        GOVUK.adminEditionsForm.init({
            selector: 'form#taxon-form',
            right_to_left_locales: ["ar"]
        });
    }
});

test("The remove button should deselect only the associated taxon if sibling is selected", function () {
    var removeButton = $('#deselect-this-one');
    debugger;
    $('#parent').prop('checked', true);
    $('#deselect-me').prop('checked', true);
    $('#sibling').prop('checked', true);

    this.subject.start(removeButton);

    removeButton.click();

    equal($('#deselect-me').is(':checked'), false, "deselect-me should have been de-selected");
    equal($('#parent').is(':checked'), true, "parent should not have been de-selected");
    equal($('#sibling').is(':checked'), true, "sibling should not have been de-selected")
});

test("The remove button should deselect the parent if no sibling is selected", function () {
    var removeButton = $('#deselect-this-one');
    $('#parent').prop('checked', true);
    $('#deselect-me').prop('checked', true);
    $('#sibling').prop('checked', false);

    this.subject.start(removeButton);

    removeButton.click();

    equal($('#deselect-me').is(':checked'), false, "deselect-me should have been de-selected");
    equal($('#parent').is(':checked'), false, "parent should have been de-selected");
    equal($('#sibling').is(':checked'), false, "sibling should have left alone");
});
