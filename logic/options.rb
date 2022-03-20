module Logic
  Options = {
    normalize: ->(original_options) {
      options = original_options.clone

      if options[:shared_object]
        options[:shared_objects] = [options[:shared_object]]
        options.delete(:shared_object)
      end

      options
    }
  }
end
