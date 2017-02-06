# Look for prose issues
prose.lint_files

# Use the VS Code Spell-checker word ignore list
require 'json'
vscode_spellings = JSON.parse File.read(".vscode/spellchecker.json")

# Look for spelling issues
prose.ignored_words = vscode_spellings["ignoreWordsList"]
prose.check_spelling
