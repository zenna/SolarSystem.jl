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

# ╔═╡ bcb1c440-8457-11eb-2e53-3582a44f6eb7
using GeometryBasics

# ╔═╡ a451cf00-845a-11eb-119b-430a1ff3c687
using UnicodePlots

# ╔═╡ 57856634-7fad-11eb-3036-4d6a958e57a4
using PlutoUI

# ╔═╡ dfc383ca-7f9c-11eb-1cae-85de56d9cfb3
md"# A Newtonion Universe"

# ╔═╡ 4aa60eb0-7f9d-11eb-24c7-bd6a81c79b66
struct Body
	radius::Float64
	phase::Float64
	dist_to_sun::Float64
	earth_years_per_year::Float64
	offset::Float64 # place holder, for not just input to body_at_time
	orbit_around::Point3{Float64}
end

# ╔═╡ acdd3c10-7f9e-11eb-15a1-fd2ee4f552c4
function abs_pos(dist_to_sun, phase, orbit_around)
  phase_2pi = phase * 2pi
  y, x = dist_to_sun .* sincos(phase_2pi)
  return Point3{Float64}(x,y, 0) .+ orbit_around
end

# ╔═╡ be4e263a-7f9e-11eb-3ac1-e791d0b6f87e
abs_pos(body::Body) = abs_pos(body.dist_to_sun, body.phase, body.orbit_around)

# ╔═╡ 924bbaa0-7fa5-11eb-3396-1972470784d5
sun = Body(696340, 0, 0,1,0, [0.,0.,0.])

# ╔═╡ 9d3fa7c2-7fa8-11eb-1cdc-517777362a3a
mercury = Body(2439.7,0.1,69.059e6, 0.241,0, abs_pos(sun))

# ╔═╡ bcabefb0-7fa8-11eb-220b-4fed094e221f
venus = Body(6051.8, 0.2, 108.87e6, 0.615, 0, abs_pos(sun))

# ╔═╡ 8effea2c-7f9d-11eb-0434-99749285b842
earth = Body(6.36e3, 0., 148.41e6,1,0, abs_pos(sun))

# ╔═╡ 36abaa90-8467-11eb-1301-fb7831fe8830
earth_moon = Body(1737.1, 0., 384400, 27.3/365, 0, abs_pos(earth))

# ╔═╡ 9237e558-7f9f-11eb-3fd2-9be5c7ebf90d
mars = Body(3389.4, 0.4, 239.41e6,1.88,0, abs_pos(sun))

# ╔═╡ 0d880270-7fa9-11eb-297a-3b2ce952fa33
jupiter = Body(69911, 0.5, 759.5e6, 11.86,0, abs_pos(sun))

# ╔═╡ 1c507e92-7fa9-11eb-393a-65742f2b78ab
saturn = Body(58232, 0.6,1.4897e9,29.5,0, abs_pos(sun))

# ╔═╡ 1deca260-7fa9-11eb-33a5-85ce58f5628a
uranus = Body(25362, 0.7,2.9562e9, 84,0, abs_pos(sun))

# ╔═╡ 1ed1ab30-7fa9-11eb-0f92-f7935e71b1b3
neptune = Body(24622, 0.8, 4.4757e9,164.8,0, abs_pos(sun))

# ╔═╡ 1f7e17ce-7fa9-11eb-3a45-7d411128e0ed
pluto = Body(1188.3, 0.9, 5.9e9,248,0, abs_pos(sun))

# ╔═╡ ceac869e-842d-11eb-0e88-a3566bd1f4c1
normalize(x) = x./sum(x)

# ╔═╡ 53bf77a0-8427-11eb-0f30-c923d76cd874
function reorient(old_position, new_orientation, new_origin)
	new_position = old_position.-new_origin; 
	old_orientation = [0,0,-1.];
	theta = acos(dot(normalize(old_orientation), normalize(new_orientation))); 
	axis = cross(old_orientation, new_orientation);
	if theta !=0
		new_position = new_position'*Rotations.AngleAxis(-theta,axis[1], axis[2], axis[3])
	end
	new_position
end

# ╔═╡ c3ca09d8-7fa0-11eb-17f8-cf753ad27443
bodies = [sun, mercury, venus, earth, mars, jupiter, saturn, uranus, neptune, pluto]

# ╔═╡ 748f0ff0-7fd0-11eb-373b-a938bdb0b34c
@bind earth_days PlutoUI.Slider(0:400)

# ╔═╡ 0a6e73f0-846b-11eb-2623-bdbbd52c7343
@bind moon_offset PlutoUI.Slider(0:.01:1)

# ╔═╡ 90974550-7fd0-11eb-081a-6b1ac49e8d6c
function body_at_time(body, t)
		body_ = Body(body.radius, t / 365 /body.earth_years_per_year + body.offset, body.dist_to_sun, body.earth_years_per_year, body.offset, body.orbit_around)
end

# ╔═╡ 90190350-845f-11eb-2012-eb0a61802819
earth_at_time = body_at_time(earth,earth_days)

# ╔═╡ edb3a450-8452-11eb-0911-bf1caf847ea6
new_orientation = (abs_pos(earth_at_time).-abs_pos(sun) )

# ╔═╡ 3e532340-8453-11eb-250e-a113554ff009
new_origin = abs_pos(earth_at_time) 

# ╔═╡ 3b95aff0-845e-11eb-254f-5fd0c4ecdac2
reorient(abs_pos(sun), new_orientation, new_origin)

# ╔═╡ 04b712a0-8457-11eb-24cb-d7e976cc0825
new_position = reorient(abs_pos(sun), new_orientation, new_origin)

