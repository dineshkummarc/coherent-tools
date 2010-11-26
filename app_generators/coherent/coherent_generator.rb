require "#{File.dirname(__FILE__)}/../../lib/coherent"

class CoherentGenerator < CoherentBaseGenerator

  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])

  COHERENT_URL = ""
  COHERENT_FOLDER = "ext/coherent"
  
  default_options :author => nil,
                  :nib_name => 'Main'
  

  attr_reader :name, :nib_name

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @destination_root = File.expand_path(args.shift)
    @name = base_name

    extract_options
  end

  def manifest
    record do |m|
      # Ensure appropriate folder(s) exists
      m.directory ''
      BASEDIRS.each { |path| m.directory path }

      copy_template_folder m
      # m.dependency "nib", [nib_name], :destination=>destination_root
    end
  end

  protected
    def banner
      <<-EOS
Creates a ...

USAGE: #{spec.name} name
EOS
    end

    def add_options!(opts)
      opts.separator ''
      opts.separator 'Options:'
      # For each option below, place the default
      # at the top of the file next to "default_options"
      # opts.on("-a", "--author=\"Your Name\"", String,
      #         "Some comment about this option",
      #         "Default: none") { |o| options[:author] = o }
      opts.on("-nib", "--nib=\"Name of the Primary NIB\"", String,
              "The name used for the primary NIB for the app.",
              "Default: main") { |o|
        options[:nib_name] = o
      }
      opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end

    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
      @nib_name= options[:nib_name]
    end

    # Installation skeleton.  Intermediate directories are automatically
    # created so don't sweat their absence here.
    BASEDIRS = %w(
      src
      test
    )
end