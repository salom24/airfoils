using Plots

function plotnaca(naca::String, nodes::Int)
    h = parse(Int,naca[1:1])/100
    p = parse(Int,naca[2:2])/10
    t = parse(Int,naca[3:4])/100

    xbase = map(-nodes:nodes) do x
        (1 - cos(x * π / nodes)) / 2
    end
    ybase = map(xbase) do x
        if x <= p
            h/p^2 * x * (2p - x) 
        else
            h/(1-p)^2 * (1 + 2p*(x-1) - x^2)
        end
    end

    width = map(xbase) do x
        5t * (0.2969sqrt(x) - 0.126x - 0.3516x^2 + 0.2843x^3 - 0.1036x^4) 
    end

    pte = map(xbase) do x
        if x <= p
            2h / p^2 * (p-x)
        else
            2h / (1-p)^2 * (p-x)
        end
    end

    cosθ = map(pte) do pte
        1 / sqrt(1 + pte^2)
    end

    cosθ[1:nodes] = -cosθ[1:nodes]

    sinθ = map(pte, cosθ) do pte, a
        pte * a
    end

    x = @. xbase - width * sinθ
    y = @. ybase + width * cosθ

    plot(x, y, aspect_ratio=:equal)
    plot!(xbase, ybase)
end

plotnaca("6515", 50)