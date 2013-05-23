(function($) {
  $(function() {
    var $auditTrail = $("#history.audit-trail");
    $auditTrail.loading = false;
    $auditTrail.on('click', 'a[data-remote-pagination]', function(e) {
      e.preventDefault();
      if (($auditTrail.loading === false) || ($auditTrail.loading === undefined)) {
        var $this = $(this);
        var $toReplace = $this.parents('.audit-trail-page');
        $.ajax($this.data('remotePagination'), {
          cache: false,
          dataType:'html',
          beforeSend: function() {
            $auditTrail.loading = true;
            $toReplace.addClass('loading').find('a[data-remote-pagination]').text('Loading more...');
          },
          complete: function(){
            $auditTrail.loading = false;
          },
          success: function(data) {
            $toReplace.replaceWith(data);
          }
        });
      }
    });
  })
})(jQuery);