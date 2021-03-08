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
  earth_years_per_year::Float64
  offset::Float64
end

# ╔═╡ acdd3c10-7f9e-11eb-15a1-fd2ee4f552c4
function abs_pos(dist_to_sun, phase)
  phase_2pi = phase * 2pi
  y, x = dist_to_sun .* sincos(phase_2pi)
  return Point3{Float64}(x,y, 0)
end

# ╔═╡ be4e263a-7f9e-11eb-3ac1-e791d0b6f87e
abs_pos(body::Body) = abs_pos(body.dist_to_sun, body.phase)

# ╔═╡ 9d3fa7c2-7fa8-11eb-1cdc-517777362a3a
mercury = Body(2439.7,0.1,69.059e6, 0.241,0)

# ╔═╡ bcabefb0-7fa8-11eb-220b-4fed094e221f
venus = Body(6051.8, 0.2, 108.87e6, 0.615, 0)

# ╔═╡ 9237e558-7f9f-11eb-3fd2-9be5c7ebf90d
mars = Body(3389.4, 0.4, 239.41e6,1.88,0)

# ╔═╡ 0d880270-7fa9-11eb-297a-3b2ce952fa33
jupiter = Body(69911, 0.5, 759.5e6, 11.86,0)

# ╔═╡ 1c507e92-7fa9-11eb-393a-65742f2b78ab
saturn = Body(58232, 0.6,1.4897e9,29.5,0)

# ╔═╡ 1deca260-7fa9-11eb-33a5-85ce58f5628a
uranus = Body(25362, 0.7,2.9562e9, 84,0)

# ╔═╡ 1ed1ab30-7fa9-11eb-0f92-f7935e71b1b3
neptune = Body(24622, 0.8, 4.4757e9,164.8,0)

# ╔═╡ 1f7e17ce-7fa9-11eb-3a45-7d411128e0ed
pluto = Body(1188.3, 0.9, 5.9e9,248,0)

# ╔═╡ 924bbaa0-7fa5-11eb-3396-1972470784d5
sun = Body(6963.40, 0, 0,1,0)

# ╔═╡ 0013cbb0-7fa9-11eb-0bdb-4f172162bf7b


# ╔═╡ 934005b0-7fa5-11eb-2bd9-19b44bfb001f
abs_pos(mars)

# ╔═╡ c3ca09d8-7fa0-11eb-17f8-cf753ad27443
bodies = [sun, mercury, venus, mars, jupiter, saturn, uranus, neptune, pluto]

# ╔═╡ be0c46f0-7fad-11eb-1bae-7d99544cc38c
#bodies = [sun, earth, jupiter]

# ╔═╡ 6e8f3936-7fad-11eb-0d65-07026d17bfff
@bind earth_years PlutoUI.Slider(1:365) 

# ╔═╡ 8effea2c-7f9d-11eb-0434-99749285b842
earth = Body(6.36e3, earth_years/365, 148.41e6,1,0)

# ╔═╡ a1cf8518-7fa2-11eb-1783-df1ff91cda12
md"Example"

# ╔═╡ dc655d7e-7fb9-11eb-2b64-eda9e336b6cf
import Pkg; Pkg.add("Observables")

# ╔═╡ 91a21d94-7faf-11eb-152e-27a5d44edf9f
# App() do session::Session
#     index_slider = JSServe.Slider(0:5:365)
# 	earth_days = Node(0)
# 	scene = Scene()
# 	function body_at_time(body, t)
# 		body_ = Body(body.radius, t / 365 /body.earth_years_per_year + body.offset, body.dist_to_sun, body.earth_years_per_year, body.offset)
# 	end
# 	for (i,body) in enumerate(bodies)
# 		body_ = @lift body_at_time(body, $earth_days)
# 		s = @lift Sphere(abs_pos($body_), body.radius*2000)
# 		mesh!(scene, s, color=RGBf0(i/10, 0.7, 0.3))
# 	end

# 	# set camera
# 	earth_ = @lift body_at_time(earth, $earth_days)
# 	eyeposition = @lift (abs_pos($earth_) .+ [1.1*earth.radius,0,0]); 
# 	jupiter_ = @lift body_at_time(jupiter, $earth_days);
# 	lookat = @lift abs_pos($jupiter_); 
# 	upvector = [0.0, 0.0, 1.0]; 
# 	#update_cam!(scene, eyeposition, [0.0, 0.0, 0.0], upvector)
# 	@lift update_cam!(scene, $eyeposition, $lookat);#, upvector)
#         # stop scene display from centering, which would overwrite the camera paramter we just set
# 	scene.center = false
# 	scene
	
