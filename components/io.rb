require 'find'

module Component
  IO = {
    read!: ->(path) { File.read(path) },
    write!: ->(path, content) { File.write(path, content) },
    find_by_pattern!: ->(pattern) { Dir.glob(pattern) },
    find_recursively!: ->(initial_path) { Find.find(initial_path) },
    reject_non_existent!: ->(paths) { paths.select { |path| File.file?(path) } }
  }
end
