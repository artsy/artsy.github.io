# Installs a prose checker if needed
system "pip install --user proselint" if `which proselint`.strip.empty?

# Look through all changed Markdown files
markdown_files = (modified_files + added_files).select { |line| line.end_with?(".markdown") || line.end_with?(".md")  }

require 'json'
result_jsons = Hash[markdown_files.uniq.collect { |v| [v, JSON.parse(`proselint #{v} --json`.strip) ] }]
proses = result_jsons.select { |path, prose| prose['data']['errors'].count }
current_branch = env.request_source.pr_json["head"]["ref"]

# We got some error reports back from proselint
if proses.count > 0
  message = "### Proselint found issues\n\n"
  message << "_note_: This is experimental, it won't fail the build, or affect other PRs. It may help though.\n\n"

  proses.each do |path, prose|
    github_loc = "/artsy/artsy.github.io/tree/#{current_branch}/#{path}"
    presentable_path = /_posts\/\d*-\d*-\d*-(.*)/.match(path)[1]
    message << "File | Message | Severity |\n"
    message << "| --- | ----- | ----- |\n"

    prose["data"]["errors"].each do |error|
      message << "[#{presentable_path} - #{error['line']}](#{github_loc}) | #{error['message']} | #{error['severity']}\n"
    end
  end

  markdown message
end
