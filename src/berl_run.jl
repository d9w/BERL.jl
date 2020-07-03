export start_berl

s = ArgParseSettings()
@add_arg_table s begin
    "--algo"
    help = "configuration script"
    default = "CGP"
    "--env"
    help = "environment"
    default = "testenv"
    "--param"
    help = "environment parameter"
    default = ""
end
args = parse_args(ARGS, s)

start_berl(algo=args["algo"], env=args["env"]) 
