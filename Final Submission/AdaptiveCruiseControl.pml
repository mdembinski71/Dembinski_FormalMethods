show bool car_ahead=false;
show bool deccelerate=false;
show bool accelerate=false;
show bool decreaseDist=false;
show bool increaseDist=false;
bool at_threshold=false;
bool tooClose= false;
bool tooFar = true;


active proctype searching(){
do
	::true->
	if
		::true->atomic {car_ahead=false; increaseDist = false; decreaseDist = false}
		::true->car_ahead=true;
	fi		
od	
}

active proctype distance_monitor(){
do
::car_ahead -> 
	if
	::true->atomic{decreaseDist = true; increaseDist=false}
	::true->atomic{increaseDist = true; decreaseDist = false}
	::true->atomic{increaseDist = false; decreaseDist = false}
	fi
	if
	::true->atomic{tooFar = true; tooClose=false}
	::true->atomic{tooFar = true; tooClose = false}
	::true->atomic{tooFar = false; tooClose = false}
	fi	
od
}

active proctype control(){
do
::(car_ahead && increaseDist && !tooClose && !at_threshold)->
atomic {accelerate = true;
	deccelerate = false;}

::(car_ahead && increaseDist && tooClose)->
atomic {accelerate = false;
	deccelerate = false;}
	
::(car_ahead && decreaseDist && tooFar) ->
atomic {accelerate = false;
	deccelerate = false;}

::(car_ahead && decreaseDist  && tooClose) ->
atomic {accelerate = false;
	deccelerate = true;}

::(!car_ahead && !at_threshold) ->
atomic {accelerate = true;
	deccelerate = false;}

::(accelerate && !at_threshold) ->
atomic {accelerate = false;
	deccelerate = false;
	at_threshold = true;
}

::(car_ahead && !decreaseDist && !increaseDist && !tooFar && !tooClose) ->
atomic { accelerate = false;
	deccelerate = false;
}

::(car_ahead && !decreaseDist && !increaseDist && tooClose) ->
atomic { accelerate = false;
	deccelerate = true;}

::(car_ahead && !decreaseDist && !increaseDist && tooFar && !at_threshold) ->
atomic { accelerate = true;
	deccelerate = false;}
	
od
}
ltl safety{[]<>!tooClose}
ltl logicC{[]<>!tooFar}
ltl logic{[]!(increaseDist && decreaseDist)}
ltl logicB{[]!(accelerate && deccelerate)}
