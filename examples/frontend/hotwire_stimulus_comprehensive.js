// Hotwire Stimulus Comprehensive Patterns
// Reference: Stimulus Handbook - https://stimulus.hotwired.dev
// Category: FRONTEND - HOTWIRE/STIMULUS

/*
============================================================================
What is Stimulus?
============================================================================

Stimulus is a modest JavaScript framework for the HTML you already have.
It connects JavaScript objects (controllers) to HTML elements using data attributes.

Key Concepts:
- Controllers: JavaScript classes that bring HTML to life
- Actions: Connect DOM events to controller methods
- Targets: Find important elements within the controller's scope
- Values: Read/write typed data attributes
- Outlets: Reference other controllers
- CSS Classes: Manage CSS class names

Benefits:
✅ Progressive enhancement
✅ Small bundle size (~30KB)
✅ Works with server-rendered HTML
✅ No build step required
✅ Easy to learn and debug
*/

/*
============================================================================
✅ BASIC CONTROLLER PATTERN
============================================================================
*/

// app/javascript/controllers/hello_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Hello, Stimulus!", this.element)
  }
}

// HTML usage:
// <div data-controller="hello">
//   This div is managed by the hello controller
// </div>

/*
============================================================================
✅ TARGETS - Find Important Elements
============================================================================
*/

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

    this.charCountTarget.textContent = `${count} / ${maxLength}`

    // Disable submit if too long
    if (count > maxLength) {
      this.submitButtonTarget.disabled = true
    } else {
      this.submitButtonTarget.disabled = false
    }
  }

  // Check if optional target exists
  hasSubmitButtonTarget() {
    return this.hasSubmitButtonTarget
  }

  // Access all targets of same type
  highlightAll() {
    this.contentTargets.forEach(element => {
      element.classList.add("highlighted")
    })
  }
}

// HTML usage:
// <div data-controller="feedback">
//   <textarea data-feedback-target="content"
//             data-action="input->feedback#updateCharCount"></textarea>
//   <div data-feedback-target="charCount">0 / 1000</div>
//   <button data-feedback-target="submitButton">Submit</button>
// </div>

/*
============================================================================
✅ ACTIONS - Connect Events to Methods
============================================================================
*/

// app/javascript/controllers/toggle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  // Default event is "click" for buttons/links
  toggle() {
    this.contentTarget.classList.toggle("hidden")
  }

  // Explicit event type
  // data-action="mouseenter->toggle#show"
  show() {
    this.contentTarget.classList.remove("hidden")
  }

  // data-action="mouseleave->toggle#hide"
  hide() {
    this.contentTarget.classList.add("hidden")
  }

  // Multiple actions on same element
  // data-action="focus->toggle#show blur->toggle#hide"

  // Action with modifiers
  // data-action="keydown.enter->toggle#submit"
  submit(event) {
    event.preventDefault()
    // Submit logic
  }

  // Global actions (document/window)
  // data-action="keydown@window->toggle#handleKeydown"
  handleKeydown(event) {
    if (event.key === "Escape") {
      this.hide()
    }
  }
}

// HTML usage:
// <div data-controller="toggle">
//   <button data-action="toggle#toggle">Toggle</button>
//   <div data-toggle-target="content">Hidden content</div>
// </div>

/*
============================================================================
✅ VALUES - Typed Data Attributes
============================================================================
*/

// app/javascript/controllers/clipboard_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    text: String,
    successMessage: { type: String, default: "Copied!" },
    timeout: { type: Number, default: 2000 }
  }

  connect() {
    console.log("Text to copy:", this.textValue)
    console.log("Success message:", this.successMessageValue)
    console.log("Timeout:", this.timeoutValue)
  }

  copy() {
    navigator.clipboard.writeText(this.textValue).then(() => {
      this.showSuccess()
    })
  }

  showSuccess() {
    const originalText = this.element.textContent
    this.element.textContent = this.successMessageValue

    setTimeout(() => {
      this.element.textContent = originalText
    }, this.timeoutValue)
  }

  // Value change callbacks
  textValueChanged(value, previousValue) {
    console.log(`Text changed from ${previousValue} to ${value}`)
  }
}

// HTML usage:
// <button data-controller="clipboard"
//         data-clipboard-text-value="Hello, World!"
//         data-clipboard-success-message-value="Done!"
//         data-clipboard-timeout-value="3000"
//         data-action="clipboard#copy">
//   Copy to Clipboard
// </button>

/*
============================================================================
✅ CSS CLASSES - Manage Class Names
============================================================================
*/

// app/javascript/controllers/dropdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static classes = ["open", "closed"]
  static targets = ["menu"]

  toggle() {
    if (this.menuTarget.classList.contains(this.openClass)) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.menuTarget.classList.remove(this.closedClass)
    this.menuTarget.classList.add(this.openClass)
  }

  close() {
    this.menuTarget.classList.remove(this.openClass)
    this.menuTarget.classList.add(this.closedClass)
  }
}

// HTML usage (with Tailwind):
// <div data-controller="dropdown"
//      data-dropdown-open-class="block"
//      data-dropdown-closed-class="hidden">
//   <button data-action="dropdown#toggle">Menu</button>
//   <div data-dropdown-target="menu" class="hidden">
//     <a href="#">Item 1</a>
//     <a href="#">Item 2</a>
//   </div>
// </div>

/*
============================================================================
✅ OUTLETS - Reference Other Controllers
============================================================================
*/

