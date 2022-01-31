extends Node

## The minimum time in seconds the workers have to be busy for visibility to kick in
export var show_timeout = 0.250

## The mimium time in seconds the workers have to be idle for visibility to cease
export var hide_timeout = 0.500

## The number of worker threads to be used
export var worker_count = 2


var visible = false
var jobs: Array
var start_time: float
var last_time: float
var running = 0
var threads: Array
var active = false
var completed = 0
var total = 0

## Triggered once work starts
signal started()
## Triggered once work is finished
signal finished(total)
## Triggered once UI hints should be shown
signal busy()
## Triggered once UI hints should be hidden
signal free()
## Triggered whenever progress updates
signal progress(completed, total)

class BackgroundWorkerJob:
	var target: Object
	var method: String
	var binds: Array
	
	## Creates a new Background Worker Job
	func _init(target: Object, method: String, binds: Array = []) -> void:
		self.target = target
		self.method = method
		self.binds = binds
	
	## Executes the job and returns true, if processing of the job is complete
	func execute(_dummy: BackgroundWorkerJob = null) -> void:
		target.callv(method, binds)

## Queue up a member function call as a new job
func queue_job(target: Object, method: String, binds: Array = []) -> void:
	jobs.append(BackgroundWorkerJob.new(target, method, binds))
	total += 1

## Queue up a resource load as a job
func queue_load(file: String, type_hint: String = '') -> void:
	jobs.append(BackgroundWorkerJob.new(ResourceLoader, 'load', [file, type_hint]))
	total += 1

## Clear all still unprocessed jobs
func clear_queue() -> void:
	total -= len(jobs)
	jobs.clear()

## Return the number of queued jobs
func queue_length() -> int:
	return len(jobs)

func _process(_delta: float) -> void:
	if active and not visible:
		if OS.get_ticks_msec() / 1000.0 > start_time + show_timeout:
			emit_signal('progress', completed, total)
			emit_signal('busy')
			visible = true
	if len(jobs) > 0:
		while len(threads) < worker_count:
			threads.append(Thread.new())
		
		if not active:
			start_time = OS.get_ticks_msec() / 1000.0
			active = true
			emit_signal('started')
		var c = 0
		for i in worker_count:
			c += 1
			if not threads[i].is_active():
				var job = jobs.front()
				threads[i].start(job, 'execute', job)
				jobs.pop_front()
				running += 1
				break
		last_time = OS.get_ticks_msec() / 1000.0
		emit_signal('progress', completed, total)
	if running > 0:
		var c = 0
		for thread in threads:
			c += 1
			if thread.is_active() and not thread.is_alive():
				thread.wait_to_finish()
				running -= 1
				completed += 1
				emit_signal('progress', completed, total)
				if running == 0:
					active = false
					emit_signal('finished', total)
					completed = 0
					total = 0
		last_time = OS.get_ticks_msec() / 1000.0
	elif not active and visible and OS.get_ticks_msec() / 1000.0 > last_time + hide_timeout:
		emit_signal('free')
		visible = false
