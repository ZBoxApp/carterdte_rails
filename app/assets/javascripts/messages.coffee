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
    
startSpinner = ->
    $("#searching-modal").modal('show')
    
stopSpinner = ->
    $("#searching-modal").modal('hide')
    
$(document).on "page:fetch", startSpinner
$(document).on "page:receive", stopSpinner

$(document).ready documentReady
$(document).on "page:load", documentReady
