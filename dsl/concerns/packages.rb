require_relative '../errors'

module DSL
  module Concerns
    module Packages
      def add_package_path(path, target = 'package.path')
        _ensure_min_version!(target, '5.1', '2')

        paths = path
        paths = [path] unless paths.is_a? Array

        self.eval("#{target} = \"#{paths.join(';')};\" .. #{target}")
      end

      def package_path(target = 'package.path')
        _ensure_min_version!(target, '5.1', '2')
        self.eval("return #{target}").split(';')
      end

      def add_package_cpath(path)
        add_package_path(path, 'package.cpath')
      end

      def package_cpath
        package_path('package.cpath')
      end

      def require_module(module_name)
        require_module_as(module_name, module_name)
      end

      def require_module_as(module_name, variable)
        self.eval("#{variable} = require \"#{module_name}\"")
      end
    end
  end
end
