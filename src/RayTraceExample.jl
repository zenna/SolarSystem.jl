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

# ╔═╡ 3cb3a910-841c-11eb-3e4b-e131de172393
using RayTrace

# ╔═╡ c0cda830-8422-11eb-057e-dfe59b6dc3e7
using Images

# ╔═╡ 385e2d70-8423-11eb-0260-31ee43d28996
using RayTrace: Sphere, Vec3, FancySphere

# ╔═╡ 41bd7830-8423-11eb-3484-97b9917ad76f
using Colors

# ╔═╡ 41bded60-8423-11eb-17e4-8bb3e0f75bc2
using ImageView

# ╔═╡ af6a7fd0-8429-11eb-1fd9-c17aeb584666
using Rotations

# ╔═╡ 3b2f98c2-842a-11eb-0dce-17cbba9c7a95
using LinearAlgebra

# ╔═╡ 57856634-7fad-11eb-3036-4d6a958e57a4
using PlutoUI

# ╔═╡ 89c59ea0-7faf-11eb-294c-41e589b29f49
using Observables

# ╔═╡ 19d27d50-842a-11eb-02a4-0b8c337361bb
cross([3, 3, 4], [1, 1, 6])

# ╔═╡ 98109ad0-842a-11eb-0d89-b332dfd48be6
[1. 0 0] *Rotations.AngleAxis(pi/4,0,0,1.)

# ╔═╡ dfc383ca-7f9c-11eb-1cae-85de56d9cfb3
md"# A Newtonion Universe"

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

# ╔═╡ 934005b0-7fa5-11eb-2bd9-19b44bfb001f
abs_pos(mars)

# ╔═╡ 2ae53030-842d-11eb-3d6e-8b9a3e595b73
[3, 3, 4.].-[1., 1, 6]

# ╔═╡ 42377ea2-842d-11eb-1eca-8980f8a0ff0a
dot([3, 3, 4.],[1., 1, 6])

# ╔═╡ ceac869e-842d-11eb-0e88-a3566bd1f4c1
normalize(x) = x./sum(x)

# ╔═╡ 53bf77a0-8427-11eb-0f30-c923d76cd874
function reorient(old_position, new_orientation, new_origin)
	new_position = old_position.-new_origin; 
	theta = acos(dot(normalize([0,0,-1.]), normalize(new_orientation))); 
	axis = cross([0,0,-1.], new_orientation);
	if theta !=0
		new_position = new_position'*Rotations.AngleAxis(-theta,axis[1], axis[2], axis[3])
	end
	new_position
end

# ╔═╡ 8914eed0-842c-11eb-328c-1b5c7f34e884
reorient([0,0,-1.], [0,1.,0], [-1., 0, 0])

# ╔═╡ a0988aa0-8425-11eb-3c2d-2306e2c20348


# ╔═╡ be0c46f0-7fad-11eb-1bae-7d99544cc38c
#bodies = [sun, earth, jupiter]

# ╔═╡ 6e8f3936-7fad-11eb-0d65-07026d17bfff
@bind earth_years PlutoUI.Slider(1:365) 

# ╔═╡ 8effea2c-7f9d-11eb-0434-99749285b842
earth = Body(6.36e3, earth_years/365, 148.41e6,1,0)

# ╔═╡ c3ca09d8-7fa0-11eb-17f8-cf753ad27443
bodies = [sun, mercury, venus, earth, mars, jupiter, saturn, uranus, neptune, pluto]

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


# ╔═╡ cd3da630-7fc0-11eb-27a6-294fdd05674c
"Some example spheres which should create actual image"
function example_spheres()
  scene = [FancySphere(Float64[0.0, -10004, -20], 10000.0, Float64[0.20, 0.20, 0.20], 0.0, 0.0, Float64[0.0, 0.0, 0.0]),
           FancySphere(Float64[0.0,      0, -20],     4.0, Float64[1.00, 0.32, 0.36], 1.0, 0.5, Float64[0.0, 0.0, 0.0]),
           FancySphere(Float64[5.0,     -1, -15],     2.0, Float64[0.90, 0.76, 0.46], 1.0, 0.0, Float64[0.0, 0.0, 0.0]),
           FancySphere(Float64[5.0,      0, -25],     3.0, Float64[0.65, 0.77, 0.97], 1.0, 0.0, Float64[0.0, 0.0, 0.0]),
           FancySphere(Float64[-5.5,      0, -15],    3.0, Float64[0.90, 0.90, 0.90], 1.0, 0.0, Float64[0.0, 0.0, 0.0]),
           # light (emission > 0)
           FancySphere(Float64[0.0,     20.0, -30],  3.0, Float64[0.00, 0.00, 0.00], 0.0, 0.0, Float64[3.0, 3.0, 3.0])]
  RayTrace.ListScene(scene)
