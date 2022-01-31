extends Node2D

func _process(delta: float) -> void:
	$Icon.rotation_degrees += 180 * delta


func _on_BackgroundWorker_busy() -> void:
	$Loading.visible = true


func _on_BackgroundWorker_free() -> void:
	$Loading.visible = false


func _on_BackgroundWorker_progress(completed, total) -> void:
	$Loading/ProgressBar.max_value = total
	$Loading/ProgressBar.value = completed

func _on_Button_pressed() -> void:
	$BackgroundWorker.queue_job(self, "random_job", [])

func random_job() -> void:
	OS.delay_msec(rand_range(1000, 5000))
