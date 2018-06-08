var form =
    '<form id="taxon-form" class="js-supports-non-english" onsubmit="function(){return false;}"></form>'

var taxonBreadcrumbs =
'<div class="content">' +
'    <div class="taxon-breadcrumb">' +
'       <ol>' +
'           <li>Parent 1</li>' +
'           <li>Child 1</li>' +
'       </ol>' +
'   </div>' +
'    <div class="taxon-breadcrumb">' +
'       <ol>' +
'           <li>Parent 2</li>' +
'           <li>Child 2</li>' +
'       </ol>' +
'   </div>' +
'</div>';

var saveButton =
'<input type="button" id="save" name="save" value="Save topic changes" data-module="track-selected-taxons"' +
'   data-track-category="taxonSelection" data-track-label="/government/admin/editions/798947/tags/edit">';

module("TrackSelectedTaxons", {
    setup: function() {
        this.subject = new GOVUKAdmin.Modules.TrackSelectedTaxons();

        $('#qunit-fixture').append(form);
        $('#qunit-fixture form').append(taxonBreadcrumbs);
        $('#qunit-fixture form').append(saveButton);


        GOVUK.adminEditionsForm.init({
            selector: 'form#taxon-form',
            right_to_left_locales:["ar"]
        });
    }
});

test("the save button should send a GA event for each taxon breadcrumb", function () {
    var saveButton = $('#save');
    var spy = sinon.spy(GOVUKAdmin, 'trackEvent');

    this.subject.start(saveButton);

    saveButton.click();

    sinon.assert.calledTwice(spy);
    deepEqual(
        spy.args[0],
        ["taxonSelection", "Parent 1 > Child 1", {}]
    );
    deepEqual(
        spy.args[1],
        ["taxonSelection", "Parent 2 > Child 2", {}]
    );

    spy.restore()
});
