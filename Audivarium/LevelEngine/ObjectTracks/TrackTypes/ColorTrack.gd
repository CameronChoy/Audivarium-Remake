extends ObjectTrack
#points contains [red,green,blue,alpha]
#cannot use bezier
func _init():
	track_type = TrackTypes.COLOR

func track_step(_time : float, _object : Static):
	
	if !is_enabled() or points.empty(): return
	
	match step_type:
		StepTypes.NEAREST:
			
			if times[0] < _time:
				times.remove(0)
				
				_object._set_color(Color(points[0], points[1], points[2], points[3]))
				
				for _i in range(4):
					points.remove(0)
				
			
		_:
			
			if times[1] < _time:
				times.remove(0)
				
				for _i in range(4):
					points.remove(0)
				
			
			var t = ((_time - times[0]) / (times[1] - times[0]))
			
			var c1 = Color(points[0], points[1], points[2], points[3])
			var c2 = Color(points[4], points[5], points[6], points[7])
			
			_object._set_color(c1.linear_interpolate(c2, t))
			
		
	
