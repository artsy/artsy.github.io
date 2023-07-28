const CERTAINTY_THRESHOLD = 0.92

/**
 * Fetch related articles and insert them into the DOM.
 */
document.addEventListener("DOMContentLoaded", async () => {
  try {
    const relatedArticles = await (await fetchRelatedArticles()).filter(a => a.certainty > CERTAINTY_THRESHOLD)
    if (relatedArticles.length) {
      insertIntoDom(relatedArticles)
    }
  } catch (e) {
    console.error("Could not add related articles: ", e)
  }
})

/**
 * Check the manifest for related articles and return them if they exist.
 *
 * @returns {Promise<Array<{path: string, title: string, certainty: float}>>}
 */
async function fetchRelatedArticles() {
  const response = await fetch("/related-articles.json")
  const relatedArticles = await response.json()

  const currentPath = document.location.pathname.replace(
    /\/blog\/(.*)\/\s*$/,
    "$1"
  )
  return relatedArticles[currentPath] || []
}

/**
 * Insert the related articles into the DOM.
 */
function insertIntoDom(relatedArticles) {
  const el = document.querySelector("aside.related-articles")
  if (el) {
    const h2 = document.createElement("h2")
    h2.innerText = "You might also like"
    el.appendChild(h2)

    ul = document.createElement("ul")
    el.appendChild(ul)

    relatedArticles.forEach((article) => {
      const li = document.createElement("li")
      const a = document.createElement("a")
      a.href = `/blog/${article.path}`
      a.innerText = article.title
      li.appendChild(a)
      ul.appendChild(li)
    })
    el.classList.add("loaded")
  }
}
