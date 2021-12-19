#=
Day 19: Beacon Scanner
=#
using LinearAlgebra

AXIS = [
    [1; 0; 0],
    [-1; 0; 0],
    [0; 1; 0],
    [0; -1; 0],
    [0; 0; 1],
    [0; 0; -1],
]

ROTATIONS = [hcat(x, y, cross(x, y)) for x in AXIS for y in AXIS]

#=
=#
function partOne(input::Array{String,1})
    sensorsData = parseSensorData(input)
    scannerMap = matchScanners(sensorsData)
    count_beacons(scannerMap, sensorsData)
end

function matchScanners(sensorsData)
    scanner_graph = [[] for _ = 1:length(sensorsData)]
    for (i, SA) in enumerate(sensorsData)
        for (j, SB) in enumerate(sensorsData)
            i == j && continue
            for ba in SA, bb in SB, R in ROTATIONS
                T = ba .- R * bb
                transformed = Set(R * p .+ T for p in SB)
                if length(intersect(transformed, SA)) >= 12
                    push!(scanner_graph[i], (j, R, T))
                    break
                end
            end
        end
    end
    return scanner_graph
end

function composeSteps(s1, s2)
    r1, t1 = s1
    r2, t2 = s2
    (r2 * r1, r2 * t1 .+ t2)
end

function scanner_bfs(source, scanner_graph)
    n_scanners = length(scanner_graph)
    q = [(source, (Matrix(1I, 3, 3), [0, 0, 0]))]
    visited = zeros(Bool, n_scanners)
    paths = [(Matrix(1I, 3, 3), [0, 0, 0]) for _ = 1:n_scanners]
    while !all(visited)
        cur_scanner, cur_path = popfirst!(q)
        visited[cur_scanner] = true
        for (neighbour, R, T) in scanner_graph[cur_scanner]
            visited[neighbour] && continue
            next_path = composeSteps((R, T), cur_path)
            paths[neighbour] = next_path
            push!(q, (neighbour, next_path))
        end
    end
    paths
end

function count_beacons(scanner_graph, scanners)
    paths = scanner_bfs(1, scanner_graph)
    length(Set((R * b .+ T) for (i, (R, T)) in enumerate(paths) for b in scanners[i]))
end

function parseSensorData(input)
    scanners = []
    this_scanner = Set{Array{Int}}()
    for line in input[2:end]
        length(line) == 0 && continue
        if startswith(line, "---")
            push!(scanners, this_scanner)
            this_scanner = Set{Array{Int}}()
            continue
        end
        coords = parse.(Int, split(line, ","))
        push!(this_scanner, coords)
    end
    push!(scanners, this_scanner)
    scanners
end

#=
=#
function partTwo(input::Array{String,1})
    sensorsData = parseSensorData(input)
    scanner_graph = matchScanners(sensorsData)
    max_dist = 0
    for source = 1:length(scanner_graph)
        paths = scanner_bfs(source, scanner_graph)
        tmd = maximum(sum(abs.(p[2])) for p in paths)
        if tmd > max_dist
            max_dist = tmd
        end
    end
    max_dist
end

function main()
    open("test.txt") do f
        input = readlines(f)
        part1result = partOne(input)
        part2result = partTwo(input)
        printstyled("-- AoC Day 19 --\n", bold = true)
        println("Result Part 1: ", part1result)
        println("Result Part 2: ", part2result)
    end
end

main()