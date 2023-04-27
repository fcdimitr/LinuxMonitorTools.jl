using .Makie

struct TimeTicks end

function Makie.get_ticks(::TimeTicks, any_scale, ::Makie.Automatic, vmin, vmax)
  if vmax >= 3600
      # divide limits by 3600 before finding standard ticks
      vals_h = Makie.get_tickvalues(
          Makie.automatic, any_scale, vmin/3600, vmax/3600)
      labels = string.(vals_h, "h")
      # rescale tick values to seconds
      vals_s = vals_h .* 3600
  elseif vmax >= 120
      vals_min = Makie.get_tickvalues(
          Makie.automatic, any_scale, vmin/60, vmax/60)
      labels = string.(vals_min, "min")
      vals_s = vals_min .* 60
  else
      vals_s = Makie.get_tickvalues(
          Makie.automatic, any_scale, vmin, vmax)
      labels = string.(vals_s, "s")
  end
  vals_s, labels
end

function plot_datafiles(df::DataFrame; gaps = false, showonly = nothing, 
  show_startstop = false, show_sep = true)

  t_sec = (Dates.value.(df.timestamp .- df.timestamp[1]) / 1000)

  f = Figure()
  ax1, ax2 = nothing, nothing
  if showonly == :mem
    ax1 = Axis(f[1, 1], yticklabelcolor = :black, ytickformat = "{:d} MB",
      xlabel = "time", ylabel = "RAM", xticks = TimeTicks() )
    ax2 = ax1
    texty = minimum(skipmissing(df.mem)) ./ 1000
  elseif showonly == :cpu
    ax1 = Axis(f[1, 1], yticklabelcolor = :black, ytickformat = "{:d}%",
      xlabel = "time", ylabel = "CPU usage", xticks = TimeTicks() )
    ax2 = ax1
    texty = minimum(skipmissing(df.cpu))
  else
    ax1 = Axis(f[1, 1], yticklabelcolor = :black, ytickformat = "{:d}%",
                xlabel = "time", ylabel = "CPU usage", xticks = TimeTicks() )
    ax2 = Axis(f[1, 1], yticklabelcolor = :blue, yaxisposition = :right,
                ytickformat = "{:d} MB", ylabel = "RAM", ylabelcolor = :blue )
    hidespines!(ax2)
    hidexdecorations!(ax2)
    texty = minimum(skipmissing(df.cpu))
  end

  idx_cpu = gaps ? axes(df.cpu, 1) : .!ismissing.(df.cpu)
  idx_mem = gaps ? axes(df.mem, 1) : .!ismissing.(df.mem)

  if showonly == :mem
    scatterlines!( ax1, t_sec[idx_mem], df.mem[idx_mem] ./ 1000, color = :black, label = "Memory", markersize = 6 )
  elseif showonly == :cpu
    scatterlines!( ax1, t_sec[idx_cpu], df.cpu[idx_cpu], color = :black, label = "CPU", markersize = 6 )
  else
    scatterlines!( ax1, t_sec[idx_cpu], df.cpu[idx_cpu], color = :black, label = "CPU", markersize = 6 )
    scatterlines!( ax2, t_sec[idx_mem], df.mem[idx_mem] ./ 1000, color = :blue, label = "Memory", markersize = 6 )
  end
  idx_sep = .!ismissing.(df.mark) .&& df.mark .!= "process killed" .&& df.mark .!= "process started"

  idx_beg = .!ismissing.(df.mark) .&& df.mark .== "process started"
  idx_end = .!ismissing.(df.mark) .&& df.mark .== "process killed"

  if show_sep

    vlines!( ax2, t_sec[ idx_sep ], color = :red, linestyle = :dot, linewidth = 2 )

    for i in findall( idx_sep )
      text!( ax1, t_sec[i], texty; offset = (0, -20), text = String(df.mark[i]), halign = :left, valign = :bottom, rotation = pi/2, color = :red )
    end

  end
  
  if show_startstop

    vlines!( ax1, t_sec[ idx_beg ], color = :green , linewidth = 4, linestyle = :dot)
    vlines!( ax1, t_sec[ idx_end ], color = :orange, linewidth = 4, linestyle = :dot)
  
    for i in findall( idx_beg )
      text!( ax1, t_sec[i], texty; offset = (0, -20), text = String(df.mark[i]), halign = :left, valign = :bottom, rotation = pi/2, color = :green )
    end

    for i in findall( idx_end )
      text!( ax1, t_sec[i], texty; offset = (0, -20), text = String(df.mark[i]), align = (:right, :bottom), rotation = -pi/2, color = :orange )
    end

  end

  f

end
