module Spree::DependenciesExtension
  def self.included(base) #:nodoc:
    base.class_eval { alias_method_chain :require_or_load, :extensions_additions }
  end

  def require_or_load_with_extensions_additions(file_name, const_path=nil)
    file_loaded = false

    # If the file is of a know type.
    if file_type != 'unknown'
      # First load code from Spree.
      spree_file_name = File.join(SPREE_ROOT, 'app', "#{file_type}s", base_name)
      RAILS_DEFAULT_LOGGER.info "Checking Spree '#{SPREE_ROOT}' for '#{base_name}'"
      if File.file?("#{spree_file_name}.rb")
        RAILS_DEFAULT_LOGGER.info "==> Loading from Spree '#{base_name}'"
        file_loaded = true if require_or_load_without_extensions_additions(spree_file_name, const_path)
      else
        RAILS_DEFAULT_LOGGER.info "==> Not found in Spree '#{base_name}'"
      end

      # Then load code from extensions in the order they were loaded.
      paths_to_extensions = Spree::ExtensionLoader.instance.load_extension_roots
      paths_to_extensions.each do |extension_path|
        extension_file_name = File.expand_path(File.join(extension_path, 'app', "#{file_type}s", base_name))
        RAILS_DEFAULT_LOGGER.info "Checking extension '#{extension_path}' for '#{base_name}'"
        if File.file?("#{extension_file_name}.rb")
          RAILS_DEFAULT_LOGGER.info "==> Loading from extension '#{extension_path}'"
          file_loaded = true if require_or_load_without_extensions_additions(extension_file_name, const_path)
        end
      end

    end

    # If the file was not found or not handled (and so, not loaded) in any other place, just load it alone.
    file_loaded || require_or_load_without_extensions_additions(file_name, const_path)
  end  
end

module ActiveSupport::Dependencies #:nodoc:
  include Spree::DependenciesExtension
end
