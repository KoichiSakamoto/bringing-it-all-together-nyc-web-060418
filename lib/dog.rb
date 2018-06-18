require 'pry'
class Dog

  attr_accessor :id, :name, :breed

  def initialize(hash)
    #binding.pry
    @id = hash[:id]
    @name = hash[:name]
    @breed = hash[:breed]
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?,?)",[@name,@breed])
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(hash)
    pupper = Dog.new(hash)
    pupper.save
  end

  def self.find_by_id(id)
    hash = DB[:conn].execute("SELECT * FROM dogs WHERE dogs.id = ?", id)[0]
    Dog.new({:id => id[0], :name => id[1], :breed => id[2]})
  end

  def self.find_or_create_by(name:, breed:)
    pupper = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !pupper.empty?
      pupper_data = pupper[0]
      pupper = Dog.new({:id => pupper_data[0], :name => pupper_data[1], :breed => pupper_data[2]})
    else
      pupper = self.create(name: name, breed: breed)
    end
    pupper
  end

  def self.new_from_db(row)
    pupper = Dog.new({:id => row[0], :name => row[1], :breed => row[2]})
  end

  def self.find_by_name(name)
    Dog.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0])
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?",[@name,@breed,@id])
    self
  end

end
