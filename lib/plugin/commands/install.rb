module Coherent
  module Commands
    
    
    class Install
      def initialize(base_command)
        @base_command = base_command
        @method = :http
        @options = { :quiet => false, :revision => nil, :force => false }
      end
    
      def options
        OptionParser.new do |o|
          o.set_summary_indent('  ')
          o.banner =    "Usage: #{@base_command.script_name} install PLUGIN [PLUGIN [PLUGIN] ...]"
          o.define_head "Install one or more plugins."
          o.separator   ""
          o.separator   "Options:"
          o.on(         "-x", "--externals", 
                        "Use svn:externals to grab the plugin.", 
                        "Enables plugin updates and plugin versioning.") { |v| @method = :externals }
          o.on(         "-o", "--checkout",
                        "Use svn checkout to grab the plugin.",
                        "Enables updating but does not add a svn:externals entry.") { |v| @method = :checkout }
          o.on(         "-e", "--export",
                        "Use svn export to grab the plugin.",
                        "Exports the plugin, allowing you to check it into your local repository. Does not enable updates, or add an svn:externals entry.") { |v| @method = :export }
          o.on(         "-q", "--quiet",
                        "Suppresses the output from installation.",
                        "Ignored if -v is passed (./script/plugin -v install ...)") { |v| @options[:quiet] = true }
          o.on(         "-r REVISION", "--revision REVISION",
                        "Checks out the given revision from subversion or git.",
                        "Ignored if subversion/git is not used.") { |v| @options[:revision] = v }
          o.on(         "-f", "--force",
                        "Reinstalls a plugin if it's already installed.") { |v| @options[:force] = true }
          o.separator   ""
          o.separator   "You can specify plugin names as given in 'plugin list' output or absolute URLs to "
          o.separator   "a plugin repository."
        end
      end
    
      def determine_install_method
        best = @base_command.environment.best_install_method
        @method = :http if best == :http and @method == :export
        case
        when (best == :http and @method != :http)
          msg = "Cannot install using subversion because `svn' cannot be found in your PATH"
        when (best == :export and (@method != :export and @method != :http))
          msg = "Cannot install using #{@method} because this project is not under subversion."
        when (best != :externals and @method == :externals)
          msg = "Cannot install using externals because vendor/plugins is not under subversion."
        end
        if msg
          puts msg
          exit 1
        end
        @method
      end
    
      def parse!(args)
        options.parse!(args)
        environment = @base_command.environment
        install_method = determine_install_method
        puts "Plugins will be installed using #{install_method}" if $verbose
        args.each do |name|
          Coherent::Plugin.find(name).install(install_method, @options)
        end
      rescue StandardError => e
        puts "Plugin not found: #{args.inspect}"
        puts e.inspect if $verbose
        exit 1
      end
    end

  end
end
