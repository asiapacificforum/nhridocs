import $ from 'jquery'
import 'jquery-ui'
window.jquery = $
import Ractive from 'ractive'

SingleMonthDatepicker = (node)->
  $(node).datepicker
    #altField: $(node).attr['id'] can't use this b/c it doesn't trigger ractive change
    maxDate: null
    defaultDate: new Date()
    changeMonth: true
    changeYear: true
    numberOfMonths: 1
    dateFormat: "M d, yy"
    onClose: (selectedDate) ->
      unless selectedDate == ""
        object = Ractive.getNodeInfo(node).ractive
        object.set('formatted_date',selectedDate)
  teardown : ->
    $(node).datepicker('destroy')

#Ractive.decorators.single_month_datepicker = SingleMonthDatepicker
export default SingleMonthDatepicker
