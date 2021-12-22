#=
Day 22: Reactor Reboot
=#

#=
=#
function partOne(input::Array{String,1})
    CS = parseInput(input)
    space = Cube(Interval(-50, 50), Interval(-50, 50), Interval(-50, 50))
    CS = filter(x -> isIn(x[2], space), CS)

    RES = CubeSet(Set([CS[1][2]]))
    println(volume(RES))
    println("CUBES = ", nC(RES))
    for (state, C) in CS[2:end]
        RES = state == "on" ? RES + C : RES - C
        println(volume(RES))
        println("CUBES = ", nC(RES))
    end
    return volume(RES)
end

function reduceCubes(cubes)
    # CANBEXJOINED(C1, C2) = areConsecutive(C1.x, C2.x) && C1.y == C2.y && C1.z == C2.z
    # JOINX(C1, C2) = Cube(C1.x + C2.x, C1.y, C1.z)
    # testCube = Set((C1, C2) for C1 in cubes for C2 in cubes if CANBEXJOINED(C1, C2))
    # joinedCube = Set(JOINX(C[1], C[2]) for C in testCube)
    # cubes = setdiff(cubes, [C[1] for C in testCube])
    # cubes = union(cubes, joinedCube)
    cubes = Set(x for x in cubes if isempty(filter(y -> x != y && isIn(x, y), cubes)))
    return cubes
end

function parseInput(input::Array{String,1})
    cubes = []
    regex = r"x=(-?[\d]+)..(-?[\d]+),y=(-?[\d]+)..(-?[\d]+),z=(-?[\d]+)..(-?[\d]+)"
    for l in input
        if startswith(l, "on")
            m = match(regex, l)
            i = [parse(Int, m[x]) for x = 1:6]
            push!(cubes, ("on", Cube(Interval(i[1], i[2]), Interval(i[3], i[4]), Interval(i[5], i[6]))))
        else
            m = match(regex, l)
            i = [parse(Int, m[x]) for x = 1:6]
            push!(cubes, ("off", Cube(Interval(i[1], i[2]), Interval(i[3], i[4]), Interval(i[5], i[6]))))
        end
    end
    return cubes
end

struct Interval
    lower::Int
    upper::Int
    Interval(x, y) = x > y ? error("out of order") : new(x, y)
end

struct Cube
    x::Interval
    y::Interval
    z::Interval
end

struct CubeSet
    cubes::Set{Cube}
end

function Base.:+(S::CubeSet, V::Cube)::CubeSet
    if isempty(S.cubes)
        return CubeSet(Set([V]))
    end
    newCS = Set(x + V for x in S.cubes)
    newCS = Set(union(newCS...))
    return CubeSet(reduceCubes(newCS))
end

function Base.:-(S::CubeSet, V::Cube)::CubeSet
    if isempty(S.cubes)
        return S
    end
    newCS = Set(x - V for x in S.cubes)
    newCS = Set(union(newCS...))
    return CubeSet(reduceCubes(newCS))
end

function volume(CS::CubeSet)
    sum([volume(c) for c in CS.cubes])
end

function nC(CS::CubeSet)
    return length(CS.cubes)
end

function Base.:+(I::Interval, J::Interval)::Interval
    if !areConsecutive(I, J)
        error("Not consecutive Interval")
    end
    return Interval(min(I.lower, J.lower), max(I.upper, J.upper))
end

function Base.length(I::Interval)
    return I.upper - I.lower + 1
end

function Base.intersect(I::Interval, J::Interval)
    if J.lower > I.upper || I.lower > J.upper
        return nothing
    else
        return Interval(max(J.lower, I.lower), min(J.upper, I.upper))
    end
end

function Base.:+(S::Cube, V::Cube)::Array{Cube}
    return sumSquares(S, V)
end

function Base.:-(S::Cube, V::Cube)::Array{Cube}
    return diffSquares(S, V)
end

function volume(S::Cube)
    return length(S.x) * length(S.y) * length(S.z)
end

function subset(I::Interval, J::Interval)
    return I.lower >= J.lower && I.upper <= J.upper
end

function isIn(S::Cube, V::Cube)
    return subset(S.x, V.x) && subset(S.y, V.y) && subset(S.z, V.z)
end

function emptyIntersect(S::Cube, V::Cube)
    return intersect(S.x, V.x) === nothing || intersect(S.y, V.y) === nothing || intersect(S.z, V.z) === nothing
end

function areConsecutive(I::Interval, J::Interval)
    return I.upper == J.lower - 1 || J.upper == I.lower - 1
end

function sumSquares(S::Cube, V::Cube)::Vector{Cube}
    if isIn(S, V)
        return [V]
    elseif isIn(V, S)
        return [S]
    elseif emptyIntersect(S, V)
        return [S, V]
    else
        splitX = splitI(S.x, V.x)
        splitY = splitI(S.y, V.y)
        splitZ = splitI(S.z, V.z)
        return [Cube(XI, YI, ZI) for (XI, YI, ZI) in Base.product(splitX, splitY, splitZ)
                if isIn(Cube(XI, YI, ZI), S) || isIn(Cube(XI, YI, ZI), V)]
    end
end

function diffSquares(S::Cube, V::Cube)::Vector{Cube}
    if isIn(S, V)
        return []
    elseif emptyIntersect(S, V)
        return [S]
    else
        splitX = splitI(S.x, V.x)
        splitY = splitI(S.y, V.y)
        splitZ = splitI(S.z, V.z)
        return [Cube(XI, YI, ZI) for (XI, YI, ZI) in Base.product(splitX, splitY, splitZ)
                if isIn(Cube(XI, YI, ZI), S) && !isIn(Cube(XI, YI, ZI), V)]
    end
end

function splitI(I::Interval, J::Interval)
    U = I ∩ J
    if U === nothing
        return return [I, J]
    end

    if min(I.lower, J.lower) > U.lower - 1
        IU = nothing
    else
        IU = Interval(min(I.lower, J.lower), U.lower - 1)
    end
    if U.upper + 1 > max(J.upper, I.upper)
        UJ = nothing
    else
        UJ = Interval(U.upper + 1, max(J.upper, I.upper))
    end

    return filter(x -> x !== nothing, [IU, U, UJ])
end

#=
=#
function partTwo(input::Array{String,1})
    CS = parseInput(input)

    RES = CubeSet(Set([CS[1][2]]))
    println(volume(RES))
    println("CUBES = ", nC(RES))
    for (i, (state, C)) in enumerate(CS[2:end])
        println("Step ", i, " of ", length(CS[2:end]))
        RES = state == "on" ? RES + C : RES - C
        println(volume(RES))
        println("CUBES = ", nC(RES))
    end
    return volume(RES)
end

function main()
    open("test2.txt") do f
        input = readlines(f)
        part1result = partOne(input)
        part2result = partTwo(input)
        printstyled("-- AoC Day 22 --\n", bold = true)
        println("Result Part 1: ", part1result)
        println("Result Part 2: ", part2result)
    end
end

main()