extends ObjectTrack

func _init():
	track_type = TrackTypes.SCALE

func track_step(_time : float, _object : Static):
	
	if !is_enabled() or points.empty(): return
	
	match step_type:
		
		StepTypes.LINEAR:
			if times[1] < _time:
				times.remove(0)
				
				for _x in range(4):
					points.remove(0)
			
			var t = ((_time - times[0]) / (times[1] - times[0]))
			var x = (points[1] - points[0]) * t
			var y = (points[3] - points[2]) * t
			
			_object._update_scale(Vector2(x,y))
		
		StepTypes.NEAREST:
			
			if times[0] < _time:
				times.remove(0)
				
				_object._update_scale(points[0])
				
				points.remove(0)
				
			
		
		StepTypes.BEZIER:
			
			if times[1] < _time:
				times.remove[0]
				for _i in range(8):
					points.remove[0]
			
			var t = ((_time - times[0]) / (times[1] - times[0]))
			
			var p = [ 
				Vector2(points[0],times[0]), 
				Vector2(points[2],points[3]), 
				Vector2(points[4],points[5]), 
				Vector2(points[6],times[1])]
			
			if is_x_track():
				_object._bezier_update_scale_x(p, t)
				return
			
			_object._bezier_update_scale_y(p, t)
			
		
