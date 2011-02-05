require "#{File.dirname(__FILE__)}/../../lib/coherent"
require "yaml"

class ClassGenerator < CoherentBaseGenerator

  default_options :author => nil

  attr_reader :name, :full_name, :namespace

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    full_name= args.shift
    parts= full_name.split(".")
    
    
    @name= parts[-1]
    @full_name= full_name
    @namespace= parts[0..-2].join(".")
    
    if @namespace.empty?
      @target_folder = "src/js"
      project = YAML::load_file(PROJECT_FILE)
      if project["export"].is_a?(String)
        @namespace = project["export"]
        @full_name= [@namespace, @name].join(".")
      end
    else
      @target_folder = "src/js/#{namespace.gsub(".", "/")}"
    end
    
    extract_options
  end

  def manifest
    record do |m|

      copy_template_folder m, @target_folder
      
    end
  end

  protected
    def banner
      <<-EOS
Creates a ...

USAGE: #{$0} #{spec.name} name
EOS
    end

    def add_options!(opts)
      # opts.separator ''
      # opts.separator 'Options:'
      # For each option below, place the default
      # at the top of the file next to "default_options"
      # opts.on("-a", "--author=\"Your Name\"", String,
      #         "Some comment about this option",
      #         "Default: none") { |o| options[:author] = o }
      # opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end

    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
    end
end