// app/javascript/controllers/search_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static outlets = ["results"]

  search(event) {
    const query = event.target.value

    // Access results controller
    this.resultsOutlet.display(query)
  }

  // Check if outlet is connected
  resultsOutletConnected(outlet, element) {
    console.log("Results outlet connected", outlet, element)
  }

  resultsOutletDisconnected(outlet, element) {
    console.log("Results outlet disconnected", outlet, element)
  }
}

// app/javascript/controllers/results_controller.js
export default class extends Controller {
  display(query) {
    // Fetch and display results
    this.element.innerHTML = `Searching for: ${query}`
  }
}

// HTML usage:
// <div data-controller="search"
//      data-search-results-outlet="#search-results">
//   <input type="text" data-action="input->search#search">
// </div>
//
// <div id="search-results" data-controller="results"></div>

/*
============================================================================
✅ LIFECYCLE CALLBACKS
============================================================================
*/

// app/javascript/controllers/lifecycle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Called when controller is connected to DOM
  connect() {
    console.log("Controller connected")
    this.setupEventListeners()
  }

  // Called when controller is disconnected from DOM
  disconnect() {
    console.log("Controller disconnected")
    this.teardownEventListeners()
  }

  // Called when target is added
  contentTargetConnected(target) {
    console.log("Content target connected", target)
  }

  // Called when target is removed
  contentTargetDisconnected(target) {
    console.log("Content target disconnected", target)
  }

  // Called when value changes
  urlValueChanged(value, previousValue) {
    console.log(`URL changed from ${previousValue} to ${value}`)
    this.fetchData(value)
  }

  setupEventListeners() {
    this.handleResize = this.handleResize.bind(this)
    window.addEventListener("resize", this.handleResize)
  }

  teardownEventListeners() {
    window.removeEventListener("resize", this.handleResize)
  }

  handleResize() {
    console.log("Window resized")
  }
}

/*
============================================================================
✅ REAL-WORLD EXAMPLES
============================================================================
*/

// 1. Form Validation Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field", "error"]
  static values = { minLength: Number }

  validate() {
    const value = this.fieldTarget.value

    if (value.length < this.minLengthValue) {
      this.showError(`Minimum ${this.minLengthValue} characters required`)
    } else {
      this.clearError()
    }
  }

  showError(message) {
    this.errorTarget.textContent = message
    this.errorTarget.classList.remove("hidden")
    this.fieldTarget.classList.add("border-red-500")
  }

  clearError() {
    this.errorTarget.classList.add("hidden")
    this.fieldTarget.classList.remove("border-red-500")
  }
}

// 2. Modal Controller
export default class extends Controller {
  static targets = ["dialog", "backdrop"]

  open() {
    this.element.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
    this.dialogTarget.focus()
  }

  close() {
    this.element.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  closeWithBackdrop(event) {
    if (event.target === this.backdropTarget) {
      this.close()
    }
  }

  closeWithKeyboard(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}

// 3. Auto-save Controller
export default class extends Controller {
  static targets = ["field", "status"]
  static values = { url: String, delay: { type: Number, default: 1000 } }

  connect() {
    this.timeout = null
  }

  save() {
    clearTimeout(this.timeout)

    this.statusTarget.textContent = "Saving..."

    this.timeout = setTimeout(() => {
      this.submitForm()
    }, this.delayValue)
  }

  async submitForm() {
    const formData = new FormData()
    formData.append("content", this.fieldTarget.value)

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        body: formData,
        headers: {
          "X-CSRF-Token": this.csrfToken
        }
      })

      if (response.ok) {
        this.statusTarget.textContent = "Saved"
        setTimeout(() => {
          this.statusTarget.textContent = ""
        }, 2000)
      }
    } catch (error) {
      this.statusTarget.textContent = "Error saving"
    }
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]').content
  }
}

// 4. Infinite Scroll Controller
export default class extends Controller {
  static values = { url: String, page: { type: Number, default: 1 } }
  static targets = ["entries", "loader"]

  connect() {
    this.observer = new IntersectionObserver(
      entries => this.handleIntersect(entries),
      { threshold: 0.5 }
    )

    this.observer.observe(this.loaderTarget)
  }

  disconnect() {
    this.observer.disconnect()
  }

  async handleIntersect(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        this.loadMore()
      }
    })
  }

  async loadMore() {
    if (this.loading) return

    this.loading = true
    this.pageValue++

    try {
      const response = await fetch(`${this.urlValue}?page=${this.pageValue}`)
      const html = await response.text()

      this.entriesTarget.insertAdjacentHTML("beforeend", html)
    } catch (error) {
      console.error("Failed to load more", error)
    } finally {
      this.loading = false
    }
  }
}

/*
============================================================================
✅ TESTING STIMULUS
============================================================================
*/

// test/javascript/controllers/clipboard_controller_test.js
import { Application } from "@hotwired/stimulus"
import ClipboardController from "controllers/clipboard_controller"

describe("ClipboardController", () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <button data-controller="clipboard"
              data-clipboard-text-value="Test"
              data-action="clipboard#copy">Copy</button>
    `

    const application = Application.start()
    application.register("clipboard", ClipboardController)
  })

  test("copies text to clipboard", async () => {
    // Mock clipboard API
    Object.assign(navigator, {
      clipboard: {
        writeText: jest.fn(() => Promise.resolve())
      }
    })

    const button = document.querySelector("button")
    button.click()

    expect(navigator.clipboard.writeText).toHaveBeenCalledWith("Test")
  })
})

/*
============================================================================
RULE: Use Stimulus for progressive enhancement of server-rendered HTML
PREFER: Small, focused controllers with single responsibility
USE: Values for typed data passing to controllers
TEST: Write unit tests for complex controller logic
ORGANIZE: One controller per file, named with _controller.js suffix
============================================================================
*/
