#=
Day 15: Chiton
=#

#=
You've almost reached the exit of the cave, but the walls are getting closer
together. Your submarine can barely still fit, though; the main problem is that
the walls of the cave are covered in chitons, and it would be best not to bump
any of them.

The cavern is large, but has a very low ceiling, restricting your motion to two
dimensions. The shape of the cavern resembles a square; a quick scan of chiton
density produces a map of risk level throughout the cave (your puzzle input).
For example:

1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581

You start in the top left position, your destination is the bottom right
position, and you cannot move diagonally. The number at each position is its
risk level; to determine the total risk of an entire path, add up the risk
levels of each position you enter (that is, don't count the risk level of your
starting position unless you enter it; leaving it adds no risk to your total).

Your goal is to find a path with the lowest total risk. In this example, a path
with the lowest total risk is highlighted here:

1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581

The total risk of this path is 40 (the starting position is never entered, so
its risk is not counted).

What is the lowest total risk of any path from the top left to the bottom right?
=#
function partOne(input::Array{String,1})
    mappa = parse.(Int, hcat(collect.(input)...))
    start = CartesianIndex(1, 1)
    destination = maximum(CartesianIndices(mappa))

    return greedy(mappa, start, destination)
end

#=
=#
function partTwo(input::Array{String,1})
    mappa = parse.(Int, hcat(collect.(input)...))
    start = CartesianIndex(1, 1)
    destination = maximum(CartesianIndices(mappa)) * 5
    return greedy(mappa, start, destination)
end

function greedy(mappa, start, destination)
    function G(c)
        x = c[1]
        y = c[2]
        (X, Y) = size(mappa)
        trueX = ((x - 1) % X) + 1
        trueY = ((y - 1) % Y) + 1
        qX = Int(floor((x - 1) / X))
        qY = Int(floor((y - 1) / Y))
        return (((mappa[CartesianIndex(trueX, trueY)] + (qX + qY)) - 1) % 9) + 1
    end

    function CNeighbors(c)
        h = CartesianIndex(1, 0)
        v = CartesianIndex(0, 1)
        return filter(x -> x[1] >= 1 &&
                               x[1] <= destination[1] &&
                               x[2] >= 1 &&
                               x[2] <= destination[2],
            [c - h, c + h, c - v, c + v])
    end

    queue = [(start, 0)]
    visited = Set([])
    while !isempty(queue)
        (current, g) = pop!(queue)
        if current == destination
            return g
        end
        if current ∈ visited
            continue
        end
        push!(visited, current)
        neighbors = filter(n -> n ∉ visited, CNeighbors(current))
        append!(queue, [(n, g + G(n)) for n in neighbors])
        sort!(queue, by = x -> x[2], rev = true, alg = QuickSort)
    end
end

function main()
    open("input.txt") do f
        input = readlines(f)
        part1result = partOne(input)
        part2result = partTwo(input)
        printstyled("-- AoC Day 15 --\n", bold = true)
        println("Result Part 1: ", part1result)
        println("Result Part 2: ", part2result)
    end
end

main()