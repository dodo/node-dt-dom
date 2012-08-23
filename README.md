[![build status](https://secure.travis-ci.org/dodo/node-dt-dom.png)](http://travis-ci.org/dodo/node-dt-dom)
# [Δt DOM Adapter](https://github.com/dodo/node-dt-dom/)

This is an [DOM](http://www.w3.org/TR/dom/) Adapter for [Δt](http://dodo.github.com/node-dynamictemplate/).

It listen on the [template events](http://dodo.github.com/node-asyncxml/#section-4) and writes to the DOM.

→ [Check out the demo!](http://dodo.github.com/node-dynamictemplate/example/svg.html)

## Installation

```bash
$ npm install dt-dom
```

## How this Adapter works:

```html
<script src="dt-dom.browser.js"></script>
<scipt>
    var domify = window.dynamictemplate.domify; // get the dom adapter
</script>
```

Just throw your template in and add it to the DOM when it's ready:

```javascript
var tpl = domify(template(mydata));
tpl.ready(function () {
    tpl.dom.forEach(function (child) {
        document.getElementById('#container').appendChild(child);
    });
});
```

## Documentation

### domify(tpl)

```javascript
tpl = domify(new dynamictemplate.Template)
```
Expects a fresh [Δt](http://dodo.github.com/node-dynamictemplate/) [template instance](http://dodo.github.com/node-dynamictemplate/doc.html) (fresh means, instantiated in the same tick to prevent event loss).

It just simply listen for a bunch of events to manipulate the DOM.

Uses [requestAnimationFrame](http://paulirish.com/2011/requestanimationframe-for-smart-animating/) for heavy DOM manipulation like node insertion and node deletion.

----

Overrides the `query` method of the [async XML Builder](http://dodo.github.com/node-asyncxml/#section-3-1).

For query type `text` it returns the result of [textContent](https://developer.mozilla.org/en/DOM/Node.textContent).

For query type `attr` it returns the result of [getAttribute](https://developer.mozilla.org/en/DOM/element.getAttribute).

For query type `tag` it returns a dummy object that it will receive again on an `add` event.
