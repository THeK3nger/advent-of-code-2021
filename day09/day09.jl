#=
Day 9: Smoke Basin
=#

#=
These caves seem to be lava tubes. Parts are even still volcanically active;
small hydrothermal vents release smoke into the caves that slowly settles like
rain.

If you can model how the smoke flows through the caves, you might be able to
avoid it and be that much safer. The submarine generates a heightmap of the
floor of the nearby caves for you (your puzzle input).

Smoke flows to the lowest point of the area it's in. For example, consider the
following heightmap:

2199943210
3987894921
9856789892
8767896789
9899965678

Each number corresponds to the height of a particular location, where 9 is the
highest and 0 is the lowest a location can be.

Your first goal is to find the low points - the locations that are lower than
any of its adjacent locations. Most locations have four adjacent locations (up,
down, left, and right); locations on the edge or corner of the map have three or
two adjacent locations, respectively. (Diagonal locations do not count as
adjacent.)

In the above example, there are four low points, all highlighted: two are in the
first row (a 1 and a 0), one is in the third row (a 5), and one is in the bottom
row (also a 5). All other locations on the heightmap have some lower adjacent
location, and so are not low points.

The risk level of a low point is 1 plus its height. In the above example, the
risk levels of the low points are 2, 1, 6, and 6. The sum of the risk levels of
all low points in the heightmap is therefore 15.

Find all of the low points on your heightmap. What is the sum of the risk levels
of all low points on your heightmap?
=#
function partOne(input::Array{String,1})
    hmap = parse.(Int, hcat(collect.(input)...))
    minimaIdx = getMinima(hmap)
    sum(hmap[minimaIdx]) + length(minimaIdx)
end

offsets(c) = [(c[1] - 1, c[2]), (c[1] + 1, c[2]), (c[1], c[2] - 1), (c[1], c[2] + 1)]
inBound(ci, sizes) = ci[1] > 0 && ci[2] > 0 && ci[1] <= sizes[1] && ci[2] <= sizes[2]
neighbors(ci, sizes) = filter(x -> inBound(x, sizes), map(x -> CartesianIndex(x), offsets(ci)))

function getMinima(hmap)
    sizes = size(hmap)
    isMinima(ci) = all(hmap[neighbors(ci, sizes)] .> hmap[ci])
    return [ci for ci in CartesianIndices(hmap) if isMinima(ci)]
end


#=
Next, you need to find the largest basins so you know what areas are most
important to avoid.

A basin is all locations that eventually flow downward to a single low point.
Therefore, every low point has a basin, although some basins are very small.
Locations of height 9 do not count as being in any basin, and all other
locations will always be part of exactly one basin.

The size of a basin is the number of locations within the basin, including the
low point. The example above has four basins.

The top-left basin, size 3:

2199943210
3987894921
9856789892
8767896789
9899965678

The top-right basin, size 9:

2199943210
3987894921
9856789892
8767896789
9899965678

The middle basin, size 14:

2199943210
3987894921
9856789892
8767896789
9899965678

The bottom-right basin, size 9:

2199943210
3987894921
9856789892
8767896789
9899965678

Find the three largest basins and multiply their sizes together. In the above
example, this is 9 * 14 * 9 = 1134.

What do you get if you multiply together the sizes of the three largest basins?
=#
function partTwo(input::Array{String,1})
    hmap = parse.(Int, hcat(collect.(input)...))
    sizes = size(hmap)
    minimaIdx = getMinima(hmap)
    basinSizes = []
    for minima in minimaIdx
        queue = []
        basin = Set()
        push!(queue, minima)
        while length(queue) > 0
            current = pop!(queue)
            push!(basin, current)
            newI = neighbors(current, sizes)
            append!(queue, filter(x -> hmap[x] != 9 && x ∉ basin, newI))
        end
        push!(basinSizes, length(basin))
    end
    return prod(sort(basinSizes, rev = true)[1:3])
end

function main()
    open("input.txt") do f
        input = readlines(f)
        part1result = partOne(input)
        part2result = partTwo(input)
        printstyled("-- AoC Day 09 --\n", bold = true)
        println("Result Part 1: ", part1result)
        println("Result Part 2: ", part2result)
    end
end

main()