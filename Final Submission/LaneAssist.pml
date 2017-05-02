show bool laneRclosing=false;
show bool laneLclosing=false;
show bool laneLbreach=false;
show bool laneRbreach=false;
show bool warning=false;
show bool correctR=false;
show bool correctL=false;
show bool laneRvisual=false;
show bool laneLvisual=false;
bool controlling = false;
bool open = true;


active proctype reading(){
do
	::open->
	if
		::true->atomic{laneRvisual=false; laneLvisual=false; controlling = false; warning = false; laneRbreach=false; laneLbreach=false;}
		::true->atomic{laneRvisual=true; laneLvisual=false; controlling = false; warning = false; laneLbreach=false; laneRbreach=false}
		::true->atomic{laneRvisual=true; laneLvisual=true}
		::true->atomic{laneRvisual=false; laneLvisual=true; controlling = false; warning = false; laneRbreach=false; laneLbreach=false}
	fi		
	open=false;
od	
}

active proctype lane_monitor(){
do
::(laneRvisual && laneLvisual && !controlling)-> 
	if
	::true->atomic{laneLclosing = false; laneRclosing=false}
	::true->atomic{laneLclosing = false; laneRclosing=true}
	::true->atomic{laneLclosing = true; laneRclosing=false}
	::true->atomic{laneLclosing = true; laneRclosing=true}
	::(laneLclosing && warning) -> atomic{laneLbreach=true; controlling = true}
	::(laneRclosing && warning )-> atomic {laneRbreach = true; controlling = true}
	fi	
	open = true;
od
}

active proctype control(){
do
::(laneRvisual && laneLvisual)->
if
::(laneLclosing && !laneRclosing && !warning )->
warning = true;

::(laneRclosing  && !laneLclosing && !warning)->
warning =true;
		
::(!laneLclosing  && !laneRclosing && warning) ->
atomic{warning = false; correctL = false; correctR=false;}

::(laneLbreach) ->
atomic{correctR = true; laneLclosing = false; laneLbreach = false}

::(laneRbreach) ->
atomic {correctL = true; laneRclosing = false; laneRbreach = false}
fi

od
}
ltl safety{[]<>!laneRbreach}
ltl safety{[]<>!laneLbreach}
ltl breachL{[](laneLbreach -> <>!warning)}
ltl breachR {[](laneRbreach -> <>correctL)}
