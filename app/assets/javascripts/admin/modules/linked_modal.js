(function (Modules) {
  'use strict'

  /*
    If `data-toggle=modal` and `data-target` are used on a link element in
    Bootstrap 3, then Bootstrap attempts to load the contents of the link's
    href remotely, putting it into the modal container. There's no way of
    disabling this. (The feature is being removed in Bootstrap 4)

    We still want a link that works when js is broken or disabled. This
    is a workaround. Use `data-module=linked-modal` rather than
    `data-toggle=modal`
  */
  Modules.LinkedModal = function () {
    this.start = function (element) {
      element.on('click', openModal)

      function openModal (evt) {
        var $target = $(element.data('target'))
        $target.modal('show')
        evt.preventDefault()
      }
    }
  }
})(window.GOVUKAdmin.Modules)
