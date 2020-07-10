extends ObjectTrack

func _init():
	track_type = TrackTypes.Z_INDEX

func track_step(_time : float, _object : Static):
	
	if !is_enabled() or points.empty(): return
	
	if times[0] < _time:
		
			times.remove(0)
			
			_object._set_z_index(points[0])
			
			points.remove(0)
			
	
