#=
Day 20: Trench Map
=#
using LinearAlgebra

#=
=#
function partOne(input::Array{String,1})
    IMA = input[1]
    image = parseImage(input[3:end])
    (pixels, bound, outlit) = image
    for _ = 1:2
        minX, minY = bound[1]
        maxX, maxY = bound[2]
        new_pixels = Set((x, y) for x = minX-5:maxX+5 for y = minY-5:maxY+5 if applyIMA(IMA, image, (x, y)))
        new_bound = getBound(new_pixels)
        image = (deepcopy(new_pixels), new_bound, outlit ? (IMA[end] == '#') : IMA[1] == '#')
        bound = new_bound
        outlit = image[3]
    end
    return image[3] ? Inf : length(image[1])
end

function parseImage(image)
    pixels = Set((x, y) for (y, r) in enumerate(image) for (x, p) in enumerate(r) if p == '#')
    bound = getBound(pixels)
    return (pixels, bound, false)
end

function isLit(image, p)
    (pixels, bound, outlit) = image
    if inBound(bound, p)
        return p ∈ pixels
    else
        return outlit
    end
end

function applyIMA(IMA, image, p)
    return IMA[kernel(image, p)+1] == '#'
end

function kernel(image, p)
    binary = String([isLit(image, (x, y)) ? '1' : '0' for y = p[2]-1:p[2]+1 for x = p[1]-1:p[1]+1])
    return parse(Int, binary, base = 2)
end

function getBound(pixels)
    minX = minimum([p[1] for p in pixels])
    minY = minimum([p[2] for p in pixels])
    maxX = maximum([p[1] for p in pixels])
    maxY = maximum([p[2] for p in pixels])
    return ((minX, minY), (maxX, maxY))
end

function printImage(image)
    (pixels, bound, outlit) = image
    minX, minY = bound[1]
    maxX, maxY = bound[2]
    for y = minY-5:maxY+5
        for x = minX-5:maxX+5
            if isLit(image, (x, y))
                if x == 1 && y == 1
                    print('$')
                else
                    print('#')
                end
            else
                if x == 1 && y == 1
                    print('o')
                else
                    print('.')
                end
            end
        end
        println()
    end
    println()
end

function inBound(bound, p)
    x, y = p
    minX, minY = bound[1]
    maxX, maxY = bound[2]
    return x <= maxX && x >= minX &&
           y <= maxY && y >= minY

end

#=
=#
function partTwo(input::Array{String,1})
    IMA = input[1]
    image = parseImage(input[3:end])
    (pixels, bound, outlit) = image
    for _ = 1:50
        minX, minY = bound[1]
        maxX, maxY = bound[2]
        new_pixels = Set((x, y) for x = minX-5:maxX+5 for y = minY-5:maxY+5 if applyIMA(IMA, image, (x, y)))
        new_bound = getBound(new_pixels)
        image = (deepcopy(new_pixels), new_bound, outlit ? (IMA[end] == '#') : IMA[1] == '#')
        bound = new_bound
        outlit = image[3]
    end
    return image[3] ? Inf : length(image[1])
end

function main()
    open("input.txt") do f
        input = readlines(f)
        part1result = partOne(input)
        part2result = partTwo(input)
        printstyled("-- AoC Day 20 --\n", bold = true)
        println("Result Part 1: ", part1result)
        println("Result Part 2: ", part2result)
    end
end

main()