(function() {
  var horz, horz_params, position, vert, vert_params;

  vert_params = {
    outerDim: "outerHeight",
    pos_param: "top",
    margin_param: "margin-top",
    pad: 140
  };

  horz_params = {
    outerDim: "outerWidth",
    pos_param: "left",
    margin_param: "margin-left",
    pad: 10
  };

  vert = function(test_param) {
    vert_params.test_param = $(window).height();
    return vert_params;
  };

  horz = function(test_param) {
    horz_params.test_param = $(window).width();
    return horz_params;
  };

  position = function(el, params) {
    var el_dim, margin_param, outerDim, pad, pos_param, test_param;
    outerDim = params.outerDim, pad = params.pad, pos_param = params.pos_param, margin_param = params.margin_param, test_param = params.test_param;
    el_dim = el[outerDim]();
    if (el_dim + pad > test_param) {
      el.css('position', 'fixed');
      el.css(pos_param, "0px");
      return el.css(margin_param, "" + (pad / 2) + "px");
    } else {
      el.css("position", 'fixed');
      el.css(pos_param, '50%');
      return el.css(margin_param, "-" + (el_dim / 2) + "px");
    }
  };

  jQuery(document).ready(function() {
    var cent_horz, cent_vert, el, _i, _j, _len, _len2;
    cent_vert = (function() {
      var _i, _len, _ref, _results;
      _ref = $('.cent_vert');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        el = _ref[_i];
        _results.push($(el));
      }
      return _results;
    })();
    cent_horz = (function() {
      var _i, _len, _ref, _results;
      _ref = $('.cent_horz');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        el = _ref[_i];
        _results.push($(el));
      }
      return _results;
    })();
    for (_i = 0, _len = cent_vert.length; _i < _len; _i++) {
      el = cent_vert[_i];
      position(el, vert());
    }
    for (_j = 0, _len2 = cent_horz.length; _j < _len2; _j++) {
      el = cent_horz[_j];
      position(el, horz());
    }
    return $(window).resize(function() {
      var el, _k, _l, _len3, _len4;
      for (_k = 0, _len3 = cent_vert.length; _k < _len3; _k++) {
        el = cent_vert[_k];
        position(el, vert());
      }
      for (_l = 0, _len4 = cent_horz.length; _l < _len4; _l++) {
        el = cent_horz[_l];
        position(el, horz());
      }
      return null;
    });
  });

}).call(this);
