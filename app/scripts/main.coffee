L.mapbox.accessToken = 'pk.eyJ1IjoibWdhIiwiYSI6IldfSmVWeFkifQ.Uy4kxEzM5s1IPB59wStQMg';

class Viz

    constructor: (options) ->
        @voices = {}
        @gain = 0
        @minZoom = 18
        @maxZoom = 21
        # Set to ♭, ♮, or ♯
        @voices["yes"] = new Beep.Voice( '1A♭').setOscillatorType( 'square' ).setAttackDuration( 0 ).setDecayDuration( 0 ).setSustainDuration( 0.150 ).setReleaseDuration( 0 ).setAttackGain( 0.01 )
        @voices["no"] = new Beep.Voice( '1A♮').setOscillatorType( 'square' ).setAttackDuration( 0 ).setDecayDuration( 0 ).setSustainDuration( 0.150 ).setReleaseDuration( 0 ).setAttackGain( 0.01 )
        @voices["fix"] = new Beep.Voice( '1A♯').setOscillatorType( 'square' ).setAttackDuration( 0 ).setDecayDuration( 0 ).setSustainDuration( 0.150 ).setReleaseDuration( 0 ).setAttackGain( 0.01 )
        @voices["color"] = new Beep.Voice( '2B♭').setOscillatorType( 'square' ).setAttackDuration( 0 ).setDecayDuration( 0 ).setSustainDuration( 0.150 ).setReleaseDuration( 0 ).setAttackGain( 0.01 )
        @voices["address"] = new Beep.Voice( '3C♭').setOscillatorType( 'square' ).setAttackDuration( 0 ).setDecayDuration( 0 ).setSustainDuration( 0.150 ).setReleaseDuration( 0 ).setAttackGain( 0.01 )
        @voices["polygonfix"] = new Beep.Voice( '4D♭').setOscillatorType( 'square' ).setAttackDuration( 0 ).setDecayDuration( 0 ).setSustainDuration( 0.150 ).setReleaseDuration( 0 ).setAttackGain( 0.01 )
        @voices["toponym"] = new Beep.Voice( '5E♭').setOscillatorType( 'square' ).setAttackDuration( 0 ).setDecayDuration( 0 ).setSustainDuration( 0.150 ).setReleaseDuration( 0 ).setAttackGain( 0.01 )

        @map = L.mapbox.map('map', 'nypllabs.g6ei9mm0',
            zoomControl: false
            animate: true
            scrollWheelZoom: false
            attributionControl: false
            minZoom: @minZoom
            maxZoom: @maxZoom
            dragging: true
            tileLayer:
                detectRetina: false
        )

        L.control.zoom(
          position: 'topright'
        ).addTo(@map)

        L.easyButton("fa-play", @togglePlayPause, "PLAY/PAUSE", @map, "play_pause")

        @poly_style = {
            stroke: false
            fillColor: '#000'
            opacity: 0.2
        }

        @overlay = L.tileLayer('http://maptiles.nypl.org/859/{z}/{x}/{y}.png',
            detectRetina: false
            minZoom: @minZoom
            maxZoom: @maxZoom
        )

        @overlay.addTo(@map)

        @map.on 'load', () =>
            @initMap()

        @map.on 'zoomend', () =>
            @onMapZoom()

    togglePlayPause: () =>
        if @playing
            @stopAnimation()
            $(".fa-pause").removeClass("fa-pause").addClass("fa-play")
        else
            @startAnimation()
            $(".fa-play").removeClass("fa-play").addClass("fa-pause")

    initMap: () ->
        bounds = new L.LatLngBounds()

        # $.getJSON('/geojson/polygons-219.geojson', (geojson) =>
        #     @poly_219 = L.geoJson(geojson,
        #         style: (feature) =>
        #             @poly_style
        #     )
        #     @poly_219.addTo(@map)
        #     bounds.extend(@poly_219.getBounds())
        #     @map.fitBounds(bounds)
        # )

        $.getJSON('./geojson/polygons-226.geojson', (geojson) =>
            @poly_json = geojson
            @poly_layer = L.geoJson(geojson,
                style: (feature) =>
                    @poly_style
            )
            # @poly_layer.addTo(@map)
            bounds.extend(@poly_layer.getBounds())
            @map.fitBounds(bounds)
            @getHistory()
        )

    onMapZoom: () ->
        zoom = @map.getZoom()
        offset = (zoom - @minZoom) * 0.02
        @voices["yes"].setAttackGain( 0.01 + offset )
        @voices["no"].setAttackGain( 0.01 + offset )
        @voices["fix"].setAttackGain( 0.01 + offset )
        @voices["color"].setAttackGain( 0.01 + offset )
        @voices["address"].setAttackGain( 0.01 + offset )
        @voices["polygonfix"].setAttackGain( 0.01 + offset )
        @voices["toponym"].setAttackGain( 0.01 + offset )

    getHistory: () ->
        $.getJSON('./geojson/history-226.geojson', (geojson) =>
            @history = geojson.features
            # @startAnimation()
        )
        @current_event = 0

    startAnimation: () ->
        $("#help").remove()
        # console.log "start animation", @history
        @playing = true
        @nextEvent()

    stopAnimation: () ->
        @playing = false

    nextEvent: () =>
        obj = @buildEvent()
        if obj != null
            obj.addTo(@map)
            # @map.panTo(obj.getBounds().getCenter()) if !@map.getBounds().contains(obj.getBounds().getCenter())
            setTimeout((() => @killPolygon(obj)), 150 )
        @current_event++
        # console.log "showing", obj
        requestAnimationFrame(@nextEvent) if @playing && @current_event < @history.length # && @current_event < 4300

    buildEvent: () ->
        obj = @history[@current_event]
        geo = null

        type = obj.properties.flag_type
        flag = obj.properties.flag_value

        color = {}
        color["no"] = '#AF2228'
        color["yes"] = '#609846'
        color["fix"] = '#FFB92D'
        color["pink"] = '#F1B6BB'
        color["blue"] = '#00747A'
        color["yellow"] = '#FF9D00'
        color["green"] = '#37AD80'
        color["gray"] = '#303030'
        color["address"] = '#d75b25'
        color["toponym"] = '#fff'
        color["polygonfix"] = '#fff'
        color["multi"] = '#f0f'

        style = {
            stroke: false
            fillOpacity: 0.9
        }

        if type == "geometry"
            style.fillColor = color[flag]
            poly = @getPolygonForFlag(obj.properties.flaggable_id)
            geo = poly[0] if poly[0]
            @increaseElementValue("span.value.#{flag}")
            voice = @voices[flag]
            voice.play()
        else if type == "address"
            geo = obj
        else if type == "color"
            poly = @getPolygonForFlag(obj.properties.flaggable_id)
            geo = poly[0] if poly[0]
            if flag.indexOf(",") == -1
                style.fillColor = color[flag]
                @increaseElementValue("span.value.#{flag}")
            else
                style.fillColor = color["multi"]
                @increaseElementValue("span.value.multi")
        else if type == "toponym"
            geo = obj
        else if type == "polygonfix"
            style.fillColor = color[type]
            geo = obj

        if type != "geometry"
            voice = @voices[type]
            voice.play()

        @increaseElementValue("span.value.#{type}")
        @increaseElementValue("span.value.total")

        return null if geo == null

        L.geoJson(geo,
            pointToLayer: (f,latlng)->
                L.circle(latlng, 3,
                    color: color[type]
                    fillOpacity: 0.75
                    opacity: 0.5
                )
            style: style)

    increaseElementValue: (selector) ->
        legend = $("#legend")
        elem = $(legend.find(selector)[0])
        val = parseInt(elem.text())
        val++
        elem.text(val)

    getIndexForFlag: (flag_id) ->
        i for f, i in @history when f.properties.id == flag_id

    getPolygonForFlag: (poly_id) ->
        p for p in @poly_json.features when p.properties.id == poly_id

    killPolygon: (poly) ->
        @map.removeLayer(poly)

$ ->
  window._viz = new Viz