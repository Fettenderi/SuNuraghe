class_name ReceiverRes
extends EmitterRes

## A resource that receives a [EmitterRes] signal.
##
## The [ReceiverRes] resource will listen for [EmitterRes] signals, allows information exchange between these two.

## Emitted when [method EmitterRes.send_signal] is executed and the corresponding [EmitterRes] resource has a reference to this resource in [param EmitterRes.receivers][br][br]
signal received(value)
