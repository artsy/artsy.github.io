# Look through all changed Markdown files
markdown_files = (modified_files + added_files).select do |line|
  line.start_with?("_posts") && (line.end_with?(".markdown") || line.end_with?(".md"))
end

proselint.lint_files markdown_files
