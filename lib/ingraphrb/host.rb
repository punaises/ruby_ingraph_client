# encoding: utf-8

module IngraphRB
  # Wrapper to find hosts
  class Host
    def self.sanitize_pattern(pattern)
      pattern.gsub('*', '%')
    end

    def self.matching(db, pattern)
      db.fetch('select * from host where name like ?',
               sanitize_pattern(pattern)).map do |row|
        new(row)
      end
    end

    def initialize(row)
      @id = row[:id]
      @name = row[:name]
    end
  end
end
