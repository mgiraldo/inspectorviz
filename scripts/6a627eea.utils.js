!function(){for(var a=0,b=["ms","moz","webkit","o"],c=0;c<b.length&&!window.requestAnimationFrame;++c)window.requestAnimationFrame=window[b[c]+"RequestAnimationFrame"],window.cancelAnimationFrame=window[b[c]+"CancelAnimationFrame"]||window[b[c]+"CancelRequestAnimationFrame"];window.requestAnimationFrame||(window.requestAnimationFrame=function(b){var c=(new Date).getTime(),d=Math.max(0,16-(c-a)),e=window.setTimeout(function(){b(c+d)},d);return a=c+d,e}),window.cancelAnimationFrame||(window.cancelAnimationFrame=function(a){clearTimeout(a)})}(),L.Control.EasyButtons=L.Control.extend({options:{position:"topright",title:"",intendedIcon:"fa-circle-o"},onAdd:function(){var a=L.DomUtil.create("div","leaflet-bar leaflet-control");return this.link=L.DomUtil.create("a","leaflet-bar-part",a),this._addImage(),this.link.href="#",L.DomEvent.on(this.link,"click",this._click,this),this.link.title=this.options.title,a},intendedFunction:function(){alert("no function selected")},_click:function(a){L.DomEvent.stopPropagation(a),L.DomEvent.preventDefault(a),this.intendedFunction()},_addImage:function(){var a=0===this.options.intendedIcon.lastIndexOf("fa",0)?" fa fa-lg":" glyphicon",b=L.DomUtil.create("i",this.options.intendedIcon+a,this.link);b.id=this.options.id}}),L.easyButton=function(a,b,c,d,e){var f=new L.Control.EasyButtons;return a&&(f.options.intendedIcon=a),e&&(f.options.id=e),"function"==typeof b&&(f.intendedFunction=b),c&&(f.options.title=c),""===d||(d?d.addControl(f):map.addControl(f)),f};