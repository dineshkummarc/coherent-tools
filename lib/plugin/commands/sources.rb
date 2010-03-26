module Coherent
  module Commands


    class Sources
      def initialize(base_command)
        @base_command = base_command
      end
    
      def options
        OptionParser.new do |o|
          o.set_summary_indent('  ')
          o.banner =    "Usage: #{@base_command.script_name} sources [OPTIONS] [PATTERN]"
          o.define_head "List configured plugin repositories."
          o.separator   ""        
          o.separator   "Options:"
          o.separator   ""
          o.on(         "-c", "--check", 
                        "Report status of repository.") { |sources| @sources = sources}
        end
      end
    
      def parse!(args)
        options.parse!(args)
        Repositories.each do |repo|
          puts repo.uri
        end
      end
    end


  end
end