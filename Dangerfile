# Look for prose issues
prose.lint_files

# Use the VS Code Spell-checker word ignore list
require 'json'
vscode_spellings = JSON.parse File.read('.vscode/settings.json')

# Look for spelling issues
prose.ignored_words = vscode_spellings['spellchecker.ignoreWordsList']
prose.check_spelling

avoid_exact_words = [
  { word: 'Github', reason: "Please use GitHub, capital 'H'" },
  { word: 'Cocoapods', reason: "Please use CocoaPods, capital 'P'" },
  { word: 'Javascript', reason: "Please use JavaScript, capital 'S'" },
  { word: 'Typescript', reason: "Please use TypeScript, capital 'S'" },
  { word: 'Fastlane', reason: "Please use fastlane, lowercase 'f'" },
  { word: 'localhost:4000', reason: 'You may have left an internal link in the markdown' },
  { word: '[]: ???', reason: 'You\'ve missed a link' }
  { word: '[TODO]', reason: 'You may have missed a TODO here' }
]

active_files = (git.modified_files + git.added_files)
markdowns = active_files.select { |file| file.start_with? '_posts/' }

# This could do with some code golfing sometime
markdowns.each do |file|
  lines = File.read(file).lines
  lines.each do |l|
    avoid_exact_words.each do |avoid|
      warn(avoid[:reason], file: file, line: l) if l.include? avoid[:word]
    end
  end
end
