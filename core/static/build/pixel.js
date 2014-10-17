// Generated by CoffeeScript 1.6.1
(function() {
  var engine, sleep, template;

  engine = new CoffeeTemplates();

  template = function(l, t) {
    return engine.render(t, l);
  };

  sleep = function(x, y) {
    return setTimeout(y, x * 1000);
  };

  $(function() {
    $("body").append(template({}, function() {
      br();
      return div(".container", function() {
        return form(".col-md-6.col-md-offset-3.form-horizontal", {
          role: "form"
        }, function() {
          div(".form-group.form-group-lg", function() {
            label(".col-sm-3.control-label", {
              "for": "inputEmail3"
            }, "Storage plugin");
            return div(".col-sm-9", function() {
              return select(".form-control", {
                id: "ppp"
              }, function() {
                return option("Behaviour Storage Plugin");
              });
            });
          });
          div(".form-group.form-group-lg", function() {
            label(".col-sm-3.control-label", {
              "for": "inputEmail3"
            }, "AWS Region");
            return div(".col-sm-9", function() {
              return select(".form-control", {
                id: "region"
              }, function() {
                var r, regions, _i, _len, _results;
                regions = ["us-east-1", "us-west-1", "us-west-2", "eu-west-1", "sa-east-1", "ap-northeast-1", "ap-southeast-1", "ap-southeast-2"];
                _results = [];
                for (_i = 0, _len = regions.length; _i < _len; _i++) {
                  r = regions[_i];
                  _results.push(option(r));
                }
                return _results;
              });
            });
          });
          return div(".form-group", function() {
            return div(".col-sm-offset-3.col-sm-10", function() {
              return button(".btn.btn-primary.btn-lg", {
                id: "deploy",
                type: "button"
              }, function() {
                span({
                  id: "deploy_text"
                }, function() {
                  return "Deploy";
                });
                return i({
                  id: "deploy_glyph"
                }, function() {});
              });
            });
          });
        });
      });
    }));
    return $("#deploy").bind("click", function() {
      $("#deploy").blur().removeClass("btn-primary").addClass("btn-warning");
      $("#deploy_glyph").css({
        "margin-left": "10px"
      }).addClass("fa fa-spinner fa-spin");
      $("#deploy_text").text("Deploying...");
      return sleep(2, function() {
        $("#deploy").removeClass("btn-warning").addClass("btn-success");
        $("#deploy_text").text("Deployed!");
        $("#deploy_glyph").removeClass("fa-spinner fa-spin").addClass("fa-check");
        return $("body").append(template({}, function() {
          br();
          return form(".form-horizontal", {
            role: "form"
          }, function() {
            return div(".form-group.form-group-lg", function() {
              label(".col-sm-4.control-label", {
                "for": "formGroupInputLarge"
              }, "Pixel URL");
              return div(".col-sm-6", function() {
                var pixelUrl;
                pixelUrl = "http://" + $("#region").val() + ".demo.pixels.datacratic.com/channel/8956/pixel.gif";
                return input("#formGroupInputLarge.form-control", {
                  type: "text",
                  value: pixelUrl
                });
              });
            });
          });
        }));
      });
    });
  });

}).call(this);