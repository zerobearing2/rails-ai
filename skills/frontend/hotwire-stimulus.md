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

**Controller:**
```javascript
// app/javascript/controllers/feedback_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "charCount", "submitButton"]

  connect() {
    this.updateCharCount()
  }

  updateCharCount() {
    const content = this.contentTarget.value
    const count = content.length
    const maxLength = 1000

    // Single target access
    this.charCountTarget.textContent = `${count} / ${maxLength}`

    // Conditional logic based on target existence
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = count > maxLength
    }
  }

  // Access all targets of same type
  highlightAll() {
    this.contentTargets.forEach(element => {
      element.classList.add("highlighted")
    })
  }
}
```

**HTML:**
```erb
<div data-controller="feedback">
  <textarea data-feedback-target="content"
            data-action="input->feedback#updateCharCount"></textarea>
  <div data-feedback-target="charCount">0 / 1000</div>
  <button data-feedback-target="submitButton">Submit</button>
</div>
```

**Target Methods:**
- `this.{name}Target` - Single target (throws if missing)
- `this.{name}Targets` - Array of all matching targets
- `this.has{Name}Target` - Check if target exists
</pattern>

<pattern name="actions">
<description>Connecting DOM events to controller methods</description>

**Controller:**
```javascript
// app/javascript/controllers/toggle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  // Default event is "click" for buttons/links
  toggle() {
    this.contentTarget.classList.toggle("hidden")
  }

  // Handle specific events
  show(event) {
    this.contentTarget.classList.remove("hidden")
    event.preventDefault()
  }

  hide(event) {
    this.contentTarget.classList.add("hidden")
    event.preventDefault()
  }
}
```

**HTML:**
```erb
<div data-controller="toggle">
  <%# Default click event %>
  <button data-action="toggle#toggle">Toggle</button>

  <%# Explicit event type %>
  <button data-action="mouseenter->toggle#show mouseleave->toggle#hide">
    Hover to show
  </button>

  <%# Multiple actions on same element %>
  <input type="text"
         data-action="focus->toggle#show blur->toggle#hide input->toggle#validate">

  <div data-toggle-target="content" class="hidden">
    Hidden content
  </div>
</div>
```

**Action Syntax:**
- `controller#method` - Default event (click for buttons)
- `event->controller#method` - Explicit event
- `event->controller#method:capture` - Capture phase
- `event->controller#method:once` - Run only once
- `event->controller#method:passive` - Passive event listener
</pattern>

<pattern name="values">
<description>Typed data attributes for controller configuration</description>

**Controller:**
```javascript
// app/javascript/controllers/countdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    seconds: { type: Number, default: 60 },
    autostart: { type: Boolean, default: false },
    message: String
  }

  static targets = ["display"]

  connect() {
    if (this.autostartValue) {
      this.start()
    }
  }

  start() {
    this.timer = setInterval(() => {
      this.secondsValue--
      this.updateDisplay()

      if (this.secondsValue === 0) {
        this.stop()
      }
    }, 1000)
  }

  stop() {
    clearInterval(this.timer)
  }

  updateDisplay() {
    this.displayTarget.textContent = this.secondsValue
  }

  // Called when value changes
  secondsValueChanged() {
    this.updateDisplay()
  }

  disconnect() {
    this.stop()
  }
}
```

**HTML:**
```erb
<div data-controller="countdown"
     data-countdown-seconds-value="120"
     data-countdown-autostart-value="true"
     data-countdown-message-value="Time's up!">
  <div data-countdown-target="display"></div>
  <button data-action="countdown#start">Start</button>
  <button data-action="countdown#stop">Stop</button>
</div>
```

**Value Types:**
- `Array`
- `Boolean`
- `Number`
- `Object`
- `String`
</pattern>

<pattern name="outlets">
<description>Reference and communicate with other controllers</description>

**Controllers:**
```javascript
// app/javascript/controllers/search_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static outlets = ["results"]

  search(event) {
    const query = event.target.value

    fetch(`/search?q=${query}`)
      .then(response => response.text())
      .then(html => {
        // Call method on connected outlet
        this.resultsOutlet.update(html)
      })
  }
}

// app/javascript/controllers/results_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  update(html) {
    this.element.innerHTML = html
  }
}
```

