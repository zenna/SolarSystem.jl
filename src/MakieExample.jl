### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ de698868-7f9b-11eb-16af-031849e1f8ac
using Revise

# ╔═╡ e6714650-7f95-11eb-131f-59c3d5f1919f
using GLMakie, AbstractPlotting, Colors, FileIO

# ╔═╡ d8e66710-7fa2-11eb-108a-9b4940798246
begin
	using JSServe
	Page(exportable=true, offline=true)
end 

# ╔═╡ 03c41ab0-7f9e-11eb-2b3e-435a5db42212
using UnitfulAstro

# ╔═╡ c61b7d78-7fa2-11eb-3317-27c52adcacd6


# ╔═╡ dfc383ca-7f9c-11eb-1cae-85de56d9cfb3
md"# A Newtonion Universe"

# ╔═╡ e9f7f20e-7f9c-11eb-3ab2-37fa0ecc4d97
Position = Point3f0

# ╔═╡ a3bcff66-7f9d-11eb-3264-91ba931fd331
Vec2

# ╔═╡ 4aa60eb0-7f9d-11eb-24c7-bd6a81c79b66
struct Body
  radius::Float64
  phase::Float64
  dist_to_sun::Float64
end

# ╔═╡ acdd3c10-7f9e-11eb-15a1-fd2ee4f552c4
function abs_pos(dist_to_sun, phase)
  phase_2pi = phase * 2pi
  y, x = dist_to_sun .* sincos(phase_2pi)
  return (x, y)
end

# ╔═╡ be4e263a-7f9e-11eb-3ac1-e791d0b6f87e
abs_pos(body::Body) = abs_pos(body.dist_to_sun, body.phase)

# ╔═╡ 8effea2c-7f9d-11eb-0434-99749285b842
earth = Body(6.36e3, 0.2, 148.41e6)

# ╔═╡ 9237e558-7f9f-11eb-3fd2-9be5c7ebf90d
mars = Body(3389.4, 0.6, 239.41e6)

# ╔═╡ 1b395122-7fa3-11eb-23bb-cf9a29cd27d2
scene = Scene()

# ╔═╡ 96a2f21c-7fa0-11eb-3ae8-8563b736b30e
function plot_solar_system(bodies, scene = Scene())
   for body in bodies
		(x, y) = abs_pos(body)
		s = Sphere(Point3f0(x, y, 0), body.radius*100)
		@show body
		println("")
		scene = mesh!(scene, s, color=RGBf0(1, 0.7, 0.3))
	end
	scene
end

# ╔═╡ c3ca09d8-7fa0-11eb-17f8-cf753ad27443
bodies = [mars, earth]

# ╔═╡ 642873f2-7fa2-11eb-0756-55cbf93d273d
mesh = plot_solar_system(bodies, scene)

# ╔═╡ 7ddc0ba6-7fa2-11eb-1133-c91b4245a1eb
scene

# ╔═╡ a1cf8518-7fa2-11eb-1783-df1ff91cda12
md"Example"

# ╔═╡ Cell order:
# ╠═de698868-7f9b-11eb-16af-031849e1f8ac
# ╠═e6714650-7f95-11eb-131f-59c3d5f1919f
# ╠═c61b7d78-7fa2-11eb-3317-27c52adcacd6
# ╠═d8e66710-7fa2-11eb-108a-9b4940798246
# ╠═03c41ab0-7f9e-11eb-2b3e-435a5db42212
# ╠═dfc383ca-7f9c-11eb-1cae-85de56d9cfb3
# ╠═e9f7f20e-7f9c-11eb-3ab2-37fa0ecc4d97
# ╠═a3bcff66-7f9d-11eb-3264-91ba931fd331
# ╠═4aa60eb0-7f9d-11eb-24c7-bd6a81c79b66
# ╠═acdd3c10-7f9e-11eb-15a1-fd2ee4f552c4
# ╠═be4e263a-7f9e-11eb-3ac1-e791d0b6f87e
# ╠═8effea2c-7f9d-11eb-0434-99749285b842
# ╠═9237e558-7f9f-11eb-3fd2-9be5c7ebf90d
# ╠═1b395122-7fa3-11eb-23bb-cf9a29cd27d2
# ╠═96a2f21c-7fa0-11eb-3ae8-8563b736b30e
# ╠═c3ca09d8-7fa0-11eb-17f8-cf753ad27443
# ╠═642873f2-7fa2-11eb-0756-55cbf93d273d
# ╠═7ddc0ba6-7fa2-11eb-1133-c91b4245a1eb
# ╠═a1cf8518-7fa2-11eb-1783-df1ff91cda12