# ╔═╡ 96a2f21c-7fa0-11eb-3ae8-8563b736b30e
function plot_solar_system(bodies)
	scene = []
	for (i,body) in enumerate(bodies)
		new_position = reorient(abs_pos(body), new_orientation, new_origin)[:]
		if (i==1) #| (i==length(bodies))
			scene = [FancySphere(new_position, 
										body.radius, 
										Float64[1., 1., 0.0], 
										0.0, 
										0.0, 
										Float64[3.0, 3.0, 3.0])]
		else
			scene = [scene; FancySphere(new_position, 
										body.radius*800, 
										Float64[0.20, 0.20, 0.20], 
										0.0, 
										0.0, 
										Float64[0.0, 0.0, 0.0])]
		end
	end
  RayTrace.render(RayTrace.ListScene(scene); width=500,height=500)#, trc=RayTrace.trcdepth)
end

# ╔═╡ e7ce1500-8468-11eb-2fac-31d121fabb96
begin
	earth_moon_ = Body(earth_moon.radius*10, moon_offset, earth_moon.dist_to_sun, earth_moon.earth_years_per_year, moon_offset, abs_pos(earth_at_time))
	@show abs_pos(body_at_time(earth_moon_, earth_days))-abs_pos(earth_at_time)
	newbodies = [body_at_time.(bodies,earth_days); earth_moon_]
end

# ╔═╡ c2eaa4e0-845b-11eb-1695-33032a7d2af3
im = plot_solar_system(newbodies);

# ╔═╡ 642873f2-7fa2-11eb-0756-55cbf93d273d
UnicodePlots.histogram(filter(x -> ((x!=0.0)), im[:]));

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

# ╔═╡ b7623890-845b-11eb-2ec1-77feffe75f65
rgbimg(im)

# ╔═╡ 6637d930-8423-11eb-2595-0357f562491c
function show_img()
  img_ = render_example_spheres()
  img = rgbimg(img_)
  ImageView.imshow(img)
end

# ╔═╡ Cell order:
# ╠═de698868-7f9b-11eb-16af-031849e1f8ac
# ╠═3cb3a910-841c-11eb-3e4b-e131de172393
# ╠═c0cda830-8422-11eb-057e-dfe59b6dc3e7
# ╠═385e2d70-8423-11eb-0260-31ee43d28996
# ╠═41bd7830-8423-11eb-3484-97b9917ad76f
# ╠═41bded60-8423-11eb-17e4-8bb3e0f75bc2
# ╠═af6a7fd0-8429-11eb-1fd9-c17aeb584666
# ╠═3b2f98c2-842a-11eb-0dce-17cbba9c7a95
# ╠═bcb1c440-8457-11eb-2e53-3582a44f6eb7
# ╠═a451cf00-845a-11eb-119b-430a1ff3c687
# ╠═57856634-7fad-11eb-3036-4d6a958e57a4
# ╟─dfc383ca-7f9c-11eb-1cae-85de56d9cfb3
# ╠═4aa60eb0-7f9d-11eb-24c7-bd6a81c79b66
# ╠═acdd3c10-7f9e-11eb-15a1-fd2ee4f552c4
# ╠═be4e263a-7f9e-11eb-3ac1-e791d0b6f87e
# ╠═924bbaa0-7fa5-11eb-3396-1972470784d5
# ╠═9d3fa7c2-7fa8-11eb-1cdc-517777362a3a
# ╠═bcabefb0-7fa8-11eb-220b-4fed094e221f
# ╠═8effea2c-7f9d-11eb-0434-99749285b842
# ╠═36abaa90-8467-11eb-1301-fb7831fe8830
# ╠═9237e558-7f9f-11eb-3fd2-9be5c7ebf90d
# ╠═0d880270-7fa9-11eb-297a-3b2ce952fa33
# ╠═1c507e92-7fa9-11eb-393a-65742f2b78ab
# ╠═1deca260-7fa9-11eb-33a5-85ce58f5628a
# ╠═1ed1ab30-7fa9-11eb-0f92-f7935e71b1b3
# ╠═1f7e17ce-7fa9-11eb-3a45-7d411128e0ed
# ╠═ceac869e-842d-11eb-0e88-a3566bd1f4c1
# ╠═53bf77a0-8427-11eb-0f30-c923d76cd874
# ╠═edb3a450-8452-11eb-0911-bf1caf847ea6
# ╠═90190350-845f-11eb-2012-eb0a61802819
# ╠═3e532340-8453-11eb-250e-a113554ff009
# ╠═3b95aff0-845e-11eb-254f-5fd0c4ecdac2
# ╠═04b712a0-8457-11eb-24cb-d7e976cc0825
# ╠═96a2f21c-7fa0-11eb-3ae8-8563b736b30e
# ╠═c3ca09d8-7fa0-11eb-17f8-cf753ad27443
# ╠═642873f2-7fa2-11eb-0756-55cbf93d273d
# ╠═c2eaa4e0-845b-11eb-1695-33032a7d2af3
# ╠═b7623890-845b-11eb-2ec1-77feffe75f65
# ╠═748f0ff0-7fd0-11eb-373b-a938bdb0b34c
# ╠═0a6e73f0-846b-11eb-2623-bdbbd52c7343
# ╠═90974550-7fd0-11eb-081a-6b1ac49e8d6c
# ╠═e7ce1500-8468-11eb-2fac-31d121fabb96
# ╠═662bcb40-8423-11eb-22c2-11bc9a628f37
# ╠═6637d930-8423-11eb-2595-0357f562491c
