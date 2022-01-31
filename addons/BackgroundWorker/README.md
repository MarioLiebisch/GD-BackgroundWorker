# BackgroundWorker Node for Godot 3.x

This plugin provides a new node `BackgroundWorker` to make it easy to queue up and track background tasks.
This can be used to preload scenes, save games, synchronize or upload files, etc.

All queued up jobs are processed by an adjustable amount of worker threads.
For strict linear processing "one after the other" you can reduce the number of active worker threads to one.

Progress is reported back through signals, although hooked up functions can still trigger their own signals from their own thread in case you need it.

## Installation

The latest version of the addon can be found in [my repository](https://github.com/MarioLiebisch/GD-BackgroundWorker).

As with any other Godot addon, put the contents of `addons/BackgroundWorker` in your own project's `addons` directory and make sure to enable it in Project Setting's "Plugins" tab.

## Usage

To queue up new jobs, call the member methods `queue_job(target, method, [binds])` or `queue_load(file, [type_hint]`). Processing starts automatically on the next frame.

### Properties

#### show_timeout [= 0.250]

The minimum time in seconds the workers have to be busy for visibility to kick in.

#### hide_timeout [= 0.500]

The mimium time in seconds the workers have to be idle for visibility to cease

#### worker_count [= 2]

The number of worker threads to be used.

### Methods

#### queue_job(target: Object, method: String, binds: Array = []) -> void

Queues a new job to call `method()` on `target` passing `binds` (if set).

#### queue_load(file: String, type_hint: String = '') -> void

Queues loading a file using Godot's `load()`, passing the optional `type_hint` (if set).

#### clear_queue() -> void

Remove/cancel any queued job not yet started.

#### queue_length() -> int

Return the number of queued jobs not yet started.

### Signals

#### started()

Triggered as soon as the first job starts processing.

#### finished(total: int)

Triggered once all queued up jobs have finished processing.

#### busy()

Triggered once busy longer than defined in `show_timeout` to show a visible indicator.

#### free()

Triggered once all queued up jobs have finished and the timeout defined in `hide_timeout` has passed to hide indicators.

#### progress(completed: int, total: int)

Triggered whenever progress is made. This can be used to show relative progress to the user.
