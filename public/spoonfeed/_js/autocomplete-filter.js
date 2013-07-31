$(document).ready(function(){
  //for autocomplete controller
  $("#search_restaurant_eq_any_name").autocomplete({
    source: "/auto_complete.js?name=restaurant",
  }).data("autocomplete")._renderItem = function (ul, item) {
    if(["This keyword does not yet exist in our database.","RESTAURANTS BY NAME", "RESTAURANTS BY KEYWORD", "RESTAURANTS BY FEATURE", "RESTAURANTS BY CUISINE"].indexOf(item.label) > -1){
         return $("<li></li>")
             .data("item.autocomplete", item)
             .append("<font color='black'>" + item.label + "</font>")
             .appendTo(ul);
           }
           else{
              return $("<li></li>")
             .data("item.autocomplete", item)
             .append("<a>" + item.label + "</a>")
             .appendTo(ul);
           }
     };
  
  $("#search_restaurant_by_state_or_region").autocomplete({
    source: "/auto_complete.js?name=region",
  }).data("autocomplete")._renderItem = function (ul, item) {
    if(["This keyword does not yet exist in our database.","RESTAURANTS BY REGION", "RESTAURANTS BY STATE"].indexOf(item.label) > -1){
         return $("<li></li>")
             .data("item.autocomplete", item)
             .append("<font color='black'>" + item.label + "</font>")
             .appendTo(ul);
           }
           else{
              return $("<li></li>")
             .data("item.autocomplete", item)
             .append("<a>" + item.label + "</a>")
             .appendTo(ul);
           }
     };

  $('#search_person_eq_any_name').autocomplete({
    source: "/auto_complete.js?person=person"
  }).data("autocomplete")._renderItem = function (ul, item) {
    if(["This keyword does not yet exist in our database.","PERSONS BY NAME","PERSONS BY SPECIALITY","PERSONS BY CUISINE"].indexOf(item.label) > -1){
         return $("<li></li>")
             .data("item.autocomplete", item)
             .append("<font color='black'>" + item.label + "</font>")
             .appendTo(ul);
           }
           else{
              return $("<li></li>")
             .data("item.autocomplete", item)
             .append("<a>" + item.label + "</a>")
             .appendTo(ul);
           }
     };
  $("#search_person_by_state_or_region").autocomplete({
    source: "/auto_complete.js?person=region"
  }).data("autocomplete")._renderItem = function (ul, item) {
    if(["This keyword does not yet exist in our database.","PERSONS BY STATE","PERSONS BY REGION"].indexOf(item.label) > -1){
         return $("<li></li>")
             .data("item.autocomplete", item)
             .append("<font color='black'>" + item.label + "</font>")
             .appendTo(ul);
           }
           else{
              return $("<li></li>")
             .data("item.autocomplete", item)
             .append("<a>" + item.label + "</a>")
             .appendTo(ul);
           }
     };
  
});