

window.providers = 
    beh:
        name: "Behaviour Storage Plugin"
        description: "Store high volume behavioral data in (who, what, when) format."
        uri: "/plugins/beh.html"
        image: "logo.png"
    pixel:
        name: "Pixel Input Plugin"
        description: "Deploy a pixel to collect behavioral data."
        uri: "/plugins/pixel.html"
        icon: "cloud-upload"
    sql:
        name: "SQL Query Plugin"
        description: "Query your data with SQL and make it available to your ORM or application."
        uri: "/plugins/sql.html"
        image: "SQLMath.png"
    prediction:
        name: "Recommender Query Plugin"
        description: "Real-time query of product recommendations with a customizable machine learning based algorithm."
        uri: "/plugins/prediction.html"
        image: "cart.jpg"
    nb:
        name: "Data Science Query Plugin"
        description: "Make your dataset available to Python based data science tools within your normal environment."
        uri: "/plugins/nb.html"
        image: "ipython.jpg"
    viz:
        name: "Visualization Query Plugin"
        description: "Clustering and exploration of behavioral data."
        uri: "http://opensource.datacratic.com/data-projector/"
        image: "vis.png"
    mongo:
        name: "MongoDB Storage Plugin"
        description: "Connect to an existing MongoDB database and make it available for machine learning."
        image: "/mongo.png"
    rtbkit:
        name: "RTBkit Delivery Plugin"
        description: "Push predictions into RTBkit for personalized real-time bidding."
        image: "/rtbkit.png"
    exacttarget:
        name: "ExactTarget Delivery Plugin"
        description: "Push predictions into ExactTarget for personalized email."
        image: "/exacttarget.jpeg"
    hadoop:
        name: "Hadoop Storage Plugin"
        description: "Connect to an existing Hadoop system via HBase to make the data available."
        image: "hadoop_logo.jpg"
    pg:
        name: "PostgreSQL Storage Plugin"
        description: "Connect to an existing PostgreSQL database to make the data available."
        image: "postgres.png"
    mm:
        name: "MetaMarkets Query Plugin"
        description: "Use MetaMarkets' real-time rollup system to make pivoting and exporation available."
        image: "metamarkets.png"

class Backend
    constructor: ->
        @state = JSON.parse localStorage.state if localStorage.state?
        @state ?= @default_state()
        @state.plugins ?= []


    default_state: -> plugins:[]

    reset: (cb) ->
        @state = @default_state()
        @commit()
        cb()

    post: (url, data, cb = ->) ->
        switch url
            when "/plugins"
                i = @state.plugins.push data
                @state.plugins[i-1].id=i-1
                @commit()
                cb i
                return false
            when "/dbname"
                @state.dbname = data
                @commit()
                cb()
                return false
        return false

    get: (url, data, cb = ->) ->
        switch url
            when "/plugins"
                if data?
                    cb @state.plugins[data]
                    return false
                cb (x for x in @state.plugins when x?)
                return false
            when "/dbname"
                cb @state.dbname
                return false
        return false

    delete: (url, data, cb = ->) ->
        switch url
            when "/plugins"
                delete @state.plugins[data]
                @commit()
                cb()
                return
        return false

    commit: ->
        localStorage.state = JSON.stringify @state


backend = new Backend()

engine = new CoffeeTemplates()
template = (l,t) -> engine.render(t,l)
sleep = (x, y) -> setTimeout y, x*1000

_ = -> 
    backend.get "/dbname", null, (dbname) ->
        if dbname?
            renderPlugins(dbname)
        else
            askForName()

askForName = ->
    $("#contents").append template {}, ->
        form ".col-md-6.col-md-offset-3.form-horizontal", role: "form", id:"deployForm", ->
          div ".form-group.form-group-lg", ->
                label ".col-sm-4.control-label", for: "formGroupInputLarge", "Name Your Database:"
                div ".col-sm-6", ->
                  input ".form-control", type: "text", id: "dbname", ->

          div ".form-group", ->
            div ".col-sm-offset-4.col-sm-10", ->
                button ".btn.btn-primary.btn-lg", id:"deploy", type: "submit", ->
                    span id:"deploy_text", -> "Create"
                    i id:"deploy_glyph", ->

    $("#deployForm").bind "submit", ->
        $("#deploy").blur().removeClass("btn-primary").addClass("btn-warning")
        $("#deploy_glyph").css("margin-left":"10px").addClass("fa fa-spinner fa-spin")
        $("#deploy_text").text("Creating...")
        sleep 0.5, -> backend.post "/dbname", $("#dbname").val(), refresh
        return false


renderPlugins = (dbname) ->

    backend.get "/plugins", null, (plugins) ->
        $("#contents").append template {dbname, plugins}, ->
            h1 ".text-center", "Database: " + @dbname

            h3 "Installed Plugins"
            br()
            a ".list-group-item", href: "#/providers", -> 
                span ".pull-left", style:"font-size: 3.5em; width: 80px", -> 
                    i ".fa.fa-plus-square-o", ->
                h4 "Install a plugin..."
                p "Visit our Plugin Store"
            a ".list-group-item", href: "#/", -> 

                div ".pull-right", style: "margin: 20px;", ->
                    p -> "Free!"
                span ".pull-left", style:"font-size: 3.5em; width: 80px", -> 
                    i ".fa.fa-plus-square-o", ->
                h4 "Deploy a custom plugin..."
                p "Use your own infrastructure to host your code."

            for t in @plugins
                a ".list-group-item", href:"#/plugins/"+t.id, -> 
                    button ".close.pull-right.deleteplugin", type: "button", "data-tid": t.id, ->
                      span "aria-hidden": "true", "&times;"

                    div ".pull-right", style: "margin: 20px;", ->
                        p -> "$15/month"
                    span ".pull-left", style:"font-size: 3.5em; width: 80px", -> 
                        if t.icon?
                            i ".fa.fa-#{t.icon}", ->
                        else if t.image?
                            img src:t.image, width: 50, height: 50
                    h4 t.name
                    p t.description

        $(".deleteplugin").bind "click", ->
            backend.delete "/plugins", $(this).data("tid"), refresh
            return false

