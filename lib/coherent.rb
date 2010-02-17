require "active_support"

class CoherentBaseGenerator < RubiGen::Base
  
  def copy_template_folder(m, path=nil)
    path = path ? "#{path}/" : ""
    prefix_regex= Regexp.new("^#{Regexp.escape(source_root)}/(.*)$")
    all_files= Dir.glob("#{source_root}/**/*").select { |filepath| File.file?(filepath) }

    all_files.map! { |filepath| prefix_regex.match(filepath)[1] }

    b= binding
    
    all_folders= all_files.map { |filepath|
      File.dirname(filepath).gsub(/@(\w+)@/) { |match|
        begin
          eval($1, b)
        rescue
          "@#{$1}@"
        end
      }
    }
    all_folders.uniq.each { |folder| m.directory "#{path}#{folder}" }

    all_files.each { |filepath|
      output_path= filepath.gsub(/\.erb$/, '').gsub(/@(\w+)@/) { |match|
        begin
          eval($1, b)
        rescue
          "@#{$1}@"
        end
      }
      output_path= "#{path}#{output_path}"
      if (filepath[/\.erb$/])
        m.template filepath, output_path
      else
        m.file filepath, output_path
      end
    }
  end

end
