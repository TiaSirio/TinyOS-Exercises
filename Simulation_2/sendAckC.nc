/**
 *  Source file for implementation of module sendAckC in which
 *  the node 1 send a request to node 2 until it receives a response.
 *  The reply message contains a reading from the Fake Sensor.
 *
 *  @author Luca Pietro Borsani
 */

#include "sendAck.h"
#include "Timer.h"

module sendAckC {

  uses {
  /****** INTERFACES *****/
	interface Boot;
	interface AMSend;
	interface Receive;
	interface Timer<TMilli> as MilliTimer;
	interface SplitControl as AMControl;
	interface PacketAcknowledgements;
	interface Packet;

    //interfaces for communication
	//interface for timer
    //other interfaces, if needed

	//interface used to perform sensor reading (to get the value from a sensor)
	interface Read<uint16_t>;
  }

} implementation {

  uint8_t counter = 0;
  uint8_t rec_id;
  uint8_t ACK_received = 0;
  message_t packet;
  bool locked;

  void sendReq();
  void sendResp();


  //***************** Send request function ********************//
  void sendReq() {
    	my_msg_t* msg = (my_msg_t*)(call Packet.getPayload(&packet, sizeof(my_msg_t)));
      if (msg == NULL) {
     		return;
      }

      msg->msg_type = 1;
      msg->msg_counter = counter;
      msg->value = 0;

      call PacketAcknowledgements.requestAck(&packet);

      if (call AMSend.send(2, &packet, sizeof(my_msg_t)) == SUCCESS){
      	dbg("radio","Message sent! -> ");
      	dbg_clear("radio", "at time %s\n", sim_time_string());
      	locked = TRUE;
      }

    	/* This function is called when we want to send a request
  	 *
  	 * STEPS:
  	 * 1. Prepare the msg
  	 * 2. Set the ACK flag for the message using the PacketAcknowledgements interface
  	 *     (read the docs)
  	 * 3. Send an UNICAST message to the correct node
  	 * X. Use debug statements showing what's happening (i.e. message fields)
  	 */
   }

    //****************** Task send response *****************//
    void sendResp() {
    	/* This function is called when we receive the REQ message.
    	 * Nothing to do here.
    	 * `call Read.read()` reads from the fake sensor.
    	 * When the reading is done it raise the event read one.
    	 */
  	call Read.read();
    }

  //***************** Boot interface ********************//
  event void Boot.booted() {
	dbg("boot","Application booted %u. \n", TOS_NODE_ID);
    call AMControl.start();
  }

  //***************** SplitControl interface ********************//
  event void AMControl.startDone(error_t err){
	if (err == SUCCESS){
		dbg("radio", "Radio ON!\n");
		if (TOS_NODE_ID == 1){
			dbg("app", "Node %u timer OK\n", TOS_NODE_ID);
			call MilliTimer.startPeriodic(1000);
		} else {
			dbg("app", "Node %u has been started\n", TOS_NODE_ID);
		}
	} else {
		dbgerror("radio", "Radio error, trying to turning on again...\n");
	}
  }

  event void AMControl.stopDone(error_t err){
	//NOthing to implement!
  }

  //***************** MilliTimer interface ********************//
  event void MilliTimer.fired() {
	if (locked) {
      return;
    } else {
      counter++;
      sendReq();
    }
	/* This event is triggered every time the timer fires.
	 * When the timer fires, we send a request
	 * Fill this part...
	 */
  }


  //********************* AMSend interface ****************//
  event void AMSend.sendDone(message_t* buf,error_t err) {
	my_msg_t* mess = (my_msg_t*)(call Packet.getPayload(&packet, sizeof(my_msg_t)));
    if (mess == NULL){
   		return;
    }
    if(err == SUCCESS && call PacketAcknowledgements.wasAcked(buf)){
    	dbg("radio","ACK correctly received!\n");
    	call MilliTimer.stop();
    }
	/* This event is triggered when a message is sent
	 *
	 * STEPS:
	 * 1. Check if the packet is sent
	 * 2. Check if the ACK is received (read the docs)
	 * 2a. If yes, stop the timer. The program is done
	 * 2b. Otherwise, send again the request
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */
	 if (&packet == buf) {
      locked = FALSE;
    }
  }

  //***************************** Receive interface *****************//
  event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {
	if (len != sizeof(my_msg_t)) {return buf;}
    else {
      my_msg_t* rcm = (my_msg_t*)payload;

      dbg("radio_rec", "Received packet at time %s\n", sim_time_string());
      dbg("radio_pack","Pack \n \t Payload length -> %hhu \n \t Counter -> %u \n \t Type -> %u\n", call Packet.payloadLength(buf), rcm->msg_counter, rcm->msg_type);


      if (rcm->msg_type == 1){
      	dbg("app","Preparing response...\n");
      	counter = rcm->msg_counter;
      	sendResp();
      } else {
      	dbg_clear("radio_pack", "\t Value -> %hhu \n", rcm->value);
      }

	}
  }

  //************************* Read interface **********************//
  event void Read.readDone(error_t result, uint16_t data) {
	my_msg_t* mess = (my_msg_t*)(call Packet.getPayload(&packet, sizeof(my_msg_t)));
    if (mess == NULL){
   		return;
    }

    mess->msg_type = 2;
    mess->msg_counter = counter;
    mess->value = data;

    call PacketAcknowledgements.requestAck(&packet);

    if (call AMSend.send(1, &packet, sizeof(my_msg_t)) == SUCCESS){
    	dbg("radio","Message sent!\n");
    	dbg("radio_pack","Pack\n \t Payload length -> %hhu \n", call Packet.payloadLength(&packet));
    	dbg_clear("radio_pack","\t Counter -> %hhu \n", mess->msg_counter);
    	dbg_clear("radio_pack","\t Type -> %hhu \n", mess->msg_type);
    	dbg_clear("radio_pack","\t Value -> %hhu \n", mess->value);
    }
	/* This event is triggered when the fake sensor finish to read (after a Read.read())
	 *
	 * STEPS:
	 * 1. Prepare the response (RESP)
	 * 2. Send back (with a unicast message) the response
	 * X. Use debug statement showing what's happening (i.e. message fields)
	 */
}

}
