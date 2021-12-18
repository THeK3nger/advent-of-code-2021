#=
Day 17: Trick Shot
=#

#=
=#
function partOne(input::Array{String,1})
    Ax = [155, 182]
    Ay = [-117, -67]
    minX0 = ceil(0.5 * (sqrt(8 * Ax[1] + 1) - 1))
    return maximum([trajectoryYMax(minX0, y0, Ax, Ay) for y0 = 1:10000])
end

T(n) = n * (n + 1) / 2

function trajectoryYMax(x0, y0, Ax, Ay)
    x(n) = min(n, x0) * x0 - T(min(n, x0) - 1)
    y(n) = n * y0 - T(n - 1)
    InBound(n) = y(n) >= Ay[1] && y(n) <= Ay[2] && x(n) >= Ax[1] && x(n) <= Ax[2]
    minX0 = ceil(0.5 * (sqrt(8 * Ax[1] + 1) - 1))
    yMax = T(y0)
    inBoundStep = filter(n -> InBound(n), [n for n = minX0:1000])
    if isempty(inBoundStep)
        return 0
    else
        return yMax
    end
end

function trajectoriesCount(x0, y0, Ax, Ay)
    x(n) = min(n, x0) * x0 - T(min(n, x0) - 1)
    y(n) = n * y0 - T(n - 1)
    InBound(n) = y(n) >= Ay[1] && y(n) <= Ay[2] && x(n) >= Ax[1] && x(n) <= Ax[2]
    return any(n -> InBound(n), [n for n = 1:(Ax[2]*2)])
end

#=
=#
function partTwo(input::Array{String,1})
    Ax = [155, 182]
    Ay = [-117, -67]
    minX0 = ceil(0.5 * (sqrt(8 * Ax[1] + 1) - 1))
    validShots = filter(p -> trajectoriesCount(p[1], p[2], Ax, Ay),
        [(x0, y0) for y0 = Ay[1]:-Ay[1] for x0 = minX0:Ax[2]])
    return length(validShots)
end

function main()
    open("input.txt") do f
        input = readlines(f)
        part1result = partOne(input)
        part2result = partTwo(input)
        printstyled("-- AoC Day 17 --\n", bold = true)
        println("Result Part 1: ", part1result)
        println("Result Part 2: ", part2result)
    end
end

main()