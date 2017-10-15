with ANU_Base_Board;                use ANU_Base_Board;

with System; use System;

package Receive_Wave is

   task type Receiver (port : Com_Ports) is
      pragma Priority (Default_Priority);
   end Receiver;

end Receive_Wave;
