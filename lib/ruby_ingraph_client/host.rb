# encoding: utf-8

module RubyIngraphClient
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

    def self.find(db, name)
      new(db.fetch('select * from host where name = ?', name).first)
    end

    attr_reader :id, :name

    def initialize(row)
      @id = row[:id]
      @name = row[:name]
    end

    def ==(other)
      @id == other.id && @name == other.name
    end
  end
end
