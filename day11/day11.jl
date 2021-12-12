#=
Day 10: Syntax Scoring
=#

#=
You enter a large cavern full of rare bioluminescent dumbo octopuses! They seem
to not like the Christmas lights on your submarine, so you turn them off for
now.

There are 100 octopuses arranged neatly in a 10 by 10 grid. Each octopus slowly
gains energy over time and flashes brightly for a moment when its energy is
full. Although your lights are off, maybe you could navigate through the cave
without disturbing the octopuses if you could predict when the flashes of light
will happen.

Each octopus has an energy level - your submarine can remotely measure the
energy level of each octopus (your puzzle input). For example:

5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526

The energy level of each octopus is a value between 0 and 9. Here, the top-left
octopus has an energy level of 5, the bottom-right one has an energy level of 6,
and so on.

You can model the energy levels and flashes of light in steps. During a single
step, the following occurs:

First, the energy level of each octopus increases by 1.

Then, any octopus with an energy level greater than 9 flashes. This increases
the energy level of all adjacent octopuses by 1, including octopuses that are
diagonally adjacent. If this causes an octopus to have an energy level greater
than 9, it also flashes. This process continues as long as new octopuses keep
having their energy level increased beyond 9. (An octopus can only flash at most
once per step.)

Finally, any octopus that flashed during this step has its energy level set to
0, as it used all of its energy to flash.

Adjacent flashes can cause an octopus to flash on a step even if it begins that
step with very little energy. Consider the middle octopus with 1 energy in this
situation:

Before any steps:

11111
19991
19191
19991
11111

After step 1:

34543
40004
50005
40004
34543

After step 2:

45654
51115
61116
51115
45654

[...]

After 100 steps, there have been a total of 1656 flashes.

Given the starting energy levels of the dumbo octopuses in your cavern, simulate
100 steps. How many total flashes are there after 100 steps?
=#

function partOne(input::Array{String,1})
    octomap = parse.(Int, hcat(collect.(input)...))
    S = size(octomap)
    flashCount = 0
    for _ = 1:100
        octomap = octomap .+ ones(Int, S)
        allFlashed = falses(S)
        flashing = octomap .> 9
        flashCount += sum(flashing)
        while true
            octomap += flashEffect(flashing)
            allFlashed = allFlashed .| flashing
            newFlashing = (octomap .> 9) .⊻ allFlashed
            flashCount += sum(newFlashing)
            flashing = newFlashing
            newFlashing != falses(S) || break
        end
        octomap[allFlashed] .= 0
    end
    return flashCount
end

function flashEffect(mask)
    result = zeros(Int, size(mask))
    R = CartesianIndices(mask)
    Ifirst, Ilast = first(R), last(R)
    I1 = oneunit(Ifirst)
    for I in R
        result[I] = sum(mask[max(Ifirst, I - I1):min(Ilast, I + I1)])
    end
    return result
end

#=
It seems like the individual flashes aren't bright enough to navigate. However,
you might have a better option: the flashes seem to be synchronizing!

In the example above, the first time all octopuses flash simultaneously is step
195:

After step 193:

5877777777
8877777777
7777777777
7777777777
7777777777
7777777777
7777777777
7777777777
7777777777
7777777777

After step 194:

6988888888
9988888888
8888888888
8888888888
8888888888
8888888888
8888888888
8888888888
8888888888
8888888888

After step 195:

0000000000
0000000000
0000000000
0000000000
0000000000
0000000000
0000000000
0000000000
0000000000
0000000000

If you can calculate the exact moments when the octopuses will all flash
simultaneously, you should be able to navigate through the cavern. What is the
first step during which all octopuses flash?
=#
function partTwo(input::Array{String,1})
    octomap = parse.(Int, hcat(collect.(input)...))
    S = size(octomap)
    for step = 1:1000
        octomap = octomap .+ ones(Int, S)
        allFlashed = falses(S)
        flashing = octomap .> 9
        while true
            octomap += flashEffect(flashing)
            allFlashed = allFlashed .| flashing
            newFlashing = (octomap .> 9) .⊻ allFlashed
            flashing = newFlashing
            newFlashing != falses(S) || break
        end
        octomap[allFlashed] .= 0
        if allFlashed == trues(S)
            return step
        end
    end
end

function main()
    open("input.txt") do f
        input = readlines(f)
        part1result = partOne(input)
        part2result = partTwo(input)
        printstyled("-- AoC Day 11 --\n", bold = true)
        println("Result Part 1: ", part1result)
        println("Result Part 2: ", part2result)
    end
end

main()