with ANU_Base_Board.Com_Interface;  use ANU_Base_Board.Com_Interface;
with ANU_Base_Board.LED_Interface;  use ANU_Base_Board.LED_Interface;
with STM32F4;                       use STM32F4;
with Ada.Real_Time;                 use Ada.Real_Time;
with ANU_Base_Board;                use ANU_Base_Board;

package body Receive_Wave_One is

   systemStart : constant Time := Clock;

   task body Receiver_One is
      readResult : Bit;
      loopStart : Time := systemStart;
   begin
      -- thisComPort := Com_Ports'Last;
      loopStart := systemStart + Milliseconds (2000) + Milliseconds (750);
      delay until loopStart;
      loop
         for thisComPort in Com_Ports loop
            readResult := Read (thisComPort);
            if readResult = Bit'First then
               Off ((thisComPort, R));
            else
               On ((thisComPort, R));
            end if;
         end loop;
         delay until loopStart + Milliseconds (1500); -- Microseconds (300);
         loopStart := loopStart + Milliseconds (1500);
      end loop;
   end Receiver_One;

   -----spawn task------
   -- receivers : array (Com_Ports) of Receiver;
   -- for com in Com_Ports loop
   --   receivers(com).setCom(com);
   -- end loop;
   receiver1 : Receiver_One;

end Receive_Wave_One;
