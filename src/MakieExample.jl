### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ e6714650-7f95-11eb-131f-59c3d5f1919f
using GLMakie, AbstractPlotting, Colors, FileIO

# ╔═╡ 5b3f6550-7f98-11eb-064d-fb19e99a1ea9
begin
	using JSServe
	Page(exportable=true, offline=true)
end

# ╔═╡ 900e00a0-7f9a-11eb-24ee-1d161eec7d24
import Pkg; Pkg.add("FileIO")

# ╔═╡ 82d461e0-7f9a-11eb-026b-73f04fa3074d
catmesh = FileIO.load(GLMakie.assetpath("cat.obj"))

# ╔═╡ 8782a7b0-7f9a-11eb-0395-d59bc1a19187
gold = FileIO.load(download("https://raw.githubusercontent.com/nidorx/matcaps/master/1024/E6BF3C_5A4719_977726_FCFC82.png"))

# ╔═╡ 8782f5d0-7f9a-11eb-1fc5-c78f4f32650d
mesh(catmesh, matcap=gold, shading=false)

# ╔═╡ 4db8cd20-7f9a-11eb-21d2-f91970955fb9
GLMakie.enable_SSAO[] = true

# ╔═╡ b4e7d1a0-7f98-11eb-167c-49f9786f6d56
N = 60

# ╔═╡ 03baf500-7f99-11eb-2c5f-051c7cb1d6bd
function xy_data(x, y)
    r = sqrt(x^2 + y^2)
    r == 0.0 ? 1f0 : (sin(r)/r)
end

# ╔═╡ 03bb4322-7f99-11eb-044b-dd69e68ab1b1
l = range(-10, stop = 10, length = N)

# ╔═╡ 03bbb850-7f99-11eb-3407-812291e20300
z = Float32[xy_data(x, y) for x in l, y in l]

# ╔═╡ 03c46ae0-7f99-11eb-1e1b-07a8e974a677
surface(
    -1..1, -1..1, z,
    colormap = :Spectral
)

# ╔═╡ 618a75c0-7f99-11eb-152d-b9425d936d94
# Alternatively:
# fig = Figure()
# scene = LScene(fig[1, 1], scenekw = (SSAO = (radius = 5.0, blur = 3), show_axis=false, camera=cam3d!))
# scene.scene[:SSAO][:bias][] = 0.025

scene = Scene(show_axis = false)

# ╔═╡ 618fccee-7f99-11eb-3a5a-099361bc502a
# SSAO attributes are per scene
scene[:SSAO][:radius][] = 5.0

# ╔═╡ 6197e340-7f99-11eb-2d50-4f4830647f10
scene[:SSAO][:blur][] = 3

# ╔═╡ 619fab70-7f99-11eb-20ba-a18c27145101
scene[:SSAO][:bias][] = 0.025

# ╔═╡ 61a79ab0-7f99-11eb-0384-855140c82865
box = Rect3D(Point3f0(-0.5), Vec3f0(1))

# ╔═╡ 61b0c270-7f99-11eb-3be1-b7cdf8819f78
positions = [Point3f0(x, y, rand()) for x in -5:5 for y in -5:5]

# ╔═╡ 61b9c320-7f99-11eb-0ab4-810f4d4ba951
meshscatter!(scene, positions, marker=box, markersize=1, color=:lightblue, ssao=true)

# ╔═╡ 61c2eae0-7f99-11eb-20d5-5d9d94a6bbe2
scene

# ╔═╡ Cell order:
# ╠═e6714650-7f95-11eb-131f-59c3d5f1919f
# ╠═900e00a0-7f9a-11eb-24ee-1d161eec7d24
# ╠═5b3f6550-7f98-11eb-064d-fb19e99a1ea9
# ╠═82d461e0-7f9a-11eb-026b-73f04fa3074d
# ╠═8782a7b0-7f9a-11eb-0395-d59bc1a19187
# ╠═8782f5d0-7f9a-11eb-1fc5-c78f4f32650d
# ╠═4db8cd20-7f9a-11eb-21d2-f91970955fb9
# ╠═b4e7d1a0-7f98-11eb-167c-49f9786f6d56
# ╠═03baf500-7f99-11eb-2c5f-051c7cb1d6bd
# ╠═03bb4322-7f99-11eb-044b-dd69e68ab1b1
# ╠═03bbb850-7f99-11eb-3407-812291e20300
# ╠═03c46ae0-7f99-11eb-1e1b-07a8e974a677
# ╠═618a75c0-7f99-11eb-152d-b9425d936d94
# ╠═618fccee-7f99-11eb-3a5a-099361bc502a
# ╠═6197e340-7f99-11eb-2d50-4f4830647f10
# ╠═619fab70-7f99-11eb-20ba-a18c27145101
# ╠═61a79ab0-7f99-11eb-0384-855140c82865
# ╠═61b0c270-7f99-11eb-3be1-b7cdf8819f78
# ╠═61b9c320-7f99-11eb-0ab4-810f4d4ba951
# ╠═61c2eae0-7f99-11eb-20d5-5d9d94a6bbe2
