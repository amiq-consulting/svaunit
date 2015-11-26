/* Scroll to top instantiation */
$(function() {
    $.scrollUp({
        scrollDistance : 100,
        scrollSpeed : 400,
        easingType : 'swing',
        animation : 'fade',
        animationSpeed : 200,
        scrollText : '<span class="badge">Top <span class="glyphicon glyphicon-chevron-up"></span></span>',
    });
});

/* Change the chevron for collapsable targets */
var toggleChevronFunction = function() {
    $(this).find("span").toggleClass("glyphicon-chevron-right glyphicon-chevron-down");
};
$('[data-toggle=collapse]').click(toggleChevronFunction);
$('[data-scroll^="#"]').click(function() {
    var id = $(this).data('scroll');
    if (! $(id).hasClass('in')) {
        $(id).collapse('show');
        $(id).siblings('[data-toggle=collapse]').each(toggleChevronFunction);
    };

    var position = 0;
    if ($(id).hasClass('panel-collapse') && $(id).parent().hasClass('panel')) {
        position = $(id).parent().offset().top;
    } else {
        position = $(id).offset().top;
    }
    $('html, body').animate({
        scrollTop : position
    }, 400);
});

/* Add bookmark url */
$(function() {
    $('body').prepend('<div class="modal fade" id="save-modal" tabindex="-1" role="dialog" aria-hidden="true"><div class="modal-dialog modal-lg"><div class="modal-content"><div class="modal-header"><h4 class="modal-title">Save this URL to restore the documentation on this page:</h4></div><div class="modal-body"><textarea class="form-control save-url" rows="4" wrap="soft" readonly></textarea></div><div class="modal-footer"><button type="button" class="btn btn-default" data-dismiss="modal">Close</button></div></div></div></div>');
    $('body').prepend('<a id="bookmark"><span class="badge"><span class="glyphicon glyphicon-star"></span></span></a>');
    $('#bookmark').click(function() {
        var href = window.location.href;
        var base = href.substring(0, href.lastIndexOf("/") + 1);
        var page = href.substring(href.lastIndexOf("/") + 1, href.length);
        var $textArea = $('#save-modal textarea');
        $textArea.val(base + 'index.html?' + page);
        $textArea.click(function() {
            $(this).select();
        });
        $("#save-modal").modal('show');
    });
});

