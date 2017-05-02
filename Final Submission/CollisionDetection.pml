show bool collisionF= false;
show bool collisionB = false;
show bool collisionR = false;
show bool collisionL = false;
show int riskF = 0;
show int riskB = 0;
show int riskR = 0;
show int riskL = 0;
show bool swerveR = false;
show bool swerveL = false;
show bool speedUp= false;
show bool brake = false;
show bool collided = false;
bool maneuvering = false;
bool riskassessed=false;
bool brakingPrioritized = true;
bool rightSwervePrioritized = true;

active proctype CollisionDetection()
{
end:
do
::!maneuvering->
if
::true -> collisionF=true;
maneuvering = true;
::true -> collisionB=true;
maneuvering = true;
::true -> collisionR = true;
maneuvering = true;
::true -> collisionL = true;
maneuvering = true;
::true -> collisionF =false;
collisionB = false;
collisionR = false;
collisionL = false;
fi;
od;
}

active proctype riskassessment()
{
end:
do
:: (maneuvering && !riskassessed)-> 
if
::collisionF -> riskF = 4;
::else ->
if
::true ->  riskF = 0;
::true -> riskF =1;
::true -> riskF = 2;
::true -> riskF = 3;
fi
fi

if
::collisionB -> riskB = 4;
::else ->
if
::true ->  riskB = 0;
::true -> riskB=1;
::true -> riskB = 2;
::true -> riskB = 3;
fi
fi

if 
::collisionR -> riskR = 4;
::else ->
if
::true ->  riskR = 0;
::true -> riskR=1;
::true -> riskR = 2;
::true -> riskR = 3;
fi
fi

if
::collisionL -> riskL = 4;
::else ->
if
::true ->  riskL = 0;
::true -> riskL =1;
::true -> riskL = 2;
::true -> riskL = 3;
fi
fi
riskassessed = true;
od
}

active proctype Maneuver()
{
do
:: (maneuvering && riskassessed) ->
if
:: (riskB <= riskF) ->
 brakingPrioritized = true;
::else -> brakingPrioritized = false;
fi
if
::(riskR <= riskL) ->
rightSwervePrioritized = true;
::else -> rightSwervePrioritized = false;
fi
if
::(brakingPrioritized && rightSwervePrioritized ) ->
	if
	::(riskB <= riskR) ->
	brake =true;
	::else ->
	swerveR = true;
	fi
::(brakingPrioritized && !rightSwervePrioritized) ->
	if 
	::(riskB <= riskL) ->
	brake = true;
	::else -> swerveL=true;
	fi
::(!brakingPrioritized && rightSwervePrioritized) ->
	if
	::(riskF <= riskR) ->
	speedUp = true;
	::else -> swerveR = true;
	fi
::(!brakingPrioritized && !rightSwervePrioritized) ->
	if
	::(riskF <= riskL) -> 
	speedUp = true;
	::else -> swerveL = true;
	fi
fi	
if
:: (riskF != 0 && riskB !=0 && riskR != 0 && riskL != 0) ->
	collided = true;
	break;
::else -> collided = false;
fi
atomic { brake = false;
	speedUp = false;
	swerveR = false;
	swerveL = false;
	riskF = 0;
	riskR = 0;
	riskL = 0;
	riskB = 0;
	collisionF = false;
	collisionB = false;
	collisionR = false;
	collisionL = false;
	maneuvering = false;
	riskassessed = false;}
od
}

ltl liveness{[]<>(!maneuvering || collided)}
ltl crash{[](!collided)}
ltl safety_front{[](speedUp -> (riskF<= riskB && riskF<=riskR && riskF <= riskL))}
ltl safety_back{[](brake -> (riskB<= riskF && riskB<=riskR && riskB <= riskL))}
ltl safety_right{[](swerveR -> (riskR<= riskB && riskR<=riskF && riskR <= riskL))}
ltl safety_left{[](swerveL -> (riskL<= riskB && riskL<=riskR && riskL <= riskF))}
ltl non_incident{[]<>(speedUp || brake || swerveR || swerveL)}
