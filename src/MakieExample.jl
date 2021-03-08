### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ de698868-7f9b-11eb-16af-031849e1f8ac
using Revise

# ╔═╡ e6714650-7f95-11eb-131f-59c3d5f1919f
using WGLMakie, AbstractPlotting, Colors, FileIO

# ╔═╡ d8e66710-7fa2-11eb-108a-9b4940798246
begin
	using JSServe
	Page(exportable=true, offline=true)
end 

# ╔═╡ 57856634-7fad-11eb-3036-4d6a958e57a4
using PlutoUI

# ╔═╡ 89c59ea0-7faf-11eb-294c-41e589b29f49
using Observables

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

# ╔═╡ 9d3fa7c2-7fa8-11eb-1cdc-517777362a3a
mercury = Body(2439.7,0.1,69.059e6)

# ╔═╡ bcabefb0-7fa8-11eb-220b-4fed094e221f
venus = Body(6051.8, 0.2, 108.87e6)

# ╔═╡ 9237e558-7f9f-11eb-3fd2-9be5c7ebf90d
mars = Body(3389.4, 0.4, 239.41e6)

# ╔═╡ 0d880270-7fa9-11eb-297a-3b2ce952fa33
jupiter = Body(69911, 0.5, 759.5e6)

# ╔═╡ 1c507e92-7fa9-11eb-393a-65742f2b78ab
saturn = Body(58232, 0.6,1.4897e9 )

# ╔═╡ 1deca260-7fa9-11eb-33a5-85ce58f5628a
uranus = Body(25362, 0.7,2.9562e9 )

# ╔═╡ 1ed1ab30-7fa9-11eb-0f92-f7935e71b1b3
neptune = Body(24622, 0.8, 4.4757e9)

# ╔═╡ 1f7e17ce-7fa9-11eb-3a45-7d411128e0ed
pluto = Body(1188.3, 0.9, 5.9e9)

# ╔═╡ 924bbaa0-7fa5-11eb-3396-1972470784d5
sun = Body(6963.40, 0, 0)

# ╔═╡ 0013cbb0-7fa9-11eb-0bdb-4f172162bf7b


# ╔═╡ 934005b0-7fa5-11eb-2bd9-19b44bfb001f
abs_pos(mars)

# ╔═╡ 96a2f21c-7fa0-11eb-3ae8-8563b736b30e
function plot_solar_system(bodies)
   scene = Scene();
   for body in bodies
		(x, y) = abs_pos(body)
		s = Sphere(Point3f0(x, y, 0), body.radius*1000)
		mesh!(scene, s, color=RGBf0(1, 0.7, 0.3))
	end
	scene
end

# ╔═╡ be0c46f0-7fad-11eb-1bae-7d99544cc38c
# bodies = [sun, earth, venus]

# ╔═╡ 6e8f3936-7fad-11eb-0d65-07026d17bfff
@bind earth_years PlutoUI.Slider(1:365) 

# ╔═╡ 8effea2c-7f9d-11eb-0434-99749285b842
earth = Body(6.36e3, earth_years/365, 148.41e6)

# ╔═╡ c3ca09d8-7fa0-11eb-17f8-cf753ad27443
bodies = [sun, mercury, venus, earth, mars, jupiter, saturn, uranus, neptune, pluto]

# ╔═╡ 642873f2-7fa2-11eb-0756-55cbf93d273d
plot_solar_system(bodies)

# ╔═╡ a1cf8518-7fa2-11eb-1783-df1ff91cda12
md"Example"

# ╔═╡ 958f8590-7fad-11eb-1bdb-5f014b47fed4


# ╔═╡ ddd21fd8-7fae-11eb-17b1-29c5619a38b7
begin
	hue_slider = JSServe.Slider(LinRange(1, 360, 100))
	color = map(hue_slider) do hue
		HSV(hue, 0.5, 0.5)
	end
	JSServe.with_session() do s, r
		return DOM.div(hue_slider, color)
	end
end

