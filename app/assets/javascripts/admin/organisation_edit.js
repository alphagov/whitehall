(function () {

    var root = this,
        $ = root.jQuery;

    var GOVUK = root.GOVUK || {};

    GOVUK.hideClosedAtDates = function() {
        $closedAtGroup = $('#organisation_closed_at_group'),
        $closedAtLabel = $closedAtGroup.prev('label[for=organisation_closed_at]'),
        $govUkStatus = $('#organisation_govuk_status');

        function toggleShown(status) {
            if (status === 'closed') {
                $closedAtLabel.show();
                $closedAtGroup.show();
                $closedAtGroup.find('select').each(function(el) {
                    // some older browsers are weird, so explicitly use the expando
                    el.disabled = false;
                    $(el).removeAttr('disabled');
                });
            }
            else {
                $closedAtLabel.hide();
                $closedAtGroup.hide();
                $closedAtGroup.find('select').each(function(el) {
                    // some older browsers are weird, so explicitly use the expando
                    el.disabled = true;
                    $(el).attr('disabled', true);
                });
            }
        }

        if ($closedAtGroup && $closedAtLabel) {
            toggleShown($govUkStatus.val());
            $govUkStatus.on('change', function(e) {
                toggleShown($(this).val());
            });
        }
    }

}).call(this);
