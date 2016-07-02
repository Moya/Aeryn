class MergeChecker
  def is_merged?(push)
    push['action'] == 'closed' && push['pull_request']['merged'] == true
  end
end