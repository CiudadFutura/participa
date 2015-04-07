colors=['#c3a6cf','#954e99','#612d62','#97c2b8','#269283']

draw_pie_chart = ($el, data) ->
  ctx = $el.get(0).getContext("2d")
  options = {
    responsive: true,
    legendTemplate:"",
    percentageInnerCutout : 50,
    animationEasing: "easeInOutCubic"
  }
  piechart = new Chart(ctx).Pie(data,options)


show_provinces = (country_code) ->
  $('#microcredit_loan_town').disable_control
  $('#microcredit_loan_province').disable_control
  $('#js-microcredit_loan-province-wrapper').load "/microcreditos/provincias?microcredit_loan_country=" + country_code, ->
    prov_select = $('select#microcredit_loan_province')
    if (prov_select.length>0 && prov_select.select2)
      prov_select.select2 {formatNoMatches: "No se encontraron resultados"}
    else
      show_towns null

no_towns_html="";
show_towns = (country_code, province_code) ->

  $('#microcredit_loan_town').disable_control
  if (province_code=="-")
    return

  if (province_code && country_code == "ES")
    url = "/microcreditos/municipios?microcredit_loan_country=ES&microcredit_loan_province=" + province_code
    has_towns = true
  else
    url = "/microcreditos/municipios"
    has_towns = false
  
  if (!has_towns && no_towns_html)
    $('#js-microcredit_loan-town-wrapper').html no_towns_html
  else
    $('#js-microcredit_loan-town-wrapper').load url, (response) ->
      if (has_towns)
        town_select = $('select#microcredit_loan_town')
        if (town_select.select2)
          town_select.select2 { formatNoMatches: "No se encontraron resultados" }
          options = town_select.children("option")
          if (options.length>1)
            postal_code = $('#microcredit_loan_postal_code').val
            prefix = options[1].value.substr(2,2)
            if (postal_code.length<5 || postal_code.substr(0, 2) != prefix)
              $('#microcredit_loan_postal_code').val prefix  
      else
        no_towns_html = response;

$ ->
  for graph in $(".js-mc-graph")
    vs = $('.js-mc-total', graph)
    parts = ({ value: parseInt($(v).html()), color:colors[Math.round(2*_i/vs.length)], highlight: colors[0], label: "" } for v in vs)
    parts.unshift({ value: parseInt($('.js-mc-pending', graph).html()), color:'#eeeeee', highlight: colors[3], label: "" })

    draw_pie_chart( $('canvas',graph), parts)

    $(".hide").hide()

  country_selector = $('select#microcredit_loan_country')
  if (country_selector.length>0)
    $.fn.disable_control = ->
      if (this.data("select2"))
        this.select2("enable", false).select2("val", "").attr("data-placeholder", "-").select2()
      else
        this.prop("disabled", true).val("").attr("placeholder", "-")
      return this

    country_selector.on "change", ->
      country = $(this).val()
      show_provinces( country )

    $(document.body).on "change", 'select#microcredit_loan_province', ->
      show_towns country_selector.val(), $(this).val()