# ╔═╡ 91a21d94-7faf-11eb-152e-27a5d44edf9f
App() do session::Session
    index_slider = JSServe.Slider(1:365)
    # fig = Figure()
    # ax, cplot = contour(fig[1, 1], volume)
    # heatmap(fig[1, 2], slice)
	earth_years = Node(100)
	#xbodies = @lift 
	# scene = @lift plot_solar_system([sun, Body(6.36e3, $earth_years/365, 148.41e6)])
	scene = Scene()
	for body in bodies
		@show "hi"
		body_ = @lift Body(body.radius, $earth_years / 365, body.dist_to_sun)
		@show "hii"
		#(x, y) = @lift abs_pos($body_)
		phase_2pi = @lift $body_.phase * 2pi
        yx = @lift $body_.dist_to_sun .* sincos($phase_2pi)

		@show "hiii"
		s = @lift Sphere(Point3f0($yx[2], $yx[1], 0), body.radius*1000)
		@show "hiiii"
		mesh!(scene, s, color=RGBf0(1, 0.7, 0.3))
	end
	# scene
	# x = 1.5
	# y = 5.8
	# xy = [x y]
	# res = scatter!(scene, xy)
	on(index_slider) do idx
		ey = idx/365
		@show idx
		earth_years[] = idx
		# xbodies[1].phase = ey
		# x_ = ey
		# y_ = ey
		# translate!(res, idx, idx, idx)
		# xy .= [x_ y_]
	end
	slider = DOM.div("z-index: ", index_slider, index_slider.value)
    return JSServe.record_states(session, DOM.div(slider, scene))
end

# ╔═╡ 64904030-7fb5-11eb-1633-cf965f8bb5ac


# ╔═╡ Cell order:
# ╠═de698868-7f9b-11eb-16af-031849e1f8ac
# ╠═e6714650-7f95-11eb-131f-59c3d5f1919f
# ╠═c61b7d78-7fa2-11eb-3317-27c52adcacd6
# ╠═d8e66710-7fa2-11eb-108a-9b4940798246
# ╠═dfc383ca-7f9c-11eb-1cae-85de56d9cfb3
# ╠═e9f7f20e-7f9c-11eb-3ab2-37fa0ecc4d97
# ╠═a3bcff66-7f9d-11eb-3264-91ba931fd331
# ╠═4aa60eb0-7f9d-11eb-24c7-bd6a81c79b66
# ╠═acdd3c10-7f9e-11eb-15a1-fd2ee4f552c4
# ╠═be4e263a-7f9e-11eb-3ac1-e791d0b6f87e
# ╠═9d3fa7c2-7fa8-11eb-1cdc-517777362a3a
# ╠═bcabefb0-7fa8-11eb-220b-4fed094e221f
# ╠═8effea2c-7f9d-11eb-0434-99749285b842
# ╠═9237e558-7f9f-11eb-3fd2-9be5c7ebf90d
# ╠═0d880270-7fa9-11eb-297a-3b2ce952fa33
# ╠═1c507e92-7fa9-11eb-393a-65742f2b78ab
# ╠═1deca260-7fa9-11eb-33a5-85ce58f5628a
# ╠═1ed1ab30-7fa9-11eb-0f92-f7935e71b1b3
# ╠═1f7e17ce-7fa9-11eb-3a45-7d411128e0ed
# ╠═924bbaa0-7fa5-11eb-3396-1972470784d5
# ╠═0013cbb0-7fa9-11eb-0bdb-4f172162bf7b
# ╠═934005b0-7fa5-11eb-2bd9-19b44bfb001f
# ╠═96a2f21c-7fa0-11eb-3ae8-8563b736b30e
# ╠═c3ca09d8-7fa0-11eb-17f8-cf753ad27443
# ╠═be0c46f0-7fad-11eb-1bae-7d99544cc38c
# ╠═642873f2-7fa2-11eb-0756-55cbf93d273d
# ╠═57856634-7fad-11eb-3036-4d6a958e57a4
# ╠═6e8f3936-7fad-11eb-0d65-07026d17bfff
# ╠═a1cf8518-7fa2-11eb-1783-df1ff91cda12
# ╠═958f8590-7fad-11eb-1bdb-5f014b47fed4
# ╠═ddd21fd8-7fae-11eb-17b1-29c5619a38b7
# ╠═89c59ea0-7faf-11eb-294c-41e589b29f49
# ╠═91a21d94-7faf-11eb-152e-27a5d44edf9f
# ╠═64904030-7fb5-11eb-1633-cf965f8bb5ac
