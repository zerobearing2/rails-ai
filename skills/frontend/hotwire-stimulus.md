---
name: hotwire-stimulus
domain: frontend
dependencies: []
version: 1.0
rails_version: 8.1+
gem_requirements:
  - stimulus-rails: 1.3.0+
---

# Hotwire Stimulus

Stimulus is a modest JavaScript framework that connects JavaScript objects to HTML elements using data attributes, enhancing server-rendered HTML.

<when-to-use>
- Adding interactive behavior to server-rendered HTML
- Need lightweight JavaScript for progressive enhancement
- Want to avoid heavy JavaScript frameworks
- Building reusable JavaScript behaviors
- Need to respond to DOM events (clicks, inputs, hovers)
- Managing form interactions and validations
</when-to-use>

<benefits>
- **Progressive Enhancement** - Works with existing HTML
- **Small Bundle** - ~30KB minified
- **No Build Step** - Works directly with Rails asset pipeline
- **Easy to Learn** - Simple concepts and clear conventions
- **Reusable** - Controllers can be applied to multiple elements
- **Turbo Compatible** - Works seamlessly with Turbo Drive/Frames
</benefits>

<standards>
- Controllers are JavaScript classes extending `Controller`
- Controller files go in `app/javascript/controllers/`
- Use `data-controller` to connect controllers to HTML
- Use `data-action` to connect events to controller methods
- Use `data-{controller}-target` to find elements
- Use `data-{controller}-{name}-value` for typed data attributes
- Stimulus runs on `turbo:load` and `turbo:frame-load` events
- Always clean up in `disconnect()` lifecycle method
</standards>

## Core Concepts

<pattern name="basic-controller">
<description>Simple Stimulus controller with lifecycle methods</description>

**Controller:**
```javascript
// app/javascript/controllers/hello_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Called when controller is connected to DOM
  connect() {
    console.log("Hello, Stimulus!", this.element)
  }

  // Called when controller is disconnected from DOM
  disconnect() {
    console.log("Goodbye!")
  }

  // Called when any target is added to DOM
  targetConnected(target, name) {
    console.log(`${name} target connected`)
  }
}
```

**HTML:**
```erb
<div data-controller="hello">
  This div is managed by the hello controller
</div>
```
</pattern>

<pattern name="targets">
<description>Finding and referencing elements within controller scope</description>

```javascript
// app/javascript/controllers/feedback_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "charCount"]

  updateCharCount() {
    const count = this.contentTarget.value.length
    this.charCountTarget.textContent = `${count} / 1000`

    // Check target existence: this.hasCharCountTarget
    // Multiple targets: this.contentTargets.forEach(...)
  }
}
```

```erb
<div data-controller="feedback">
  <textarea data-feedback-target="content"
            data-action="input->feedback#updateCharCount"></textarea>
  <div data-feedback-target="charCount">0 / 1000</div>
</div>
```
</pattern>

<pattern name="actions">
<description>Connecting DOM events to controller methods</description>

```javascript
// app/javascript/controllers/toggle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  toggle(event) {
    this.contentTarget.classList.toggle("hidden")
    event.preventDefault()
  }
}
```

```erb
<div data-controller="toggle">
  <button data-action="toggle#toggle">Toggle</button>
  <button data-action="mouseenter->toggle#show">Hover</button>
  <input data-action="focus->toggle#show blur->toggle#hide">
  <div data-toggle-target="content" class="hidden">Content</div>
</div>
```

**Syntax:** `event->controller#method:modifier` (modifiers: capture, once, passive)
</pattern>

<pattern name="values">
<description>Typed data attributes for controller configuration</description>

```javascript
// app/javascript/controllers/countdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    seconds: { type: Number, default: 60 },
    autostart: Boolean
  }

  connect() {
    if (this.autostartValue) this.start()
  }

  start() {
    this.timer = setInterval(() => {
      this.secondsValue--
      if (this.secondsValue === 0) this.stop()
    }, 1000)
  }

  // Called automatically when value changes
  secondsValueChanged() {
    this.element.textContent = this.secondsValue
  }

  disconnect() {
    clearInterval(this.timer)
  }
}
```

