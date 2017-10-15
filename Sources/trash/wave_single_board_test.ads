with System;                        use System;
with ANU_Base_Board;                use ANU_Base_Board;

package Wave_Single_Board_Test is

   task type SquareWave (periodD : Positive; port : Com_Ports) is
      pragma Priority (Default_Priority);
   end SquareWave;

   task type SawtoothWave (periodD : Positive; port : Com_Ports) is
      pragma Priority (Default_Priority);
   end SawtoothWave;

   task type SineWave (periodD : Positive; port : Com_Ports) is
      pragma Priority (Default_Priority);
   end SineWave;

private

   amp : constant Float := 1.0;

end Wave_Single_Board_Test;
