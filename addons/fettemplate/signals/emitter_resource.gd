class_name EmitterRes
extends Resource

## A resource for multiple [ReceiverRes] resources signal emission.
##
## The [EmitterRes] allows information exchange among various [ReceiverRes] resources.

## Reference to all [ReceiverRes] resources. These will emit [signal ReceiverRes.recieved] upon [method send_signal].
@export var receivers : Array[ReceiverRes]

## Emits a signal towards all its [member receivers].[br][br]
func send_signal(value = null):
	for _receiver : ReceiverRes in receivers:
		_receiver.received.emit(value)
		_receiver.send_signal(value)
