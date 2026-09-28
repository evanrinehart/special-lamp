def make_example_world
    world = load_schema("world.schema")
    
    rooms = world[:rooms]
    rooms.insert(1, :name => "Cryochamber")
    rooms.insert(2, :name => "Loading Bay")
    rooms.insert(3, :name => "Coat Closet")
    rooms.insert(4, :name => "Navigation")

    mobs = world[:mobs]
    mobs.insert(5, :name => "Player", :room_id => 1, :health_id => 9, :oxygen_id => 10)

    things = world[:things]
    things.insert(6, :name => "fuse", :mob_id => 5)
    things.insert(7, :name => "spanner", :mob_id => 5)
    things.insert(8, :name => "cheese sandwich", :room_id => 1)

    powerbars = world[:powerbars]
    powerbars.insert(9, :value => 100, :value_max => 100, :regen => nil, :cooldown => 0)
    powerbars.insert(10, :value => 100, :value_max => 100, :regen => nil, :cooldown => 0)

    world
end

