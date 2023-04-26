module LinuxMonitorTools

# store a pointer to the process
const proc = Ref{Union{Base.Process, Nothing}}(nothing)
const mpid = getpid()

const bpath = tempname()

function __init__()

  mkpath( bpath )

end

if isfile(joinpath(@__DIR__, "..", "deps", "deps.jl"))
  include("../deps/deps.jl")
else
  @error("Bash scripts not properly installed. Please run Pkg.build(\"LinuxMonitorTools\")")
end

function start_process(; name = "linuxmonitortools", basepath = bpath)
  # start the process
  @info "starting process"
  proc[] = open(pipeline(`$(execpath) $(mpid) $(name) $(basepath)`))
end

function kill_process()
  # kill the process
  @info "killing process"
  if proc[] !== nothing
    Base.kill(proc[])
    proc[] = nothing
  end
end

end
