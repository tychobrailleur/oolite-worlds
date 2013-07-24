require 'neography'
require 'ostruct'

worlds = []

File.open('worlds.txt', 'r').each do |line|
  line.scan(/\#\s?([0-9]+)\. (\w+) \([^\)]+\), \{([0-9,]+)\}/) do |m|
    world = OpenStruct.new
    world.id = m[0].to_i
    world.name = m[1]
    world.links = m[2]

    worlds << world
  end
end

puts "Found #{worlds.count} planets."

@neo = Neography::Rest.new
worlds_hash = Hash.new

# Delete all nodes and relationships first
@neo.execute_query("START n=node(*) MATCH n-[r?]-() DELETE n, r;")

# First create all the nodes
worlds.each do |w|
  planet = @neo.create_node("id" => w.id, "name" => w.name)
  worlds_hash[w.id] = planet
  puts "Planet: #{w.name}"

  # Add node to the Planet index
  @neo.add_node_to_index("planet", "name", w.name, planet)
end

# Second create all the relationships
worlds.each do |w|
  current_world = worlds_hash[w.id]
  w.links.split(/,/).each do |id|
    link_to_world = worlds_hash[id.to_i]
    puts "Linking #{current_world} to #{link_to_world['name']}"
    @neo.create_relationship("accessible", current_world, link_to_world)
  end
end

