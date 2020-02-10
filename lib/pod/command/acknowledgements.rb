require "pod/command/acknowledgements/search"

module Pod
  class Command
    class Acknowledgements < Command
      self.abstract_command = true
      self.summary = "Find and add extra acknowledgements"
    end
  end
end
