
# TODO: turn into plugin

# Determine if proselint is currently installed in the system paths.
# @return  [Bool]
#
def mdspell_installed?
  `which mdspell`.strip.empty? == false
end

def check_spelling(files, ignored_words = []) 
  # Installs a prose checker if needed
    system "npm i markdown-spellcheck -g" unless mdspell_installed?

    # Check that this is in the user's PATH after installing
    unless mdspell_installed?
      fail "mdspell is not in the user's PATH, or it failed to install"
      return
    end

    markdown_files = files ? Dir.glob(files) : (modified_files + added_files)
    markdown_files.select! do |line| (line.end_with?(".markdown") || line.end_with?(".md")) end
    output = `mdspell #{ markdown_files.uniq.join" " } -r`
    markdown output if output.include? "spelling errors found"
end


# Look through all changed Markdown files
markdown_files = (modified_files + added_files).select do |line|
  line.start_with?("_posts") && (line.end_with?(".markdown") || line.end_with?(".md"))
end

proselint.lint_files markdown_files
check_spelling markdown_files