# 	on(index_slider) do idx
# 		ey = idx/365
# 		@show eyeposition[]
# 		@show lookat[]
# 		earth_days[] = idx
# 	end
# 	slider = DOM.div("z-index: ", index_slider, index_slider.value)
#     return JSServe.record_states(session, DOM.div(slider, scene))
# end

# ╔═╡ 90974550-7fd0-11eb-081a-6b1ac49e8d6c
function body_at_time(body, t)
		body_ = Body(body.radius/1e6, t / 365 /body.earth_years_per_year + body.offset, body.dist_to_sun/1e6, body.earth_years_per_year, body.offset)
end

# ╔═╡ 748f0ff0-7fd0-11eb-373b-a938bdb0b34c
@bind earth_days PlutoUI.Slider(0:400)

# ╔═╡ 96a2f21c-7fa0-11eb-3ae8-8563b736b30e
function plot_solar_system(bodies)
   scene = Scene();
	for (i,body) in enumerate(bodies)
		body_ = body_at_time(body, earth_days)
		s = Sphere(abs_pos(body_), body_.radius*2000)
		mesh!(scene, s, color=RGBf0(i/length(bodies), 0.7, 0.3))
	end
	scene
end

# ╔═╡ 642873f2-7fa2-11eb-0756-55cbf93d273d
plot_solar_system(bodies)

# ╔═╡ a0e57710-7fd0-11eb-0b93-5f7ca5ee8824
begin
	scene = Scene();
	for (i,body) in enumerate(bodies)
		body_ = body_at_time(body, earth_days)
		s = Sphere(abs_pos(body_), body_.radius*2000)
		mesh!(scene, s, color=RGBf0(i/length(bodies), 0.7, 0.3))
	end
	cam = cameracontrols(scene);

	# set camera
	earth_ = body_at_time(earth, earth_days)
	cam.eyeposition[] = (abs_pos(earth_) .+ [0000*earth_.radius,1*earth_.radius,0000*earth_.radius]); 

	jupiter_ = body_at_time(jupiter, earth_days);
	cam.lookat[] = abs_pos(jupiter_); 
	upvector = [0.0, 0.0, 1.0]; 
	#update_cam!(scene, eyeposition, [0.0, 0.0, 0.0], upvector)
	update_cam!(scene, cam);#, upvector)
        # stop scene display from centering, which would overwrite the camera paramter we just set
	@show abs_pos(earth_)
	cam = cameracontrols(scene);
	@show cam.eyeposition
	scene.center = false
	scene
end

# ╔═╡ 6f5a5c10-7fd0-11eb-1c69-eda6306bb53b


# ╔═╡ 64904030-7fb5-11eb-1633-cf965f8bb5ac
cam = cameracontrols(scene)
cam.upvector[] = (0.0, 0.0, 1.0)
cam.lookat[] = minimum(scene_limits(scene)) + dir_scaled
cam.eyeposition[] = (cam.lookat[][1], cam.lookat[][2] + 6.3, cam.lookat[][3])
cam.projectiontype[] = AbstractPlotting.Orthographic
        update_cam!(scene, cam)
        # stop scene display from centering, which would overwrite the camera paramter we just set
        scene.center = false

# ╔═╡ c5ef5690-7fbf-11eb-156b-f30ec4c5200e
AbstractPlotting

# ╔═╡ cd3da630-7fc0-11eb-27a6-294fdd05674c


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
# ╠═89c59ea0-7faf-11eb-294c-41e589b29f49
# ╠═dc655d7e-7fb9-11eb-2b64-eda9e336b6cf
# ╠═91a21d94-7faf-11eb-152e-27a5d44edf9f
# ╠═90974550-7fd0-11eb-081a-6b1ac49e8d6c
# ╠═748f0ff0-7fd0-11eb-373b-a938bdb0b34c
# ╠═a0e57710-7fd0-11eb-0b93-5f7ca5ee8824
# ╠═6f5a5c10-7fd0-11eb-1c69-eda6306bb53b
# ╠═64904030-7fb5-11eb-1633-cf965f8bb5ac
# ╠═c5ef5690-7fbf-11eb-156b-f30ec4c5200e
# ╠═cd3da630-7fc0-11eb-27a6-294fdd05674c
