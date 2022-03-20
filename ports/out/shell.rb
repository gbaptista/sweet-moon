module Port
  module Out
    Shell = {
      dispatch!: ->(message) {
        puts message
      }
    }
  end
end
