class NameSearch

    def initialize world
        @world = world
    end

    def find_by_fragment surfaces, containers, fragment
        fragment = fragment.downcase

        results = []
        things = []

        surfaces.each do |surf|
            surf.things.each do |t|
                things.push t
            end
        end
        containers.each do |con|
            con.contents.each do |t|
                things.push t
            end
        end

        things.each do |thing|
            words = thing.name.downcase.split
            words.each do |word|
                if word.start_with?(fragment)
                    results.push thing
                    break
                end
            end
        end

        results
    end

end
