
vert_params =
  outerDim: "outerHeight"
  pos_param: "top"
  margin_param: "margin-top"
  pad: 140
horz_params  =
  outerDim: "outerWidth"
  pos_param: "left"
  margin_param: "margin-left"
  pad: 10

vert = (test_param) ->
  vert_params.test_param = $(window).height()
  vert_params

horz = (test_param) ->
  horz_params.test_param = $(window).width()
  horz_params

position = (el, params)->
  { outerDim, pad, pos_param, margin_param, test_param } = params

  el_dim = el[outerDim]()

  if el_dim + pad > test_param
    el.css 'position', 'absolute'
    el.css pos_param, "0px"
    el.css margin_param, "#{pad/2}px"
  else
    el.css "position", 'fixed'
    el.css pos_param, '50%'
    el.css margin_param, "-#{el_dim/2}px"

jQuery(document).ready ->
  cent_vert = ($ el for el in $ '.cent_vert')
  cent_horz = ($ el for el in $ '.cent_horz')
  for el in cent_vert
    el.css 'height', el.height()
    position el, vert()

  for el in cent_horz
    el.css 'width', el.width()
    position el, horz()

  $(window).resize ->
    position el, vert() for el in cent_vert
    position el, horz()  for el in cent_horz
    null
