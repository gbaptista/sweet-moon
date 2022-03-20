module Logic
  IO = {
    extension: ->(path) { File.extname(path) },
    file_name: ->(path) { File.basename(path) }
  }
end
