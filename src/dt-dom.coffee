{ Animation } = require 'animation'

# TODO i think this should work with asyncxml as well
# TODO listen on data and use innerHTML to create all dom elems at once
#       http://blog.stevenlevithan.com/archives/faster-than-innerhtml

# TODO listen for dom events to know when a dom manipulation is ready
# TODO mit canvas tag kommt man direkt auf die browser render ticks.

animation = new Animation
    execution:'5ms'
    timeout:'120ms'
    toggle:on

nextAnimationFrame = (callback) ->
    animation.push   (callback)

# delay or invoke job immediately
delay = (job) ->
    # only when tag is ready
    if @_dom?
        do job
    else
        @_dom_delay ?= []
        @_dom_delay.push(job)


# invoke all delayed jquery work
release = () ->
    if @_dom_delay?
        for job in @_dom_delay
            do job
        delete @_dom_delay


# FIXME namespaced attrs?

domify = (tpl) ->
    animation.start()

    tpl.on 'add', (parent, el) ->
        # insert into parent
        delay.call parent, ->
            if parent is tpl.xml
                parent._dom.push(el._dom)
            else
                nextAnimationFrame ->
                    parent._dom.appendChild(el._dom)

    tpl.on 'close', (el) ->
        # FIXME hm, ... namespace handling should be in asyncxml
        el._namespace = el.attrs['xmlns'] # FIXME more tolerant check, plz

        if el._namespace?
            el._dom ?= document.createElementNS(el._namespace, el.name)
        else
            el._dom ?= document.createElement(el.name)
        for key, value of el.attrs
            el._dom.setAttribute(key, value)
        release.call el

    tpl.on 'text', (el, text) ->
        delay.call el, ->
            # el._dom.appendChild(el._dom.ownerDocument.createTextNode(text))
            el._dom.textContent = text

    tpl.on 'raw', (el, html) ->
        delay.call el, ->
            nextAnimationFrame ->
                el._dom.innerHTML = html

    tpl.on 'show', (el) ->
        delay.call el, ->
            #el._jquery.show() ####################################
            # save old-display value in data-display and set new display value visivle or not

    tpl.on 'hide', (el) ->
        delay.call el, ->
            #el._jquery.hide() ####################################

    tpl.on 'attr', (el, key, value) ->
        delay.call el, ->
            el._dom.setAttribute(key, value)

    tpl.on 'attr:remove', (el, key) ->
        delay.call el, ->
            el._dom.removeAttribute(key)

    tpl.on 'replace', (el, tag) ->
        delay.call el, ->
            nextAnimationFrame ->
                _dom = tag._dom ? tag
                return unless _dom?.length > 0
                el.parent?._dom?.replaceChild(_dom)
                # replaceChild isnt inplace
                el._dom = _dom
                if el is tpl.xml
                    el.dom = _dom

    tpl.on 'remove', (el) ->
        el.parent?._dom?.removeChild(el._dom) if el._dom?

    tpl.on 'end', ->
        tpl.xml._dom = []
        release.call tpl.xml
        tpl.dom = tpl.xml._dom

    old_query = tpl.xml.query
    tpl.xml.query = (type, tag, key) ->
        return old_query.call(this, type, tag, key) unless tag._dom?
        if type is 'attr'
            tag._dom.getAttribute(key)
        else if type is 'text'
            tag._dom.text or tag._dom.textContent or tag._dom.innerHTML or ""
        else if type is 'tag'
            if key._dom?
                key
            else# FIXME this doesnt get invoked because of the return
                # assume this is allready a dom object
                {_dom:key}

    return tpl

# exports

module.exports = domify

# browser support

( ->
    if @dynamictemplate?
        @dynamictemplate.domify = domify
    else
        @dynamictemplate = {domify}
).call window if process.title is 'browser'
