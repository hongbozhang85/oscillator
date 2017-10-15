with Ada.Real_Time;                 use Ada.Real_Time;
with System;                        use System;

package Wave is

   procedure All_Set;
   procedure All_Reset;
   procedure All_Left_On;
   procedure All_Left_Off;

   task type SquareWave is
      pragma Priority (Default_Priority);
   end SquareWave;

   task type SawtoothWave is
      pragma Priority (Default_Priority);
   end SawtoothWave;

   task type SineWave is
      pragma Priority (Default_Priority);
   end SineWave;

private

   -- for testing purpose, set periodDuration as long as possible.
   -- since the human eye cannot distinguish signals faster than 24Hz
   -- 1/24*100 = 4.16s. (where 100 is segmentNum)
   -- so periodDuation should be greater than 4.16.
   -- otherwise, the sawtoothWave will not increase its brightness continuously.
   periodDuration : Positive := 3000; -- periodDuration is in unit of milliseconds
   period : Time_Span := Milliseconds (periodDuration); -- 1000/50, typically 20ms
   amp : constant Float := 1.0;

end Wave;
