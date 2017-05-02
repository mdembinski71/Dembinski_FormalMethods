show bool humanControlSteering=true;
show bool collisionMonitor=false;
show bool laneMonitor=false;
show bool speedMonitor=true;
show bool warning=false;
show bool collisionControl=false;
show bool speedControl=true;
show bool laneControl=false;
bool controlling = false;
bool distributing = false;

active proctype reading(){
do
	::(!controlling && !distributing)->
	if
		::true->atomic{collisionMonitor=false; laneMonitor=false; speedMonitor=true}
		::true->atomic{collisionMonitor=false; laneMonitor=true; speedMonitor=true}
		::true->atomic{collisionMonitor=true; laneMonitor=false; speedMonitor=true}
		::true->atomic{collisionMonitor=true; laneMonitor=true; speedMonitor=true}
	fi		
	distributing = true;
od	
}

active proctype control_distribution(){
do
::(distributing)-> 
	if
	::(collisionMonitor && laneMonitor && speedMonitor && !controlling)-> 
	controlling = true;
	warning = true;
	humanControlSteering = false;
	speedControl = false;
	collisionControl = true;
	collisionMonitor = false;
	collisionControl = false;
	speedControl = true;
	laneControl = true; 
	laneMonitor = false;
	laneControl = false;
	humanControlSteering = true;
	warning = false;
	controlling = false;

	::(!collisionMonitor && laneMonitor && speedMonitor && !controlling)-> 
	controlling = true;
	warning = true;
	humanControlSteering = false;
	laneControl = true; 
	laneMonitor = false;
	laneControl = false;
	humanControlSteering = true;
	warning = false;
	controlling = false;

	::(!collisionMonitor && !laneMonitor && speedMonitor && !controlling)-> 
	controlling = true;
	humanControlSteering = true;
	controlling = false;
	::(collisionMonitor && !laneMonitor && speedMonitor && !controlling)-> 
	controlling = true;
	warning = true;
	humanControlSteering = false;
	speedControl = false;
	collisionControl = true;
	collisionMonitor = false;
	collisionControl = false;
	speedControl = true;
	humanControlSteering = true;
	warning = false;
	controlling = false;
	fi
	distributing = false;	
od
}

ltl liveness {[]<>humanControlSteering}
