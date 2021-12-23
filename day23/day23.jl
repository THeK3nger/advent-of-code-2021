#=
Day 23: Amphipod
=#

using Memoize

#=
#############
#.....D.....#
###.#B#C#D###
  #A#B#C#A#
  #########
=#
function partOne()

    S = State(
        Room([D, A]),
        Room([D, C]),
        Room([A, B]),
        Room([C, B]),
        Hallway([]))
    S2 = State(
        Room([A, B]),
        Room([D, C]),
        Room([C, B]),
        Room([A, D]),
        Hallway([]))
    DESTINATION = State(
        Room([A]),
        Room([B, B]),
        Room([C, C]),
        Room([A, D]),
        Hallway([(D, 6)]))
    #display(moveBack(DESTINATION))
    mincostM(DESTINATION)
end

@enum Amphipod A B C D

AmphiCost = Dict(A => 1, B => 10, C => 100, D => 1000)
COST(a::Amphipod) = AmphiCost[a]
HALLWAYSTOPS = [1, 2, 4, 6, 8, 10, 11]

struct Room
    stack::Vector{Amphipod}
    size::Int
    Room(stack) = new(stack, 2)
end

Base.:(==)(R::Room, P::Room) = R.size == P.size && R.stack == P.stack

@inline function popRoom(R::Room, home::Amphipod)
    if isempty(R.stack)
        return (R, nothing, 0)
    end
    if all(x -> home == x, R.stack)
        return (R, nothing, 0)
    end
    stack = copy(R.stack)
    a = pop!(stack)
    return (Room(stack), a, COST(a) * (R.size - length(stack)))
end

@inline function pushRoom(R::Room, a::Amphipod)
    if length(R.stack) == R.size
        (R, 0)
    end
    stack = copy(R.stack)
    if any([x !== a for x in stack])
        (R, 0)
    end
    push!(stack, a)
    return (Room(stack), COST(a) * (R.size - length(stack) + 1))
end

struct Hallway
    hallway::Array{Tuple{Amphipod,Int}}
end

Base.:(==)(h1::Hallway, h2::Hallway) = h1.hallway == h2.hallway

struct State
    roomA::Room
    roomB::Room
    roomC::Room
    roomD::Room
    hallway::Hallway
end

Base.:(==)(S::State, P::State) = S.roomA == P.roomA &&
                                 S.roomB == P.roomB &&
                                 S.roomC == P.roomC &&
                                 S.roomD == S.roomD &&
                                 S.hallway == P.hallway

function allDestinationA(S::State, a::Amphipod)
    return allDestination(S, a, 3)
end

function allDestinationB(S::State, a::Amphipod)
    return allDestination(S, a, 5)
end

function allDestinationC(S::State, a::Amphipod)
    return allDestination(S, a, 7)
end

function allDestinationD(S::State, a::Amphipod)
    return allDestination(S, a, 9)
end

function allDestination(S::State, a::Amphipod, I)
    result = []
    H = S.hallway
    for i in HALLWAYSTOPS
        if !any(h -> h[2] <= max(i, I) && h[2] >= min(i, I), H.hallway)
            newH = copy(H.hallway)
            push!(newH, (a, I))
            push!(result, (COST(a) * (abs(i - I)), Hallway(newH)))
        end
    end
    return result
end

function moveRoomA(S::State)
    newRA, a, cPop = popRoom(S.roomA, A)
    if a === nothing
        return []
    end
    allDest = allDestinationA(S, a)
    return [(c + cPop, State(newRA, S.roomB, S.roomC, S.roomD, d)) for (c, d) in allDest]
end

function moveRoomB(S::State)
    newR, a, cPop = popRoom(S.roomB, B)
    if a === nothing
        return []
    end
    allDest = allDestinationB(S, a)
    return [(c + cPop, State(S.roomA, newR, S.roomC, S.roomD, d)) for (c, d) in allDest]
end

function moveRoomC(S::State)
    newR, a, cPop = popRoom(S.roomC, C)
    if a === nothing
        return []
    end
    allDest = allDestinationC(S, a)
    return [(c + cPop, State(S.roomA, S.roomB, newR, S.roomD, d)) for (c, d) in allDest]
end

function moveRoomD(S::State)
    newR, a, cPop = popRoom(S.roomD, D)
    if a === nothing
        return []
    end
    allDest = allDestinationD(S, a)
    return [(c + cPop, State(S.roomA, S.roomB, S.roomC, newR, d)) for (c, d) in allDest]
end

