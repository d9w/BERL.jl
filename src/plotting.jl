using Gadfly
using Dates

export BERLplot

set_default_plot_size(30cm, 20cm)

function logs_to_layers(id::String; color)
	path = "logs/$id.log"
    fileString = readlines(path)
	steps::Array = []
	max_fitness::Array = []
	time::Array = []
	for i in fileString
		l = split(i, " ")
		push!(steps, parse(Int64, l[4]))
		t = split(l[1], "\t")[1]
		push!(time, DateTime(t)) #timestamp
		push!(max_fitness, float(parse(Float64, l[6]))) #max
	end
	time = Dates.value.(time .- time[1])
	f = layer(x=steps, y=max_fitness, Geom.point, Geom.line, Theme(default_color=color))
	t = layer(x=time,  y=max_fitness, Geom.point, Geom.line, Theme(default_color=color))
	f, t
end

function BERLplot(id::String)
	f, t = logs_to_layers(id; color=colorant"blue")
	f = plot(f, Guide.xlabel("Evals"), Guide.ylabel("Max fitness"), Guide.title("Max fitness / eval"))
	t = plot(t, Guide.xlabel("Time (ms)"), Guide.ylabel("Max fitness"), Guide.title("Max fitness / time"))
	p = hstack(f, t)
	title(p, id)
	# push!(p, Guide.title(id))
	display(p)
	img = SVG("plots/$id.svg", 30cm, 20cm)
	draw(img, p)
end

function BERLplot(ids::Array{String}; name::String=string(UUIDs.uuid4(), ".svg"))
	palette = Scale.color_discrete().f(length(ids))
	f_list::Array{} = []
	t_list::Array{} = []
	for i in eachindex(ids)
		f, t = logs_to_layers(ids[i]; color=palette[i])
		push!(f_list, f)
		push!(t_list, t)
	end
	f = plot(f_list..., Scale.color_discrete, Guide.xlabel("Evals"), Guide.ylabel("Max fitness"), Guide.title("Max fitness / eval"))
	t = plot(t_list..., Scale.color_discrete, Guide.xlabel("Time (ms)"), Guide.ylabel("Max fitness"), Guide.title("Max fitness / time"))
	p = hstack(f, t)
	title(p, name)
	display(p)
	img = SVG("plots/$name", 30cm, 20cm)
	draw(img, p)
end