```erb
<div data-controller="countdown"
     data-countdown-seconds-value="120"
     data-countdown-autostart-value="true">60</div>
```

**Types:** Array, Boolean, Number, Object, String
</pattern>

<pattern name="outlets">
<description>Reference and communicate with other controllers</description>

```javascript
// app/javascript/controllers/search_controller.js
export default class extends Controller {
  static outlets = ["results"]

  search(event) {
    fetch(`/search?q=${event.target.value}`)
      .then(r => r.text())
      .then(html => this.resultsOutlet.update(html))
  }
}

// results_controller.js
export default class extends Controller {
  update(html) { this.element.innerHTML = html }
}
```

```erb
<div data-controller="search"
     data-search-results-outlet="#results">
  <input data-action="input->search#search">
</div>
<div id="results" data-controller="results"></div>
```
</pattern>

<pattern name="css-classes">
<description>Managing CSS classes with typed class attributes</description>

```javascript
// app/javascript/controllers/accordion_controller.js
export default class extends Controller {
  static classes = ["open", "closed"]
  static targets = ["content"]

  toggle() {
    this.contentTarget.classList.toggle(this.openClass)
    this.contentTarget.classList.toggle(this.closedClass)
  }
}
```

```erb
<div data-controller="accordion"
     data-accordion-open-class="block"
     data-accordion-closed-class="hidden">
  <button data-action="accordion#toggle">Toggle</button>
  <div data-accordion-target="content" class="hidden">Content</div>
</div>
```
</pattern>

<antipatterns>
<antipattern>
<description>Not cleaning up in disconnect()</description>
<bad-example>
```javascript
// ❌ BAD - Memory leak
connect() {
  this.timer = setInterval(() => this.update(), 1000)
}
```
</bad-example>
<good-example>
```javascript
// ✅ GOOD
disconnect() {
  clearInterval(this.timer)
}
```
</good-example>
</antipattern>

<antipattern>
<description>Direct DOM access instead of targets</description>
<bad-example>
```javascript
// ❌ BAD
toggle() {
  document.getElementById("content").classList.toggle("hidden")
}
```
</bad-example>
<good-example>
```javascript
// ✅ GOOD
static targets = ["content"]
toggle() {
  this.contentTarget.classList.toggle("hidden")
}
```
</good-example>
</antipattern>

<antipattern>
<description>Not preventing default on form submissions</description>
<bad-example>
```javascript
// ❌ BAD - Page reloads
submit() {
  fetch("/api/endpoint", { method: "POST" })
}
```
</bad-example>
<good-example>
```javascript
// ✅ GOOD
submit(event) {
  event.preventDefault()
  fetch("/api/endpoint", { method: "POST" })
}
```
</good-example>
</antipattern>
</antipatterns>

<testing>
```javascript
// test/javascript/controllers/hello_controller.test.js
import { Application } from "@hotwired/stimulus"
import HelloController from "controllers/hello_controller"

describe("HelloController", () => {
  beforeEach(() => {
    document.body.innerHTML = '<div data-controller="hello"></div>'
    const app = Application.start()
    app.register("hello", HelloController)
  })

  it("connects to DOM", () => {
    expect(document.querySelector('[data-controller="hello"]')).toBeDefined()
  })
})
```

```ruby
# test/system/stimulus_test.rb
test "countdown works" do
  visit root_path
  within "[data-controller='countdown']" do
    click_button "Start"
    sleep 2
    assert_text "58"
  end
end
```
</testing>

<related-skills>
- hotwire-turbo - Stimulus works seamlessly with Turbo
- viewcomponent-basics - Add Stimulus to ViewComponents
</related-skills>

<resources>
- [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
- [Stimulus Reference](https://stimulus.hotwired.dev/reference/controllers)
- [Rails Guides - Stimulus](https://guides.rubyonrails.org/working_with_javascript_in_rails.html#stimulus)
</resources>
