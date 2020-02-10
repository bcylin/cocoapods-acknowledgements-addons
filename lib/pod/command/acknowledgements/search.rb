module Pod
  class Command
    class Acknowledgements < Command
      class Search < Acknowledgements

        self.arguments = [
          CLAide::Argument.new("PATHS", true)
        ]

        def self.options
          []
        end

        def initialize(argv)
          @arguments = argv.arguments!
          @paths = @arguments.map(&Pathname::method(:new)).map(&:expand_path)
          super
        end

        def validate!
          super
          help! "Path(s) to look for acknowledgements are required" if @paths.empty?
        end

        def run
          puts @paths
        end

      end
    end
  end
end