**HTML:**
```erb
<div data-controller="search"
     data-search-results-outlet="#search-results">
  <input type="text" data-action="input->search#search">
</div>

<div id="search-results" data-controller="results">
  <%# Results will appear here %>
</div>
```
</pattern>

<pattern name="css-classes">
<description>Managing CSS classes with typed class attributes</description>

**Controller:**
```javascript
// app/javascript/controllers/accordion_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static classes = ["open", "closed"]
  static targets = ["content"]

  toggle() {
    if (this.contentTarget.classList.contains(this.openClass)) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.contentTarget.classList.remove(this.closedClass)
    this.contentTarget.classList.add(this.openClass)
  }

  close() {
    this.contentTarget.classList.remove(this.openClass)
    this.contentTarget.classList.add(this.closedClass)
  }
}
```

**HTML:**
```erb
<div data-controller="accordion"
     data-accordion-open-class="block"
     data-accordion-closed-class="hidden">
  <button data-action="accordion#toggle">Toggle</button>
  <div data-accordion-target="content" class="hidden">
    Accordion content
  </div>
</div>
```
</pattern>

<antipatterns>
<antipattern>
<description>Not cleaning up in disconnect()</description>
<reason>Can cause memory leaks and unexpected behavior</reason>
<bad-example>
```javascript
// ❌ BAD - Timer not cleaned up
export default class extends Controller {
  connect() {
    this.timer = setInterval(() => {
      this.updateTime()
    }, 1000)
  }
}
```
</bad-example>
<good-example>
```javascript
// ✅ GOOD - Clean up timer
export default class extends Controller {
  connect() {
    this.timer = setInterval(() => {
      this.updateTime()
    }, 1000)
  }

  disconnect() {
    clearInterval(this.timer)
  }
}
```
</good-example>
</antipattern>

<antipattern>
<description>Accessing DOM elements directly instead of using targets</description>
<reason>Breaks encapsulation and makes code less reusable</reason>
<bad-example>
```javascript
// ❌ BAD - Direct DOM access
export default class extends Controller {
  toggle() {
    document.getElementById("content").classList.toggle("hidden")
  }
}
```
</bad-example>
<good-example>
```javascript
// ✅ GOOD - Use targets
export default class extends Controller {
  static targets = ["content"]

  toggle() {
    this.contentTarget.classList.toggle("hidden")
  }
}
```
</good-example>
</antipattern>

<antipattern>
<description>Not preventing default on form submissions</description>
<reason>Causes page reload instead of AJAX handling</reason>
<bad-example>
```javascript
// ❌ BAD - Form reloads page
export default class extends Controller {
  submit() {
    fetch("/api/endpoint", {
      method: "POST"
    })
  }
}
```
</bad-example>
<good-example>
```javascript
// ✅ GOOD - Prevent default
export default class extends Controller {
  submit(event) {
    event.preventDefault()

    fetch("/api/endpoint", {
      method: "POST"
    })
  }
}
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test Stimulus controllers with Jest or in system tests:

```javascript
// test/javascript/controllers/hello_controller.test.js
import { Application } from "@hotwired/stimulus"
import HelloController from "controllers/hello_controller"

describe("HelloController", () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <div data-controller="hello">
        <span data-hello-target="output"></span>
      </div>
    `

    const application = Application.start()
    application.register("hello", HelloController)
  })

  it("connects to the DOM", () => {
    const controller = application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="hello"]'),
      "hello"
    )

    expect(controller).toBeDefined()
  })
})
```

**System Tests:**
```ruby
# test/system/stimulus_test.rb
class StimulusTest < ApplicationSystemTestCase
  test "countdown controller works" do
    visit root_path

    within "[data-controller='countdown']" do
      assert_text "60"

      click_button "Start"

      sleep 2
      assert_text "58"
    end
  end
end
```
</testing>

<related-skills>
- hotwire-turbo - Stimulus works seamlessly with Turbo
- viewcomponent-basics - Add Stimulus to ViewComponents
- javascript-best-practices - JavaScript conventions
</related-skills>

<resources>
- [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
- [Stimulus Reference](https://stimulus.hotwired.dev/reference/controllers)
- [Rails Guides - Stimulus](https://guides.rubyonrails.org/working_with_javascript_in_rails.html#stimulus)
</resources>
