# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


documentReady = ->
  $("#datepicker").datepicker({
    format: 'dd/mm/yyyy'
    })
  $(".datepicker").datepicker({
    format: 'dd/mm/yyyy'
    })

$(document).ready documentReady
$(document).on "page:load", documentReady
