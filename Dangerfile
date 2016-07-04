has_app_changes = !git.modified_files.grep(/lib/).empty?
has_test_changes = !git.modified_files.grep(/spec/).empty?

# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
declared_trivial = pr_title.include? '#trivial'

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn('PR is classed as Work in Progress') if pr_title.include? '[WIP]'

# Warn when there is a big PR
warn('Big PR') if lines_of_code > 500

# Add a CHANGELOG entry for app changes
if !modified_files.include?('CHANGELOG.md') && has_app_changes
  fail('Please include a CHANGELOG entry.')
end

# Warn about un-updated tests
if has_app_changes && !has_test_changes
  warn 'Tests were not updated'
end

if github.pr_body.length < 5
  fail 'Please provide a summary in the Pull Request description'
end

# TODO: This could be a danger plugin
files_to_lint = (modified_files + added_files).select { |f| f.end_with? 'rb' }
rubocop_results = files_to_lint.map { |f| JSON.parse(`bundle exec rubocop -f json #{f}`)['files'] }.flatten
offending_files = rubocop_results.select { |f| f['offenses'].count > 0 }

unless offending_files.empty?
  message = '### Rubocop violations'
  message << 'File | Line | Reason |\n'
  message << '| --- | ----- | ----- |\n'  

  offending_files.each do |f|
    f['offenses'].each do |o|
      message << "#{f['path']} | #{o['location']['line']} | #{o['message']} \n"
    end
  end

  markdown message
end
