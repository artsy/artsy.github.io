// Adapted from https://github.com/github/g-emoji-element

var onWindows7 = /\bWindows NT 6.1\b/.test(navigator.userAgent)
var onWindows8 = /\bWindows NT 6.2\b/.test(navigator.userAgent)
var onWindows81 = /\bWindows NT 6.3\b/.test(navigator.userAgent)
var onLinux = /\bLinux\b/.test(navigator.userAgent)
var onFreeBSD = /\bFreeBSD\b/.test(navigator.userAgent)

function isEmojiSupported() {
  return !(onWindows7 || onWindows8 || onWindows81 || onLinux || onFreeBSD)
}

class GEmojiElement extends HTMLElement {
  get image() {
    // Check if fallback image already exists since this node may have been
    // cloned from another node
    if (this.firstElementChild instanceof HTMLImageElement) {
      return this.firstElementChild
    } else {
      return null
    }
  }

  connectedCallback() {
    if (this.image === null && !isEmojiSupported()) {
      this.textContent = ''
      const image = emojiImage(this)
      image.src = this.getAttribute('fallback-src') || ''
      this.appendChild(image)
    }
  }
}

// Generates an <img> child element for a <g-emoji> element.
//
// el - The <g-emoji> element.
//
// Returns an HTMLImageElement.
function emojiImage(el) {
  const image = document.createElement('img')
  image.className = 'emoji'
  image.alt = el.getAttribute('alias') || ''
  image.height = 20
  image.width = 20
  return image
}

if (!window.customElements.get('g-emoji')) {
  window.GEmojiElement = GEmojiElement
  window.customElements.define('g-emoji', GEmojiElement)
}
