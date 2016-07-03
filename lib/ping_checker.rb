class PingChecker
  def ping?(push)
    push['zen'].nil? == false
  end
end
