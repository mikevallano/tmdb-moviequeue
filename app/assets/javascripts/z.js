$(document).ready(function() {

  // console.log("i see dead javascripts")


    // This hides the 'year select' field until a year is selected
    // $(function() {
    //   $("#year_select_discover_search").hide();
    //   $("#year_field_discover_search").on("change",function() {
    //     var year = this.value;
    //     if (year == "") return; // please select - possibly you want something else here

    //     $("#year_select_discover_search").show();
    //   });
    // });


// autocomplete


    $( "#movie_field_movie_search" ).autocomplete({
      minLength: 3,
      source: $('#movie_field_movie_search').data('autocomplete-source')
    });

    $( "#actor_name_actor_search" ).autocomplete({
      minLength: 3,
      source: $('#actor_name_actor_search').data('autocomplete-source')
    });



// the final closer
});