/**
 * Fetch related articles and insert them into the DOM.
 */
document.addEventListener("DOMContentLoaded", async () => {
  try {
    const relatedArticles = await fetchRelatedArticles()
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
 * @returns {Promise<Array<{path: string, title: string, distance: float}>>}
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
    h2.innerText = "Related articles"

    const div = document.createElement("pre")
    div.innerText = JSON.stringify(relatedArticles, null, 2)
    el.appendChild(h2)
    el.appendChild(div)
  }
}
