using LinuxMonitorTools
using Test

@testset "LinuxMonitorTools.jl" begin
    @test !isempty( LinuxMonitorTools.execpath )
end
