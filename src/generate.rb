def make_example_world
    world = load_schema("world.schema")
    
    surfaces = world[:surfaces]
    surfaces.insert(1, :name => "Cryochamber")
    surfaces.insert(2, :name => "Loading Bay")
    surfaces.insert(3, :name => "Coat Closet")
    surfaces.insert(4, :name => "Navigation")
    surfaces.insert(5, :name => "Outside Ship 15")

    things = world[:things]
    things.insert(6, :name => "fuse", :container_id => 9)
    things.insert(7, :name => "spanner", :container_id => 9)
    things.insert(8, :name => "cheese sandwich", :on_surface_id => 1)
    things.insert(9, :name => "Player", :on_surface_id => 1)
    things.insert(10, :name => "Ship 10")

    edges = world[:edges]
    edges.insert(11, :surface_id => 1, :to_edge => 12)
    edges.insert(12, :surface_id => 2, :to_edge => 11)
    edges.insert(13, :surface_id => 2, :to_edge => 14, :index => 1)
    edges.insert(14, :surface_id => 5, :to_edge => 13)

    powerbars = world[:powerbars]
    powerbars.insert(15, :value => 100, :value_max => 100, :regen => nil, :cooldown => 0)
    powerbars.insert(16, :value => 100, :value_max => 100, :regen => nil, :cooldown => 0)

    mobs = world[:mobs]
    mobs.insert(17, :object_id => 9, :health_id => 15, :oxygen_id => 16)

    world
end

