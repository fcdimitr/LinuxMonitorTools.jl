module LinuxMonitorTools

using Dates, DataFrames, CSV, Requires

# store a pointer to the process
const proc = Ref{Union{Base.Process, Nothing}}(nothing)

const mpid  = Ref{Union{Int, Nothing}}(nothing)
const mname = Ref{Union{String, Nothing}}(nothing)
const bpath = tempname()

if isfile(joinpath(@__DIR__, "..", "deps", "deps.jl"))
  include(joinpath(@__DIR__, "..", "deps", "deps.jl"))
else
  @error("Bash scripts not properly installed. Please run Pkg.build(\"LinuxMonitorTools\")")
end

function __init__()
  @require Makie="ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a" include("visualization.jl")
end

function start_process(; pid = getpid(), name = "linuxmonitortools")::Bool
  if is_running()
    @error "process already started; kill it first"
    return false
  end
  # create a temp directory if it doesn't exist
  !isdir(bpath) && mkdir(bpath)
  
  # start the process
  @info "starting monitoring process"
  proc[] = open(pipeline(`$(execpath) $(pid) $(name) $(bpath)`))
  mpid[] = pid
  mname[] = name
  add_timemark( "process started" )

  return true

end

function add_timemark(str::String)::Bool
  if !is_running()
    @error "process not started; start it first"
    return false
  end
  # send a time mark
  @debug "sending time mark"
  open(joinpath( bpath, "$(mname[])_$(mpid[])_timemarks.csv" ), "a") do io
    write(io, Dates.format(now(), "yyyy-mm-dd HH:MM:SS.s") * "," * str * "\n")
  end
  return true
end

function kill_process()
  # kill the process
  if is_running()
    @info "killing monitoring process"
    Base.kill(proc[])
    add_timemark( "process killed" )
    proc[] = nothing
  else
    @warn "process already killed or not started"
  end
end

function cleanup!()
  # kill the process
  kill_process()
  @info "cleaning temporary directory"
  rm(bpath, recursive = true)
end

function is_running()::Bool
  return proc[] !== nothing
end

function parse_datafiles()

  dfmt = dateformat"yyyy-mm-dd HH:MM:SS.s"
  
  # parse the data files
  cpu      = joinpath( bpath, "$(mname[])_$(mpid[])_cpu.csv" )
  mem_rss  = joinpath( bpath, "$(mname[])_$(mpid[])_memrss.csv" )
  time_mrk = joinpath( bpath, "$(mname[])_$(mpid[])_timemarks.csv" )
  
  cpu = CSV.read(cpu, DataFrame; dateformat=dfmt, header = [:timestamp, :cpu] )
  mem_rss = CSV.read(mem_rss, DataFrame; dateformat=dfmt, header = [:timestamp, :mem] )
  time_mrk = CSV.read(time_mrk, DataFrame; dateformat=dfmt, header = [:timestamp, :mark] )

  df = outerjoin( cpu, mem_rss, time_mrk, on = :timestamp )

  sort!( df, [:timestamp] )

end


end
