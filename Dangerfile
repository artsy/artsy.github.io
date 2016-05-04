# Installs a prose checker if needed
`pip install proselint` if `which proselint`.empty?

# Look through all changed Markdown files
markdown_files = (modified_files + added_files).select { |line| line.end_with?(".markdown") || line.end_with?(".md")  }

require 'JSON'
result_jsons = Hash[markdown_files.collect { |v| [v, JSON.parse(`proselint #{v} --json`.strip) ] }]
proses = result_jsons.select { |prose| prose['data']['errors'].count }

# We got some error reports back from proselint
if proses.count > 0
  message = "### Proselint: #{prose['status'].capitalize}\n\n"
  message = "_note_: This is experimental, it won't fail the build, or affect other PRs. It may help though.\n\n"

  proses.each do |path, prose|
    message << "File | Message | Severity |\n| --- | ----- | ----- |"
    current_branch = env.request_source.pr_json["head"]["ref"]
    github_loc = "/artsy/artsy.github.io/tree/#{current_branch}/#{path}"

    prose["data"]["errors"].each do |error|
      message << "[#{path}](#{github_loc}) | #{error['message']} | #{error['severity']} "
    end
    markdown message
  end
end
