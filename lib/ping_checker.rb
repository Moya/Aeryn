class PingChecker
  def is_ping?(push)
    push['zen'].nil? == false
  end
end