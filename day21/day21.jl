#=
Day 21: Dirac Dice
=#

using Memoize

#=
=#
function partOne(input::Array{String,1})
    playerOne = 3
    playerTwo = 7
    playerOneScore = 0
    playerTwoScore = 0
    dice = 0
    numRoll = 0
    function rollDice()
        numRoll += 1
        dice = dice % 100 + 1
        return dice
    end
    while playerOneScore < 1000 && playerTwoScore < 1000
        playerOneRolls = [rollDice() for _ = 1:3]
        playerOne = (playerOne + sum(playerOneRolls) - 1) % 10 + 1
        playerOneScore += playerOne
        playerOneScore >= 1000 && break
        playerTwoRolls = [rollDice() for _ = 1:3]
        playerTwo = (playerTwo + sum(playerTwoRolls) - 1) % 10 + 1
        playerTwoScore += playerTwo
        playerTwoScore >= 1000 && break
    end
    return numRoll * min(playerOneScore, playerTwoScore)
end

struct GameState
    p1::Int
    p2::Int
    s1::Int
    s2::Int
end

#=
=#
function partTwo(input::Array{String,1})
    T = [3, 4, 5, 6, 7, 8, 9]
    F = [1, 3, 6, 7, 6, 3, 1]
    @memoize function wins(GS::GameState, turn)::Vector{BigInt}
        if GS.s1 >= 21
            return [1, 0]
        elseif GS.s2 >= 21
            return [0, 1]
        else
            win = [0, 0]
            for (t, freq) in zip(T, F)
                if turn == 1
                    newPos = (GS.p1 + t - 1) % 10 + 1
                    win += freq * wins(GameState(newPos, GS.p2, GS.s1 + newPos, GS.s2), 0)
                else
                    newPos = (GS.p2 + t - 1) % 10 + 1
                    win += freq * wins(GameState(GS.p1, newPos, GS.s1, GS.s2 + newPos), 1)
                end
            end
        end
        win
    end

    W = wins(GameState(3, 7, 0, 0), 1)
    return maximum(W)
end

function main()
    open("input.txt") do f
        input = readlines(f)
        part1result = partOne(input)
        part2result = partTwo(input)
        printstyled("-- AoC Day 21 --\n", bold = true)
        println("Result Part 1: ", part1result)
        println("Result Part 2: ", part2result)
    end
end

main()