# -*- coding: utf-8 -*-
require 'neography' 


start = ARGV[0]
arrival = ARGV[1]

@neo = Neography::Rest.new


start_node = @neo.get_node_index("planet", "name", start) 
arrival_node = @neo.get_node_index("planet", "name", arrival) 

path = @neo.get_path(start_node, arrival_node, [{"type"=> "accessible", "direction" => "all"}], depth=100, algorithm="shortestPath")

path_array = []
path["nodes"].each do |n|
  node = Neography::Node.load(n) 
  path_array << node[:name]
end

puts path_array.join(' → ')
