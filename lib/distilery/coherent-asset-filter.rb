require "#{$script_dir}/filters/file-reference-filter"

$include_regex= /NIB\.asset\(['"]([^)]+)['"]\)/
$include_regex_old= /INC\(['"]([^)]+)['"]\)/

class CoherentAssetFilter < FileReferenceFilter
  
  def handles_file(file)
    return ["js"].include?(file.content_type)
  end
  
  def preprocess_content(file, content)
    content= content.split("\n")
    
    line_num=0
    
    content.each { |line|
      
      line_num+=1
      
      line.gsub!($include_regex) { |match|

        import_file= File.expand_path(File.join(file.parent_folder, $1))

        if (!File.exists?(import_file))
          file.warning "Missing asset: #{$1}", line_num
          "NIB.asset('#{$1}')"
        else
          asset= SourceFile.from_path(import_file)
          file.add_asset(asset);
          if (file.can_embed_as_content(asset))
            "NIB.asset('#{file_reference(asset)}','#{content_reference(asset)}')"
          else
            "NIB.asset('#{file_reference(asset)}')"
          end
        end
        
      }

      line.gsub!($include_regex_old) { |match|

        import_file= File.expand_path(File.join(file.parent_folder, $1))

        if (!File.exists?(import_file))
          file.warning "Missing import file: #{$1}", line_num
          "INC('#{$1}')"
        else
          asset= SourceFile.from_path(import_file)
          file.add_asset(asset);
          if (file.can_embed_as_content(asset))
            "INC('#{file_reference(asset)}','#{content_reference(asset)}')"
          else
            "INC('#{file_reference(asset)}')"
          end
        end
        
      }
      
    }
    
    content.join("\n")
  end

end