function freeHTo(h, fromI, toI)
    for i = min(fromI, toI):max(fromI, toI)
        if i != fromI
            if any(x -> x[2] == i, h.hallway)
                return false

            end
        end
    end
    return true
end

function moveBack(S::State)
    result = []
    for (h, i) in S.hallway.hallway
        if h == A

            if !freeHTo(S.hallway, i, 3)
                continue
            end
            (newR, c) = pushRoom(S.roomA, A)
            if c == 0
                continue
            end
            newH = copy(S.hallway.hallway)
            newH = filter(x -> x[2] != i, newH)
            push!(result, (c + abs(i - 3) * COST(A), State(newR, S.roomB, S.roomC, S.roomD, Hallway(newH))))
        end
        if h == B
            if !freeHTo(S.hallway, i, 5)
                continue
            end
            (newR, c) = pushRoom(S.roomB, B)
            if c == 0
                continue
            end
            newH = copy(S.hallway.hallway)
            newH = filter(x -> x[2] != i, newH)
            push!(result, (c + abs(i - 5) * COST(B), State(S.roomA, newR, S.roomC, S.roomD, Hallway(newH))))
        end
        if h == C
            if !freeHTo(S.hallway, i, 7)
                continue
            end
            (newR, c) = pushRoom(S.roomC, C)
            if c == 0
                continue
            end
            newH = copy(S.hallway.hallway)
            newH = filter(x -> x[2] != i, newH)
            push!(result, (c + abs(i - 7) * COST(C), State(S.roomA, S.roomB, newR, S.roomD, Hallway(newH))))
        end
        if h == D
            if !freeHTo(S.hallway, i, 9)
                continue
            end
            (newR, c) = pushRoom(S.roomD, D)
            if c == 0
                continue
            end
            newH = copy(S.hallway.hallway)
            newH = filter(x -> x[2] != i, newH)
            push!(result, (c + abs(i - 9) * COST(D), State(S.roomA, S.roomB, S.roomC, newR, Hallway(newH))))

        end
    end
    return result
end

function nexts(S::State)
    Set(moveRoomA(S)) ∪ Set(moveRoomB(S)) ∪ Set(moveRoomC(S)) ∪ Set(moveRoomD(S)) ∪ Set(moveBack(S))
end

@memoize function mincostM(S::State)
    DESTINATION = State(
        Room([A, A]),
        Room([B, B]),
        Room([C, C]),
        Room([D, D]),
        Hallway([]))
    if S == DESTINATION
        return 0
    end
    nextStates = nexts(S)
    if isempty(nextStates)
        return Inf
    end
    allcosts = [c + mincostM(n) for (c, n) in nextStates]
    return minimum(allcosts)
end

function mincost(S::State)
    function H(S::State)
        ES = Dict(A => 3, B => 5, C => 7, D => 9)
        h = 0
        AA = [abs(ES[p] - ES[A]) * COST(p) for p in S.roomA.stack]
        h += isempty(AA) ? 0 : sum(AA)
        BB = [abs(ES[p] - ES[B]) * COST(p) for p in S.roomB.stack]
        h += isempty(BB) ? 0 : sum(BB)
        CC = [abs(ES[p] - ES[C]) * COST(p) for p in S.roomC.stack]
        h += isempty(CC) ? 0 : sum(CC)
        DD = [abs(ES[p] - ES[D]) * COST(p) for p in S.roomD.stack]
        h += isempty(DD) ? 0 : sum(DD)
        for (i, p) in enumerate(S.hallway)
            if p !== nothing
                h += (abs(ES[p] - i) + 1) * COST(p)
            end
        end
        return h
    end

    DESTINATION = State(
        Room([A, A]),
        Room([B, B]),
        Room([C, C]),
        Room([D, D]),
        Array{Union{Amphipod,Nothing}}([nothing for _ = 1:11]))
    queue = [(0, S, H(S))]
    visited = Set([])
    while !isempty(queue)
        println("Q: ", length(queue))
        (K, current, h) = popfirst!(queue)
        if current == DESTINATION
            return K
        end
        if current ∈ visited
            continue
        end
        push!(visited, current)
        N = nexts(current)
        NnotVisited = filter(x -> x[1] ∉ visited, N)
        append!(queue, [(K + c, n, K + c + H(n)) for (c, n) in NnotVisited])
        sort!(queue, by = x -> x[3])
    end
end

#=
=#
function partTwo()

end

function main()
    part1result = partOne()
    part2result = partTwo()
    printstyled("-- AoC Day 22 --\n", bold = true)
    println("Result Part 1: ", part1result)
    println("Result Part 2: ", part2result)
end

main()