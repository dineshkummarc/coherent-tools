module Coherent
  module Commands
    
    
    class Update
      def initialize(base_command)
        @base_command = base_command
      end
   
      def options
        OptionParser.new do |o|
          o.set_summary_indent('  ')
          o.banner =    "Usage: #{@base_command.script_name} update [name [name]...]"
          o.on(         "-r REVISION", "--revision REVISION",
                        "Checks out the given revision from subversion.",
                        "Ignored if subversion is not used.") { |v| @revision = v }
          o.define_head "Update plugins."
        end
      end
   
      def parse!(args)
        options.parse!(args)
        root = @base_command.environment.root
        cd root
        args = Dir["vendor/plugins/*"].map do |f|
          File.directory?("#{f}/.svn") ? File.basename(f) : nil
        end.compact if args.empty?
        cd "vendor/plugins"
        args.each do |name|
          if File.directory?(name)
            puts "Updating plugin: #{name}"
            system("svn #{$verbose ? '' : '-q'} up \"#{name}\" #{@revision ? "-r #{@revision}" : ''}")
          else
            puts "Plugin doesn't exist: #{name}"
          end
        end
      end
    end


  end
end
