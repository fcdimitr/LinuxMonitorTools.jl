if Sys.islinux()

else
  error("This package only works on Linux")
end

# find directories
exedir = joinpath(@__DIR__, "bin")

# where to place dependencies
path_deps = joinpath(@__DIR__, "deps.jl")

# write the path of all compiled libraries
@info "printing libraries"
open(path_deps, "w") do io
  write(io, "const execpath = \"$(exedir)/linux_monitor.sh\"\n")
end

