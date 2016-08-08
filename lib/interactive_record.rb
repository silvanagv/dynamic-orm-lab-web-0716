require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_name1 = table_info[1]["name"]
    column_names = []

    column_names = table_info.collect do |element|
        element["name"]
    end
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name ='#{name}' "
    DB[:conn].execute(sql)
  end

  def self.find_by(attribute)
    ary = []
    attribute.each do |key, value|
      ary << key.to_s
      ary << value
    end

    sql = "SELECT * FROM #{table_name} WHERE #{ary[0]} = '#{ary[1]}'"
    DB[:conn].execute(sql)
  end

  #instance methods
  def table_name_for_insert
    Student.table_name
  end

  def col_names_for_insert
    Student.column_names.delete_if do |name|
      name == "id"
    end.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end


end
