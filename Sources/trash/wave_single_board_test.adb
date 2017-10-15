with ANU_Base_Board.LED_Interface;  use ANU_Base_Board.LED_Interface;
with Discovery_Board.LED_Interface; use Discovery_Board.LED_Interface;
with Discovery_Board;               use Discovery_Board;
with ANU_Base_Board.Com_Interface;  use ANU_Base_Board.Com_Interface;
with Ada.Real_Time;                 use Ada.Real_Time;

package body Wave_Single_Board_Test is

   package DBL  renames Discovery_Board.LED_Interface;

   systemStart : constant Time := Clock;

   -------------------------------------------
   -------------- SquareWave -----------------
   -------------------------------------------
   task body SquareWave is
      -- for testing purpose, set periodDuration as long as possible.
      -- since the human eye cannot distinguish signals faster than 24Hz
      -- 1/24*100 = 4.16s. (where 100 is segmentNum)
      -- so periodDuation should be greater than 4.16.
      -- otherwise, the sawtoothWave will not increase its brightness continuously.
      periodDuration : constant Positive := periodD; -- periodDuration is in unit of milliseconds
      period : constant Time_Span := Milliseconds (periodDuration); -- 1000/50, typically 20ms
      currentPeriodStart : Time := systemStart;
      halfPeriod : constant Time_Span := Milliseconds (periodDuration / 2); -- 500/50 -- period / 2.0;
   begin
      currentPeriodStart := systemStart + Milliseconds (2000);
      delay until currentPeriodStart;
      loop -- toggle (1) all LED on DB, (2) Left LED on 1st Com port, and (3) Tx data on 1st Com port.
         DBL.All_On;
         Set (port);
         On ((port, L));
         delay until currentPeriodStart + halfPeriod;
         DBL.All_Off;
         Reset (port);
         Off ((port, L));
         delay until currentPeriodStart + period;
         currentPeriodStart := currentPeriodStart + period;
      end loop;
   exception
      when others => On (Red);
   end SquareWave;

   -------------------------------------------
   -------------- SawtoothWave ---------------
   -------------------------------------------
   task body SawtoothWave is

      -- for testing purpose, set periodDuration as long as possible.
      -- since the human eye cannot distinguish signals faster than 24Hz
      -- 1/24*100 = 4.16s. (where 100 is segmentNum)
      -- so periodDuation should be greater than 4.16.
      -- otherwise, the sawtoothWave will not increase its brightness continuously.
      periodDuration : constant Positive := periodD; -- periodDuration is in unit of milliseconds
      -- period : constant Time_Span := Milliseconds (periodDuration); -- 1000/50, typically 20ms

      -- divide whole wave period into segmentNum(100) segments,
      -- each loop in this task will last for period/segmentNum milliseconds
      -- in each segment, the duty cycle is different,
      -- so that the LED will have different "apparent" brightness.
      -- this will be useful for visualising a triangle wave.

      segmentNum : constant Positive := 100;
      type SegmentIndex is mod segmentNum;
      thisSegIndex : SegmentIndex := SegmentIndex'First;

      dutyCycle : Float := 0.0;
      dutyCycleInc : constant Float :=  1.0 / Float (segmentNum);

      loopStart : Time := systemStart;
      loopDuration : constant Float := Float (periodDuration) / Float (segmentNum); -- typically 200us
      loopPeriod : constant Time_Span := Microseconds (Integer (loopDuration * 1000.0));

   begin
      delay until systemStart + Milliseconds (2000);
      loop -- last for period/segmentNum milliseconds
         -- toggle (1) all LED on DB, (2) Left LED on 1st Com port, and (3) Tx data on 1st Com port.
         DBL.All_On;
         Set (port);
         On ((port, L));
         -- dutyCycle increases in each loop
         delay until loopStart + Microseconds (Integer (loopDuration * 1000.0 * dutyCycle));
         DBL.All_Off;
         Reset (port);
         Off ((port, L));
         thisSegIndex := SegmentIndex'Succ (thisSegIndex);
         -- dutyCycle resets to zero every periodDuration
         dutyCycle := dutyCycleInc * Float (thisSegIndex);
         delay until loopStart + loopPeriod;
         loopStart := loopStart + loopPeriod;
      end loop;
   exception
         when others => On (Red);
   end SawtoothWave;

   -------------------------------------------
   -------------- SineWave -------------------
   -------------------------------------------
   task body SineWave is
   begin
      On (Blue);
   end SineWave;

   ----spawn tasks-----
   testWavePort1 : SquareWave (1000, 2);
   testWavePort4 : SquareWave (3000, 4);
   -- testWave : SawtoothWave;

end Wave_Single_Board_Test;
