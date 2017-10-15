with ANU_Base_Board.LED_Interface;  use ANU_Base_Board.LED_Interface;
with Discovery_Board.LED_Interface; use Discovery_Board.LED_Interface;
with Discovery_Board;               use Discovery_Board;
with ANU_Base_Board.Com_Interface;  use ANU_Base_Board.Com_Interface;
with ANU_Base_Board;                use ANU_Base_Board;
with STM32F4;                       use STM32F4;
with Ada.Real_Time;                 use Ada.Real_Time;

package body Gen_Rec_In_One is

   package DBL  renames Discovery_Board.LED_Interface;
   -- package ABBL renames ANU_Base_Board.LED_Interface;

   systemStart : constant Time := Clock;
   periodDuration : constant Positive := 3000; -- periodDuration is in unit of milliseconds
   period : constant Time_Span := Milliseconds (periodDuration); -- 1000/50, typically 20ms

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

   -------------------------
   ---- generator ----------
   -------------------------

   task SquareWaveGenRec;
   task body SquareWaveGenRec is
      currentPeriodStart : Time := systemStart;
      halfPeriod : constant Time_Span := Milliseconds (periodDuration / 2); -- 500/50 -- period / 2.0;
      quarterPeriod : constant Time_Span := Milliseconds (periodDuration / 4);
      readResult : Bit;
   begin
      delay until systemStart + Milliseconds (2000);
      loop -- toggle (1) all LED on DB, (2) Left LED on 1st Com port, and (3) Tx data on 1st Com port.
         -- generate and transimit
         DBL.All_On;
         All_Set;
         All_Left_On;

         delay until currentPeriodStart + quarterPeriod;
         -- read
         for thisComPort in Com_Ports loop
            readResult := Read (thisComPort);
            if readResult = Bit'First then
               Off ((thisComPort, R));
            else
               On ((thisComPort, R));
            end if;
         end loop;

         delay until currentPeriodStart + halfPeriod;
         -- generate and transimit
         DBL.All_Off;
         All_Reset;
         All_Left_Off;

         delay until currentPeriodStart + halfPeriod + quarterPeriod;
         -- read
         for thisComPort in Com_Ports loop
            readResult := Read (thisComPort);
            if readResult = Bit'First then
               Off ((thisComPort, R));
            else
               On ((thisComPort, R));
            end if;
         end loop;

         delay until currentPeriodStart + period;
         currentPeriodStart := currentPeriodStart + period;
      end loop;
   exception
         when others => On (Red);
   end SquareWaveGenRec;

end Gen_Rec_In_One;
