var ready;
ready = function() {

  $( "#movie_field_movie_search" ).autocomplete({
    minLength: 4,
    source: $("#movie_field_movie_search").data("autocomplete-source")
  });

  // $( "#homepage-search-field" ).autocomplete({
  //   minLength: 4,
  //   source: $("#homepage-search-field").data("autocomplete-source")
  // });

  $( "#actor_name_actor_search" ).autocomplete({
    minLength: 4,
    source: $("#actor_name_actor_search").data("autocomplete-source")
  });

  $( "#actor_field_discover_search" ).autocomplete({
    minLength: 4,
    source: $("#actor_field_discover_search").data("autocomplete-source")
  });

  $( "#actor1_field_two_actor_search" ).autocomplete({
    minLength: 4,
    source: $("#actor1_field_two_actor_search").data("autocomplete-source")
  });

  $( "#actor2_field_two_actor_search" ).autocomplete({
    minLength: 4,
    source: $("#actor2_field_two_actor_search").data("autocomplete-source")
  });

  $( "#movie1_field_two_movie_search" ).autocomplete({
    minLength: 4,
    source: $("#movie1_field_two_movie_search").data("autocomplete-source")
  });

  $( "#movie2_field_two_movie_search" ).autocomplete({
    minLength: 4,
    source: $("#movie2_field_two_movie_search").data("autocomplete-source")
  });

};

$(document).ready(ready);
$(document).on('page:load', ready);





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




// the final closer