end

# ╔═╡ 662b2f00-8423-11eb-246e-637ae0019720
"Render an example scene and display it"
function render_example_spheres()
  scene = example_spheres()
  RayTrace.render(scene;width=1000,height=1000)
end

# ╔═╡ 662bcb40-8423-11eb-22c2-11bc9a628f37
"Create an rgb image from a 3D matrix (w, h, c)"
function rgbimg(img)
  w = size(img)[1]
  h = size(img)[2]
  clrimg = Array{Colors.RGB}(undef, w, h)
  for i = 1:w
    for j = 1:h
      clrimg[i,j] = Colors.RGB(img[i,j,:]...)
    end
  end
  clrimg
end

# ╔═╡ 96a2f21c-7fa0-11eb-3ae8-8563b736b30e
function plot_solar_system(bodies)
	scene = [FancySphere(Float64[0.0,     20.0, -30],  3.0, Float64[0.00, 0.00, 0.00], 0.0, 0.0, Float64[3.0, 3.0, 3.0])]
	for (i,body) in enumerate(bodies)
		scene = [scene; FancySphere(abs_pos(body), body.radius, Float64[0.20, 0.20, 0.20], 0.0, 0.0, Float64[0.0, 0.0, 0.0])]
	end
  rgbimg(RayTrace.render(RayTrace.ListScene(scene), width=1000,height=1000))
end

# ╔═╡ 0013cbb0-7fa9-11eb-0bdb-4f172162bf7b
plot_solar_system(bodies)

# ╔═╡ 642873f2-7fa2-11eb-0756-55cbf93d273d
plot_solar_system(bodies)

# ╔═╡ 6637d930-8423-11eb-2595-0357f562491c
function show_img()
  img_ = render_example_spheres()
  img = rgbimg(img_)
  ImageView.imshow(img)
end

# ╔═╡ 6435c7a0-8423-11eb-3598-e96296f2c8f3
rgbimg(render_example_spheres())

# ╔═╡ Cell order:
# ╠═de698868-7f9b-11eb-16af-031849e1f8ac
# ╠═3cb3a910-841c-11eb-3e4b-e131de172393
# ╠═c0cda830-8422-11eb-057e-dfe59b6dc3e7
# ╠═385e2d70-8423-11eb-0260-31ee43d28996
# ╠═41bd7830-8423-11eb-3484-97b9917ad76f
# ╠═41bded60-8423-11eb-17e4-8bb3e0f75bc2
# ╠═af6a7fd0-8429-11eb-1fd9-c17aeb584666
# ╠═3b2f98c2-842a-11eb-0dce-17cbba9c7a95
# ╠═19d27d50-842a-11eb-02a4-0b8c337361bb
# ╠═98109ad0-842a-11eb-0d89-b332dfd48be6
# ╟─dfc383ca-7f9c-11eb-1cae-85de56d9cfb3
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
# ╠═2ae53030-842d-11eb-3d6e-8b9a3e595b73
# ╠═42377ea2-842d-11eb-1eca-8980f8a0ff0a
# ╠═ceac869e-842d-11eb-0e88-a3566bd1f4c1
# ╠═53bf77a0-8427-11eb-0f30-c923d76cd874
# ╠═8914eed0-842c-11eb-328c-1b5c7f34e884
# ╠═96a2f21c-7fa0-11eb-3ae8-8563b736b30e
# ╠═c3ca09d8-7fa0-11eb-17f8-cf753ad27443
# ╠═a0988aa0-8425-11eb-3c2d-2306e2c20348
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
# ╠═cd3da630-7fc0-11eb-27a6-294fdd05674c
# ╠═662b2f00-8423-11eb-246e-637ae0019720
# ╠═662bcb40-8423-11eb-22c2-11bc9a628f37
# ╠═6637d930-8423-11eb-2595-0357f562491c
# ╠═6435c7a0-8423-11eb-3598-e96296f2c8f3
