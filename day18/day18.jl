#=
Day 18: Snailfish
=#

#=
=#
function partOne(input::Array{String,1})
    snailfishes = [parseSnailFish(x) for x in input]
    return magnitude(sum(snailfishes))
end

struct SnailFishNumber
    tree::Vector{Tuple{Int,Int}}
end

function Base.:+(a::SnailFishNumber, b::SnailFishNumber)::SnailFishNumber
    A = [x .+ (0, 1) for x in a.tree]
    B = [x .+ (0, 1) for x in b.tree]
    return reduce(SnailFishNumber(append!(A, B)))
end

function parseSnailFish(str::String)::SnailFishNumber
    arr = include_string(Main, str)
    return SnailFishNumber(parseSnailFishArray(arr))
end

function parseSnailFishArray(arr, depth = 0)
    if arr isa Number
        return [(arr, depth)]
    end
    return append!(parseSnailFishArray(arr[1], depth + 1), parseSnailFishArray(arr[2], depth + 1))
end

function explode(sfn::SnailFishNumber)::SnailFishNumber
    explodingIdx = findfirst(x -> x[2] > 4, sfn.tree)
    if explodingIdx === nothing
        return sfn
    end
    return explodeIdx(sfn, explodingIdx)
end

function canExplode(sfn::SnailFishNumber)::Bool
    any(x -> x[2] > 4, sfn.tree)
end

function explodeIdx(sfn::SnailFishNumber, idx::Int)::SnailFishNumber
    tree = sfn.tree
    explodingPair = tree[idx:idx+1]
    newTree = deleteat!(tree, idx:idx+1)
    newTree = insert!(newTree, idx, (0, explodingPair[1][2] - 1))
    if idx - 1 > 0
        newTree[idx-1] = newTree[idx-1] .+ (explodingPair[1][1], 0)
    end
    if idx + 1 <= length(newTree)
        newTree[idx+1] = newTree[idx+1] .+ (explodingPair[2][1], 0)
    end
    return SnailFishNumber(newTree)
end

function canSplit(sfn::SnailFishNumber)::Bool
    any(x -> x[1] >= 10, sfn.tree)
end

function split(sfn::SnailFishNumber)::SnailFishNumber
    splitIdx = findfirst(x -> x[1] >= 10, sfn.tree)
    if splitIdx === nothing
        return sfn
    end
    return splitAt(sfn, splitIdx)
end

function splitAt(sfn::SnailFishNumber, idx::Int)::SnailFishNumber
    tree = sfn.tree
    (splitted, splittedDepth) = tree[idx]
    newTree = deleteat!(tree, idx)
    newTree = insert!(newTree, idx, (floor(splitted / 2), splittedDepth + 1))
    newTree = insert!(newTree, idx + 1, (ceil(splitted / 2), splittedDepth + 1))
    return SnailFishNumber(newTree)
end

function reduce(sfn::SnailFishNumber)::SnailFishNumber
    while canExplode(sfn) || canSplit(sfn)
        if canExplode(sfn)
            sfn = explode(sfn)
        elseif canSplit(sfn)
            sfn = split(sfn)
        end
    end
    return sfn
end

function magnitude(sfn::SnailFishNumber)::Number
    function findPair(tree)::Int
        for i = 1:length(tree)-1
            if tree[i][2] == tree[i+1][2]
                return i
            end
        end
    end

    tree = deepcopy(sfn.tree)
    while length(tree) > 1
        pairIdx = findPair(tree)
        pairN = tree[pairIdx:pairIdx+1]
        M = pairN[1][1] * 3 + pairN[2][1] * 2
        tree = deleteat!(tree, pairIdx:pairIdx+1)
        tree = insert!(tree, pairIdx, (M, pairN[1][2] - 1))
    end
    return tree[1][1]
end

#=
=#
function partTwo(input::Array{String,1})
    snailfishes = [parseSnailFish(x) for x in input]
    maximum([magnitude(a + b) for a in snailfishes for b in snailfishes])
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