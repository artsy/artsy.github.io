---
name: creating-articles
description: Creates new blog posts for the Artsy Engineering blog. Use when the user wants to write, create, or start a new blog post or article.
---

# Creating Articles

For full documentation, see [docs/authoring_articles.md](../../../docs/authoring_articles.md).

## Workflow

### Step 1: Gather Information

Use AskUserQuestion to ask the user:

1. **Template selection** - Ask which template they want to use:
   - `regular-post` - Short, straightforward posts (recommended for most posts)
   - `long-post` - Detailed posts with introduction, body, and conclusion
   - `epic-post` - Narrative-style posts following the monomyth structure

2. **Author name** - Ask for their name, then check if they exist in `_config.yml` under the `authors:` key.

### Step 2: Validate Author

Read `_config.yml` and search for the author under the `authors:` section.

**If author exists**: Use their author key (e.g., `orta`, `db`, `joey`).

**If author does not exist**: Inform the user they need to add themselves to `_config.yml` first:

```yaml
authors:
  authorkey:
    name: Full Name
    github: githubUsername
    twitter: twitterHandle  # optional
    site: https://example.com  # optional
```

### Step 3: Create the Post

1. Generate filename: `YYYY-MM-DD-post-title.markdown` (use today's date)
2. Copy the selected template from `Post-Templates/` to `_posts/`
3. Update the front matter:
   - Set `title`
   - Set `date` to today
   - Set `author` to the author key
   - Set `categories` (ask user if not provided)

## Templates Reference

| Template | File | Use Case |
|----------|------|----------|
| Regular | `Post-Templates/YYYY-MM-DD-regular-post.markdown` | Quick posts about a problem and solution |
| Long | `Post-Templates/YYYY-MM-DD-long-post.markdown` | Detailed technical deep-dives |
| Epic | `Post-Templates/YYYY-MM-DD-epic-post.markdown` | Narrative journey-style posts |