_providers = ([ignore, plugin_id]) ->
    backend.get "/plugins", null, (plugins) ->
        $("#contents").append template {plugins}, -> 
            h1 ".text-center", "Plugin Store"
            br()
            br()
            div class:"row", id:"tile_row", ->
                for k, prov of window.providers
                    div "#myModal#{k}.modal.fade", tabindex: "-1", role: "dialog", "aria-labelledby": "myModalLabel", "aria-hidden": "true", ->
                      div ".modal-dialog", ->
                        div ".modal-content", ->
                          div ".modal-header", ->
                            button ".close", type: "button", "data-dismiss": "modal", ->
                              span "aria-hidden": "true", "&times;"
                              span ".sr-only", "Close"
                            div ".text-center", style:"font-size: 6em", -> 
                                if prov.icon?
                                    i ".fa.fa-#{prov.icon}", ->
                                else if prov.image?
                                    img src:prov.image, width: 100, height: 100
                            h2 "#myModalLabel.modal-title.text-center", prov.name
                          div ".modal-body", ->
                            p prov.description
                            p ".pull-right", "Cost: $15/month"
                            br()
                          div ".modal-footer", ->
                            button ".btn.btn-default", type: "button", "data-dismiss": "modal", "Close"
                            if not prov.uri?
                                button ".btn.btn-primary.disabled", type: "button", "data-prov": k, "Plugin coming soon!"
                            else
                                for t in @plugins when t.name == prov.name
                                    alreadyThere = true
                                if alreadyThere
                                    button ".btn.btn-primary.disabled", type: "button", "data-prov": k, "Plugin already installed"
                                else
                                    button ".btn.btn-primary.addplugin", type: "button", "data-prov": k, ->
                                        span ".btntxt", -> "Install plugin"
                                        i ".btnglyph", ->

                    div class:"col-md-3", ->
                        div class:"panel panel-default", style:"height: 200px", ->
                            div class:"panel-heading", ->
                                h3 class:"panel-title", -> prov.name
                            div class:"panel-body text-center   ", ->
                                span style:"font-size: 6em", ->
                                    a href:"", "data-toggle": "modal", "data-target": "#myModal#{k}", -> 
                                        if prov.icon?
                                            i ".fa.fa-#{prov.icon}", ->
                                        else if prov.image?
                                            img src:prov.image, width: 100, height: 100

    $(".addplugin").bind "click", ->
        $(this).blur().removeClass("btn-primary").addClass("btn-warning")
        $(this).find(".btnglyph").css("margin-left":"10px").addClass("fa fa-spinner fa-spin")
        $(this).find(".btntxt").text("Installing...")
        provId = $(this).data("prov")
        sleep 0.5, -> 
            backend.post "/plugins", providers[provId], -> jumpto "#/"
        return false
        

_plugin = ([ignore, plugin_id]) ->
    backend.get "/plugins", plugin_id, (plugin) ->
        $("#contents").append template {plugin}, -> 
            div class:"panel panel-default", style:"width:100%; height:100%;", ->
                div class:"panel-heading", ->
                    h3 class:"panel-title", -> 
                        i ".fa.fa-#{@plugin.icon}", style:"margin-right: 10px", ->
                        text @plugin.name
                iframe class:"panel-body text-center", style:"width:100%; height:100%; border: none;", src:@plugin.uri, ->

refresh = ->
    $("body").empty()
    $("body").append template {}, -> 
        div class: "navbar navbar-default navbar-static-top", role:"navigation", ->
            div class:"container", ->
                div class:"navbar-header", ->
                    button type:"button", class:"navbar-toggle collapsed", "data-toggle":"collapse", "data-target":".navbar-collapse", ->
                        span class:"sr-only", -> "Toggle navigation"
                        span class:"icon-bar", ->
                        span class:"icon-bar", ->
                        span class:"icon-bar", ->
                    a href: "#", -> img class:"navbar-left", src:"/logo.png", height: "50"
                    a class:"navbar-brand", href: "#", -> 
                        text "&nbsp;PredictiveDB"
                div class:"navbar-collapse collapse", ->
                    ul class:"nav navbar-nav navbar-right", ->
                        li class:"dropdown", ->
                            a href:"#", class:"dropdown-toggle", "data-toggle":"dropdown", ->
                                span class:"glyphicon glyphicon-cog", ->
                            ul class:"dropdown-menu", role:"menu", ->
                                li -> a href:"#", id:"reset_local_storage", -> "Reset Local Storage"
        div class:"container", id:"contents", ->    
        div ".footer", ->
          div ".container", ->
            p ".pull-right.text-muted", ->
                a href:"", "Terms of Use"
                text " – "
                a href:"", "Privacy Policy"
            p ".text-muted", "© 2014 Datacratic Inc."

    $("#reset_local_storage").bind "click", -> backend.reset -> jumpto "#/"



    here = window.location.hash
    routes = 
        "#/plugins/([0-9]+)": _plugin
        "#/providers": _providers
    for re, route of routes when RegExp(re).test here
        route(here.match(re)) 
        return false
    _()
    return false

jumpto = (hashUrl) ->
    history.pushState {}, "", hashUrl
    refresh()
$ ->
    window.onpopstate = refresh
    refresh() 

