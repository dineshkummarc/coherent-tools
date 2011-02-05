require "active_support"

class String
  def as_identifier
    word= self.to_s.gsub(/(?:^|\W)(.)/) { $1.upcase }
    # word[0..0].downcase + word[1..-1]
  end
  def starts_with?(prefix)
    prefix = prefix.to_s
    self[0, prefix.length] == prefix
  end
  def remove_indent
    str= sub(/^\n*/, "")
    match= str.match(/(^\s+)/)
    return str unless match
    str.gsub(/^#{match[1]}/, '').strip
  end
  def indent(str)
    self.gsub(/^/, str)
  end
end

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
