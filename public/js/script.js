jQuery(document).ready(function() {
    jQuery('form.delete').submit(function(){
        return confirm('Are you sure you want to delete this level?');
    });
});
