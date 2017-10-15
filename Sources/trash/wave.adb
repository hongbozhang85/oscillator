with ANU_Base_Board.LED_Interface;  use ANU_Base_Board.LED_Interface;
with Discovery_Board.LED_Interface; use Discovery_Board.LED_Interface;
with Discovery_Board;               use Discovery_Board;
with ANU_Base_Board.Com_Interface;  use ANU_Base_Board.Com_Interface;
with ANU_Base_Board;                use ANU_Base_Board;

package body Wave is

   package DBL  renames Discovery_Board.LED_Interface;
   -- package ABBL renames ANU_Base_Board.LED_Interface;

   systemStart : constant Time := Clock;

   -------------------------------------------
   ----------- useful functions --------------
   -------------------------------------------

   -- set all com-ports TX data to 1
   procedure All_Set is
   begin
      for Port in Com_Ports loop
         Set (Port);
      end loop;
   end All_Set;

   -- set all com-ports TX data to 0
   procedure All_Reset is
   begin
      for Port in Com_Ports loop
         Reset (Port);
      end loop;
   end All_Reset;

   -- set all left LED of com-ports off
   procedure All_Left_Off is
   begin
      for Port in Com_Ports loop
         Off ((Port, L));
      end loop;
   end All_Left_Off;

   -- set all left LED of com-ports on
   procedure All_Left_On is
   begin
      for Port in Com_Ports loop
         On ((Port, L));
      end loop;
   end All_Left_On;

   -------------------------------------------
   -------------- SquareWave -----------------
   -------------------------------------------
   task body SquareWave is
      currentPeriodStart : Time := systemStart;
      halfPeriod : constant Time_Span := Milliseconds (periodDuration / 2); -- 500/50 -- period / 2.0;
   begin
      delay until systemStart + Milliseconds (2000);
      loop -- toggle (1) all LED on DB, (2) Left LED on 1st Com port, and (3) Tx data on 1st Com port.
         DBL.All_On;
         All_Set;
         All_Left_On;
         delay until currentPeriodStart + halfPeriod;
         DBL.All_Off;
         All_Reset;
         All_Left_Off;
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
         All_Set;
         All_Left_On;
         -- dutyCycle increases in each loop
         delay until loopStart + Microseconds (Integer (loopDuration * 1000.0 * dutyCycle));
         DBL.All_Off;
         All_Reset;
         All_Left_Off;
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
   testWave : SquareWave;
   -- testWave : SawtoothWave;

end Wave;
