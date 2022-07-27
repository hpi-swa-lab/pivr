# adapted from https://github.com/jaantollander/OneEuroFilter

class_name OneEuroFilter

extends Node

func smoothing_factor(t_e, cutoff):
	var r = 2 * PI * cutoff * t_e
	return r / (r + 1)


func exponential_smoothing(a, x, x_prev):
	return a * x + (1 - a) * x_prev

# The parameters.
var min_cutoff
var beta
var d_cutoff
# Previous values.
var x_prev
var dx_prev
var t_prev


func _init(t0, x0, dx0=0.0, min_cutoff_=1.0, beta_=0.0, d_cutoff_=1.0):
	min_cutoff = float(min_cutoff_)
	beta = float(beta_)
	d_cutoff = float(d_cutoff_)
	x_prev = float(x0)
	dx_prev = float(dx0)
	t_prev = float(t0)

func filter(t, x):
	# Compute the filtered signal.
	var t_e = t - t_prev

	# The filtered derivative of the signal.
	var a_d = smoothing_factor(t_e, d_cutoff)
	var dx = (x - x_prev) / t_e
	var dx_hat = exponential_smoothing(a_d, dx, dx_prev)

	# The filtered signal.
	var cutoff = min_cutoff + beta * abs(dx_hat)
	var a = smoothing_factor(t_e, cutoff)
	var x_hat = exponential_smoothing(a, x, x_prev)

	# Memorize the previous values.
	x_prev = x_hat
	dx_prev = dx_hat
	t_prev = t

	return x_hat
