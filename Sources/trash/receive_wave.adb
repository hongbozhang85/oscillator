with ANU_Base_Board.Com_Interface;  use ANU_Base_Board.Com_Interface;
with ANU_Base_Board.LED_Interface;  use ANU_Base_Board.LED_Interface;
with STM32F4;                       use STM32F4;
with Ada.Real_Time;                 use Ada.Real_Time;

package body Receive_Wave is

   systemStart : constant Time := Clock;

   task body Receiver is
      thisComPort : constant Com_Ports := port; -- := Com_Ports'Last;
      readResult : Bit;
      loopStart : Time := systemStart;
   begin
      -- thisComPort := Com_Ports'Last;
      delay until systemStart + Milliseconds (2000);
      loop
         readResult := Read (thisComPort);
         if readResult = Bit'First then
            Off ((thisComPort, R));
         else
            On ((thisComPort, R));
         end if;
         delay until loopStart + Microseconds (300);
         loopStart := Clock;
      end loop;
   end Receiver;

   -----spawn task------
   -- receivers : array (Com_Ports) of Receiver;
   -- for com in Com_Ports loop
   --   receivers(com).setCom(com);
   -- end loop;
   receiver1 : Receiver (1);
   receiver2 : Receiver (2);
   receiver3 : Receiver (3);
   receiver4 : Receiver (4);

end Receive_Wave;
